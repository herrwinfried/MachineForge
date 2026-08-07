# registry.psm1
# Resolves registry entry names from the archive and applies them, separating user-level from admin-level.

function Resolve-RegistryEntries {
    <#
    .SYNOPSIS
        Takes a list of registry entry names and the archive, returns resolved entry objects
        split into user-level and admin-level groups.
    #>
    param (
        [Parameter(Mandatory)]
        [string[]]$Names,

        [Parameter(Mandatory)]
        [hashtable]$Archive
    )

    $UserEntries  = @()
    $AdminEntries = @()

    foreach ($Name in $Names) {
        if (-not $Archive.ContainsKey($Name)) {
            Write-Step -Section 'Registry' -Message (Get-I18n 'UnknownRegistryEntry' @($Name)) -Level Warning
            continue
        }

        $Entry = $Archive[$Name]

        # Determine privilege requirement from path
        $NeedsAdmin = $false
        if ($Entry.ContainsKey('RequiresAdministrator')) {
            $NeedsAdmin = $Entry.RequiresAdministrator
        }
        else {
            switch -Wildcard ($Entry.Path.ToUpper()) {
                'HKLM:\*'                { $NeedsAdmin = $true }
                'HKU:\*'                 { $NeedsAdmin = $true }
                'HKCC:\*'                { $NeedsAdmin = $true }
                'HKCR:\*'                { $NeedsAdmin = $true }
                '*\SOFTWARE\POLICIES\*'  { $NeedsAdmin = $true }
            }
        }

        # Attach metadata
        $Resolved = @{
            EntryName = $Name
            Path      = $Entry.Path
            Name      = $Entry.Name
            Value     = $Entry.Value
        }
        if ($Entry.ContainsKey('Type')) {
            $Resolved.Type = $Entry.Type
        }

        if ($NeedsAdmin) { $AdminEntries += $Resolved }
        else             { $UserEntries  += $Resolved }
    }

    return @{
        User  = $UserEntries
        Admin = $AdminEntries
    }
}


function Set-RegistryEntries {
    <#
    .SYNOPSIS
        Applies an array of resolved registry entries.
    #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Entries,

        [switch]$WhatIf
    )

    foreach ($Entry in $Entries) {
        if ($WhatIf) {
            Write-Step -Section 'Registry' -Message (Get-I18n 'WhatIfSetRegistry' @($Entry.EntryName, $Entry.Path, $Entry.Name, $Entry.Value)) -Level Info
            continue
        }

        try {
            if (-not (Test-Path -LiteralPath $Entry.Path)) {
                New-Item -Path $Entry.Path -Force | Out-Null
            }

            $Params = @{
                Path  = $Entry.Path
                Name  = $Entry.Name
                Value = $Entry.Value
            }

            if ($Entry.ContainsKey('Type')) {
                $Params.Type = $Entry.Type
            }

            Set-ItemProperty @Params
            Write-Step -Section 'Registry' -Message $Entry.EntryName -Level Success
        }
        catch {
            Write-Step -Section 'Registry' -Message (Get-I18n 'RegistrySetFailed' @($Entry.EntryName, $_)) -Level Error
        }
    }
}


Export-ModuleMember -Function `
    Resolve-RegistryEntries, `
    Set-RegistryEntries