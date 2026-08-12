# feature.psm1
# Enables or disables Windows optional features. All operations require admin.

function Enable-ResolvedFeatures {
    <#
    .SYNOPSIS
        Enables a list of Windows optional features.
    #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Features,

        [switch]$WhatIf
    )

    if (-not $WhatIf -and $Features.Count -gt 0) {
        Initialize-DismModule
    }

    foreach ($Feature in $Features) {
        if ($WhatIf) {
            Write-Step -Section 'Features' -Message (Get-I18n 'WhatIfEnableFeature' @($Feature)) -Level Info
            continue
        }

        try {
            $State = Get-WindowsOptionalFeature -Online -FeatureName $Feature -ErrorAction SilentlyContinue

            if ($null -eq $State) {
                Write-Step -Section 'Features' -Message (Get-I18n 'FeatureNotAvailable' @($Feature)) -Level Warning
                continue
            }

            if ($State.State -eq 'Enabled') {
                Write-Step -Section 'Features' -Message (Get-I18n 'FeatureAlreadyEnabled' @($Feature)) -Level Skip
                continue
            }

            Enable-WindowsOptionalFeature -Online -FeatureName $Feature -All -NoRestart -ErrorAction Stop | Out-Null
            Write-Step -Section 'Features' -Message (Get-I18n 'FeatureEnabled' @($Feature)) -Level Success
        }
        catch {
            Write-Step -Section 'Features' -Message (Get-I18n 'FeatureFailed' @($Feature, $_)) -Level Error
        }
    }
}

function Install-WindowsCapabilities {
    <#
    .SYNOPSIS
        Installs a list of Windows capabilities, such as OpenSSH.Client.
    #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Capabilities,

        [switch]$WhatIf
    )

    if (-not $WhatIf -and $Capabilities.Count -gt 0) {
        Initialize-DismModule
    }

    foreach ($CapabilityName in $Capabilities) {
        if ($WhatIf) {
            Write-Step -Section 'Capabilities' -Message (Get-I18n 'WhatIfInstallCapability' @($CapabilityName)) -Level Info
            continue
        }

        try {
            $Capability = Get-WindowsCapability -Online -Name $CapabilityName -ErrorAction Stop

            if ($Capability.State -eq 'Installed') {
                Write-Step -Section 'Capabilities' -Message (Get-I18n 'CapabilityAlreadyInstalled' @($CapabilityName)) -Level Skip
                continue
            }

            Add-WindowsCapability -Online -Name $CapabilityName -ErrorAction Stop | Out-Null
            Write-Step -Section 'Capabilities' -Message (Get-I18n 'CapabilityInstalled' @($CapabilityName)) -Level Success
        }
        catch {
            Write-Step -Section 'Capabilities' -Message (Get-I18n 'CapabilityFailed' @($CapabilityName, $_)) -Level Error
        }
    }
}

function Disable-ResolvedFeatures {
    <# .SYNOPSIS Disables a list of Windows optional features. #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Features,
        [switch]$WhatIf
    )

    if (-not $WhatIf -and $Features.Count -gt 0) {
        Initialize-DismModule
    }

    foreach ($Feature in $Features) {
        if ($WhatIf) {
            Write-Step -Section 'Features' -Message (Get-I18n 'WhatIfDisableFeature' @($Feature)) -Level Info
            continue
        }

        try {
            $State = Get-WindowsOptionalFeature -Online -FeatureName $Feature -ErrorAction Stop
            if ($State.State -ne 'Enabled') {
                Write-Step -Section 'Features' -Message (Get-I18n 'FeatureAlreadyDisabled' @($Feature)) -Level Skip
                continue
            }
            Disable-WindowsOptionalFeature -Online -FeatureName $Feature -NoRestart -ErrorAction Stop | Out-Null
            Write-Step -Section 'Features' -Message (Get-I18n 'FeatureDisabled' @($Feature)) -Level Success
        }
        catch {
            Write-Step -Section 'Features' -Message (Get-I18n 'FeatureDisableFailed' @($Feature, $_)) -Level Error
        }
    }
}

function Remove-WindowsCapabilities {
    <# .SYNOPSIS Removes a list of installed Windows capabilities. #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Capabilities,
        [switch]$WhatIf
    )

    if (-not $WhatIf -and $Capabilities.Count -gt 0) {
        Initialize-DismModule
    }

    foreach ($CapabilityName in $Capabilities) {
        if ($WhatIf) {
            Write-Step -Section 'Capabilities' -Message (Get-I18n 'WhatIfRemoveCapability' @($CapabilityName)) -Level Info
            continue
        }

        try {
            $Capability = Get-WindowsCapability -Online -Name $CapabilityName -ErrorAction Stop
            if ($Capability.State -ne 'Installed') {
                Write-Step -Section 'Capabilities' -Message (Get-I18n 'CapabilityNotInstalled' @($CapabilityName)) -Level Skip
                continue
            }
            Remove-WindowsCapability -Online -Name $CapabilityName -ErrorAction Stop | Out-Null
            Write-Step -Section 'Capabilities' -Message (Get-I18n 'CapabilityRemoved' @($CapabilityName)) -Level Success
        }
        catch {
            Write-Step -Section 'Capabilities' -Message (Get-I18n 'CapabilityRemoveFailed' @($CapabilityName, $_)) -Level Error
        }
    }
}

Export-ModuleMember -Function `
    Enable-ResolvedFeatures, `
    Install-WindowsCapabilities, `
    Disable-ResolvedFeatures, `
    Remove-WindowsCapabilities
