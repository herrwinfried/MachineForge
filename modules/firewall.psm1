# firewall.psm1
# Resolves firewall rule names from the archive and creates/removes them. All firewall operations require admin.

function Resolve-FirewallRules {
    <#
    .SYNOPSIS
        Takes a list of firewall rule names and the archive, returns resolved rule objects.
        Substitutes variable references in port fields.
    #>
    param (
        [Parameter(Mandatory)]
        [string[]]$Names,

        [Parameter(Mandatory)]
        [hashtable]$Archive,

        [hashtable]$Variables = @{}
    )

    $Rules = @()

    foreach ($RuleName in $Names) {
        if (-not $Archive.ContainsKey($RuleName)) {
            Write-Step -Section 'Firewall' -Message (Get-I18n 'UnknownFirewallRule' @($RuleName)) -Level Warning
            continue
        }

        $Rule = $Archive[$RuleName]

        # Use the key as Name if no explicit Name property
        $Name = if ($Rule.ContainsKey('Name') -and $Rule.Name) { $Rule.Name } else { $RuleName }

        # Resolve variable in LocalPort
        $LocalPort = $Rule.LocalPort
        if ($LocalPort -is [string] -and $Variables.ContainsKey($LocalPort)) {
            $LocalPort = $Variables[$LocalPort]
        }

        $Enabled = switch ($Rule.Enabled) {
            $true { 'True' }
            $false { 'False' }
            default { $Rule.Enabled }
        }

        $Resolved = @{
            RuleKey     = $RuleName
            Name        = $Name
            DisplayName = $Rule.DisplayName
            Enabled     = $Enabled
            Profile     = $Rule.Profile
            Direction   = $Rule.Direction
            Action      = $Rule.Action
            Protocol    = $Rule.Protocol
            LocalPort   = $LocalPort
        }

        $Rules += $Resolved
    }

    return $Rules
}


function New-ResolvedFirewallRules {
    <#
    .SYNOPSIS
        Creates firewall rules from an array of resolved rule objects.
    #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Rules,

        [switch]$WhatIf
    )

    foreach ($Rule in $Rules) {
        if ($WhatIf) {
            Write-Step -Section 'Firewall' -Message (Get-I18n 'WhatIfCreateFirewall' @($Rule.DisplayName, $Rule.Direction, $Rule.Action, $Rule.Protocol, $Rule.LocalPort)) -Level Info
            continue
        }

        # Check if rule already exists
        $Existing = Get-NetFirewallRule -Name $Rule.Name -ErrorAction SilentlyContinue

        if ($Existing) {
            Write-Step -Section 'Firewall' -Message (Get-I18n 'FirewallAlreadyExists' @($Rule.DisplayName)) -Level Skip
            continue
        }

        $Enabled = switch ($Rule.Enabled) {
            $true { 'True' }
            $false { 'False' }
            default { $Rule.Enabled }
        }

        try {
            New-NetFirewallRule `
                -Name        $Rule.Name `
                -DisplayName $Rule.DisplayName `
                -Enabled     $Enabled `
                -Profile     $Rule.Profile `
                -Direction   $Rule.Direction `
                -Action      $Rule.Action `
                -Protocol    $Rule.Protocol `
                -LocalPort   $Rule.LocalPort | Out-Null

            Write-Step -Section 'Firewall' -Message (Get-I18n 'FirewallCreated' @($Rule.DisplayName)) -Level Success
        }
        catch {
            Write-Step -Section 'Firewall' -Message (Get-I18n 'FirewallFailed' @($Rule.DisplayName, $_)) -Level Error
        }
    }
}


function Remove-ResolvedFirewallRules {
    <# .SYNOPSIS Removes firewall rules identified by resolved rule objects. #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Rules,
        [switch]$WhatIf
    )

    foreach ($Rule in $Rules) {
        if ($WhatIf) {
            Write-Step -Section 'Firewall' -Message (Get-I18n 'WhatIfRemoveFirewall' @($Rule.DisplayName)) -Level Info
            continue
        }

        try {
            $Existing = Get-NetFirewallRule -Name $Rule.Name -ErrorAction SilentlyContinue
            if (-not $Existing) {
                Write-Step -Section 'Firewall' -Message (Get-I18n 'FirewallNotFound' @($Rule.DisplayName)) -Level Skip
                continue
            }
            $Existing | Remove-NetFirewallRule -ErrorAction Stop
            Write-Step -Section 'Firewall' -Message (Get-I18n 'FirewallRemoved' @($Rule.DisplayName)) -Level Success
        }
        catch {
            Write-Step -Section 'Firewall' -Message (Get-I18n 'FirewallRemoveFailed' @($Rule.DisplayName, $_)) -Level Error
        }
    }
}

Export-ModuleMember -Function `
    Resolve-FirewallRules, `
    New-ResolvedFirewallRules, `
    Remove-ResolvedFirewallRules
