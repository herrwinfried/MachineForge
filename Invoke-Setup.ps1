<#
.SYNOPSIS
    Windows Configuration Automation — Main Entry Point.
    Detects hardware, matches a profile, resolves templates, and applies configuration.

.DESCRIPTION
    This script orchestrates the entire setup process:
    1. Initializes localization (English / Turkish / auto-detected)
    2. Initializes file logging (logs/<timestamp>.log)
    3. Gathers system information (OS, hardware)
    4. Matches/Selects a profile from the Profile directory
    5. Loads and merges templates in order
    6. Applies user-level operations (HKCU registry, winget packages, npm global packages, exec tasks)
    7. Batches all admin-level operations into a single elevated session
       (HKLM/Policy registry, firewall rules, features, apps, chocolatey packages, admin commands)

.PARAMETER ProfileName
    Optional. Name of the profile to use directly without interactive prompt.

.PARAMETER Language
    Optional. Language code ('en-US', 'tr-TR'). Defaults to system culture auto-detection.

.PARAMETER SkipAdmin
    When specified, skips all operations that require administrator privileges.

.EXAMPLE
    .\Invoke-Setup.ps1
    .\Invoke-Setup.ps1 -Language tr-TR
    .\Invoke-Setup.ps1 -ProfileName asuswindows11 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    [string]$ProfileName,
    [Alias('Lang')]
    [string]$Language,
    [switch]$SkipAdmin
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Import modules ──────────────────────────────────────────────────────────
$ModuleDir = Join-Path $PSScriptRoot 'modules'
$LangDir = Join-Path $PSScriptRoot 'lang'

Import-Module (Join-Path $ModuleDir 'logger.psm1')       -Force -DisableNameChecking
Import-Module (Join-Path $ModuleDir 'global.psm1')       -Force -DisableNameChecking
Import-Module (Join-Path $ModuleDir 'i18n.psm1')         -Force -DisableNameChecking
Import-Module (Join-Path $ModuleDir 'profile.psm1')      -Force -DisableNameChecking
Import-Module (Join-Path $ModuleDir 'registry.psm1')     -Force -DisableNameChecking
Import-Module (Join-Path $ModuleDir 'package.psm1')      -Force -DisableNameChecking
Import-Module (Join-Path $ModuleDir 'firewall.psm1')     -Force -DisableNameChecking
Import-Module (Join-Path $ModuleDir 'feature.psm1')      -Force -DisableNameChecking
Import-Module (Join-Path $ModuleDir 'WindowsApps.psm1')  -Force -DisableNameChecking
Import-Module (Join-Path $ModuleDir 'execution.psm1')    -Force -DisableNameChecking

# ── Initialize logger ───────────────────────────────────────────────────────
Initialize-Logger -ScriptDir $PSScriptRoot
Write-Log -Level 'INFO' -Section 'Setup' -Message 'Invoke-Setup.ps1 started'

# ── Initialize localization ─────────────────────────────────────────────────
Initialize-Localization -Language $Language -LangDir $LangDir

# ── Load archives ───────────────────────────────────────────────────────────
$RegistryArchive = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'registry.psd1')
$PackageArchive = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'package.psd1')
$FirewallArchive = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'firewall.psd1')

# ── Gather system info & profile selection loop ──────────────────────────────
$SystemInfo = Get-SystemInfo -ScriptDir $PSScriptRoot
$Version = "1.0.0"

$MatchedProfile = $null
while ($true) {
    Clear-Host

    Write-Host ""
    Write-Host "███╗   ███╗ █████╗  ██████╗██╗  ██╗██╗███╗   ██╗███████╗" -ForegroundColor Blue
    Write-Host "████╗ ████║██╔══██╗██╔════╝██║  ██║██║████╗  ██║██╔════╝" -ForegroundColor Blue
    Write-Host "██╔████╔██║███████║██║     ███████║██║██╔██╗ ██║█████╗  " -ForegroundColor Blue
    Write-Host "██║╚██╔╝██║██╔══██║██║     ██╔══██║██║██║╚██╗██║██╔══╝  " -ForegroundColor Blue
    Write-Host "██║ ╚═╝ ██║██║  ██║╚██████╗██║  ██║██║██║ ╚████║███████╗" -ForegroundColor Blue
    Write-Host "╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝" -ForegroundColor Blue

    Write-Host ""
    Write-Host "            ███████╗ ██████╗ ██████╗  ██████╗ ███████╗" -ForegroundColor Blue
    Write-Host "            ██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝" -ForegroundColor Blue
    Write-Host "            █████╗  ██║   ██║██████╔╝██║  ███╗█████╗  " -ForegroundColor Blue
    Write-Host "            ██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝  " -ForegroundColor Blue
    Write-Host "            ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗" -ForegroundColor Blue
    Write-Host "            ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝" -ForegroundColor Blue

    Write-Host ""
    Write-Host "                        MachineForge" -ForegroundColor White -NoNewline
    Write-Host " - " -ForegroundColor Blue -NoNewline
    Write-Host "v$($SystemInfo.ScriptVersion)" -ForegroundColor Red
    Write-Host ""
    Start-Sleep -Milliseconds 1100
    Write-Banner (Get-I18n 'BannerSystemDetection')

    Write-Step -Section 'System' -Message (Get-I18n 'SystemOS'     @($SystemInfo.OsName))     -Level Info
    Write-Step -Section 'System' -Message (Get-I18n 'SystemBuild'  @($SystemInfo.OsBuild))    -Level Info
    Write-Step -Section 'System' -Message (Get-I18n 'SystemVendor' @($SystemInfo.BoardVendor)) -Level Info
    Write-Step -Section 'System' -Message (Get-I18n 'SystemModel'  @($SystemInfo.Model))      -Level Info
    Start-Sleep -Milliseconds 1000
    # ── Match / Select profile ──────────────────────────────────────────────────
    Write-Banner (Get-I18n 'BannerProfileSelection')
    $ProfileDir = Join-Path $PSScriptRoot 'Profile'
    $MatchedProfile = Find-MatchingProfile -ProfileDir $ProfileDir -SystemInfo $SystemInfo -ProfileName $ProfileName -LangDir $LangDir
    Start-Sleep -Milliseconds 1000

    if ($MatchedProfile -eq 'RESTART') {
        Clear-Host
        continue
    }

    break
}

if ($MatchedProfile -eq 'EXIT') {
    Write-Log -Level 'INFO' -Section 'Setup' -Message 'User chose to exit.'
    exit 0
}

if ($null -eq $MatchedProfile) {
    Write-Host ""
    Write-Step -Section 'Setup' -Message (Get-I18n 'NoProfileSelected') -Level Error
    exit 1
}

# ── Merge configuration ────────────────────────────────────────────────────
Write-Banner (Get-I18n 'BannerConfigMerge')

$TemplateDir = Join-Path $PSScriptRoot 'Templates'

$Config = Merge-ProfileConfiguration `
    -Profile $MatchedProfile `
    -TemplateDir $TemplateDir `
    -RegistryArchive $RegistryArchive `
    -PackageArchive $PackageArchive `
    -FirewallArchive $FirewallArchive

# Show summary
Write-Host ""
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryRegistry'     @($Config.Registry.Count))    -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryPackages'     @($Config.Packages.Count))    -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryUninstallPackages' @($Config.UninstallPackages.Count)) -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryNpm'          @($Config.Npm.Count))         -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryUninstallNpm' @($Config.UninstallNpm.Count)) -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryFirewall'     @($Config.Firewall.Count))    -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryRemoveFirewall' @($Config.RemoveFirewall.Count)) -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryFeatures'     @($Config.Features.Count))    -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryDisableFeatures' @($Config.DisableFeatures.Count)) -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryCapabilities' @($Config.WindowsCapabilities.Count)) -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryRemoveCapabilities' @($Config.RemoveWindowsCapabilities.Count)) -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryRemoveApps'   @($Config.RemoveApps.Count))  -Level Info
Write-Step -Section 'Summary' -Message (Get-I18n 'SummaryComputerName' @($(if ($Config.ComputerName) { $Config.ComputerName } else { '(unchanged)' }))) -Level Info

# ── Resolve all references ──────────────────────────────────────────────────
$UseWhatIf = $WhatIfPreference

# Registry
$ResolvedRegistry = @{ User = @(); Admin = @() }
if ($Config.Registry.Count -gt 0) {
    $ResolvedRegistry = Resolve-RegistryEntries -Names $Config.Registry -Archive $RegistryArchive
}

# Packages (winget / choco / npm via archive)
$ResolvedPackages = @{ User = @(); Admin = @() }
if ($Config.Packages.Count -gt 0) {
    $ResolvedPackages = Resolve-Packages -Names $Config.Packages -Archive $PackageArchive
}

# Packages to uninstall (winget user-level; Chocolatey admin-level)
$ResolvedUninstallPackages = @{ User = @(); Admin = @() }
if ($Config.UninstallPackages.Count -gt 0) {
    $ResolvedUninstallPackages = Resolve-Packages -Names $Config.UninstallPackages -Archive $PackageArchive
}

# Firewall
$ResolvedFirewall = @()
if ($Config.Firewall.Count -gt 0) {
    $ResolvedFirewall = Resolve-FirewallRules -Names $Config.Firewall -Archive $FirewallArchive -Variables $Config.Variables
}

$ResolvedFirewallToRemove = @()
if ($Config.RemoveFirewall.Count -gt 0) {
    $ResolvedFirewallToRemove = Resolve-FirewallRules -Names $Config.RemoveFirewall -Archive $FirewallArchive -Variables $Config.Variables
}

# ════════════════════════════════════════════════════════════════════════════
# PHASE 1: User-level operations (no elevation needed)
# ════════════════════════════════════════════════════════════════════════════
Write-Banner (Get-I18n 'BannerPhase1')

# User-level registry (HKCU)
if ($ResolvedRegistry.User.Count -gt 0) {
    Write-Step -Section 'Registry' -Message (Get-I18n 'ApplyingUserRegistry' @($ResolvedRegistry.User.Count)) -Level Info
    Set-RegistryEntries -Entries $ResolvedRegistry.User -WhatIf:$UseWhatIf
}
else {
    Write-Step -Section 'Registry' -Message (Get-I18n 'NoUserRegistry') -Level Skip
}

# Winget packages (user-level)
if ($ResolvedPackages.User.Count -gt 0) {
    Write-Step -Section 'Packages' -Message (Get-I18n 'InstallingPackages' @($ResolvedPackages.User.Count, 'winget')) -Level Info
    Install-ResolvedPackages -Packages $ResolvedPackages.User -WhatIf:$UseWhatIf
}
else {
    Write-Step -Section 'Packages' -Message (Get-I18n 'NoUserPackages') -Level Skip
}

if ($ResolvedUninstallPackages.User.Count -gt 0) {
    Uninstall-ResolvedPackages -Packages $ResolvedUninstallPackages.User -WhatIf:$UseWhatIf
}

# NPM global packages (user-level)
if ($Config.Npm.Count -gt 0) {
    Install-NpmPackages -NpmPackages $Config.Npm -WhatIf:$UseWhatIf
}

if ($Config.UninstallNpm.Count -gt 0) {
    Uninstall-NpmPackages -NpmPackages $Config.UninstallNpm -WhatIf:$UseWhatIf
}
else {
    Write-Step -Section 'Packages' -Message (Get-I18n 'NoNpmPackages') -Level Skip
}

# Exec tasks (user-level ones run immediately; admin ones are deferred)
$DeferredAdminCommands = @()
if ($Config.Exec.Mkdir.Count -gt 0 -or $Config.Exec.Copy.Count -gt 0 -or
    $Config.Exec.DownloadFile.Count -gt 0 -or $Config.Exec.AppInstaller.Count -gt 0 -or
    $Config.Exec.Command.Count -gt 0) {
    Write-Step -Section 'Exec' -Message (Get-I18n 'RunningExecTasks') -Level Info
    $DeferredAdminCommands = Invoke-ExecTasks -ExecConfig $Config.Exec -SystemInfo $SystemInfo -WhatIf:$UseWhatIf
}
else {
    Write-Step -Section 'Exec' -Message (Get-I18n 'NoExecTasks') -Level Skip
}

# ════════════════════════════════════════════════════════════════════════════
# PHASE 2: Admin-level operations (single elevation)
# ════════════════════════════════════════════════════════════════════════════

$HasAdminWork = (
    $ResolvedRegistry.Admin.Count -gt 0 -or
    $ResolvedPackages.Admin.Count -gt 0 -or
    $ResolvedUninstallPackages.Admin.Count -gt 0 -or
    $ResolvedFirewall.Count -gt 0 -or
    $ResolvedFirewallToRemove.Count -gt 0 -or
    $Config.Features.Count -gt 0 -or
    $Config.DisableFeatures.Count -gt 0 -or
    $Config.WindowsCapabilities.Count -gt 0 -or
    $Config.RemoveWindowsCapabilities.Count -gt 0 -or
    $Config.RemoveApps.Count -gt 0 -or
    $DeferredAdminCommands.Count -gt 0 -or
    ($Config.ComputerName -and $env:COMPUTERNAME -ne $Config.ComputerName)
)

if (-not $HasAdminWork) {
    Write-Banner (Get-I18n 'BannerComplete')
    Write-Step -Section 'Setup' -Message (Get-I18n 'NoAdminWorkNeeded') -Level Success
    exit 0
}

if ($SkipAdmin) {
    Write-Banner (Get-I18n 'BannerSkippedAdmin')
    Write-Step -Section 'Setup' -Message (Get-I18n 'AdminSkipped') -Level Warning
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedAdminRegistry' @($ResolvedRegistry.Admin.Count)) -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedAdminPackages' @($ResolvedPackages.Admin.Count)) -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedAdminUninstallPackages' @($ResolvedUninstallPackages.Admin.Count)) -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedFirewallRules' @($ResolvedFirewall.Count))      -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedRemoveFirewallRules' @($ResolvedFirewallToRemove.Count)) -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedFeatures'      @($Config.Features.Count))      -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedDisableFeatures' @($Config.DisableFeatures.Count)) -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedCapabilities'  @($Config.WindowsCapabilities.Count)) -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedRemoveCapabilities' @($Config.RemoveWindowsCapabilities.Count)) -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedRemoveApps'    @($Config.RemoveApps.Count))    -Level Info
    Write-Step -Section 'Setup' -Message (Get-I18n 'SkippedDeferredCmds'  @($DeferredAdminCommands.Count))-Level Info
    exit 0
}

Write-Banner (Get-I18n 'BannerPhase2')

if (Test-IsAdministrator) {
    # Already elevated — run directly
    Write-Step -Section 'Admin' -Message (Get-I18n 'RunningElevated') -Level Info

    # Admin registry (HKLM, etc.)
    if ($ResolvedRegistry.Admin.Count -gt 0) {
        Write-Step -Section 'Registry' -Message (Get-I18n 'ApplyingAdminRegistry' @($ResolvedRegistry.Admin.Count)) -Level Info
        Set-RegistryEntries -Entries $ResolvedRegistry.Admin -WhatIf:$UseWhatIf
    }

    # Chocolatey packages
    if ($ResolvedPackages.Admin.Count -gt 0) {
        Write-Step -Section 'Packages' -Message (Get-I18n 'InstallingPackages' @($ResolvedPackages.Admin.Count, 'chocolatey')) -Level Info
        Install-ResolvedPackages -Packages $ResolvedPackages.Admin -WhatIf:$UseWhatIf
    }

    if ($ResolvedUninstallPackages.Admin.Count -gt 0) {
        Uninstall-ResolvedPackages -Packages $ResolvedUninstallPackages.Admin -WhatIf:$UseWhatIf
    }

    # Firewall rules
    if ($ResolvedFirewall.Count -gt 0) {
        Write-Step -Section 'Firewall' -Message (Get-I18n 'CreatingFirewallRules' @($ResolvedFirewall.Count)) -Level Info
        New-ResolvedFirewallRules -Rules $ResolvedFirewall -WhatIf:$UseWhatIf
    }

    if ($ResolvedFirewallToRemove.Count -gt 0) {
        Remove-ResolvedFirewallRules -Rules $ResolvedFirewallToRemove -WhatIf:$UseWhatIf
    }

    # Windows features
    if ($Config.Features.Count -gt 0) {
        Write-Step -Section 'Features' -Message (Get-I18n 'EnablingFeatures' @($Config.Features.Count)) -Level Info
        Enable-ResolvedFeatures -Features $Config.Features -WhatIf:$UseWhatIf
    }

    if ($Config.DisableFeatures.Count -gt 0) {
        Disable-ResolvedFeatures -Features $Config.DisableFeatures -WhatIf:$UseWhatIf
    }

    # Windows capabilities (for example OpenSSH)
    if ($Config.WindowsCapabilities.Count -gt 0) {
        Write-Step -Section 'Capabilities' -Message (Get-I18n 'InstallingWindowsCapabilities' @($Config.WindowsCapabilities.Count)) -Level Info
        Install-WindowsCapabilities -Capabilities $Config.WindowsCapabilities -WhatIf:$UseWhatIf
    }

    if ($Config.RemoveWindowsCapabilities.Count -gt 0) {
        Remove-WindowsCapabilities -Capabilities $Config.RemoveWindowsCapabilities -WhatIf:$UseWhatIf
    }

    # Remove Windows apps (requires admin for system/provisioned apps)
    if ($Config.RemoveApps.Count -gt 0) {
        Write-Step -Section 'Apps' -Message (Get-I18n 'RemovingApps' @($Config.RemoveApps.Count)) -Level Info
        Remove-ResolvedWindowsApps -Apps $Config.RemoveApps -UserName $SystemInfo.UserName -WhatIf:$UseWhatIf
    }

    # Deferred admin commands
    if ($DeferredAdminCommands.Count -gt 0) {
        Write-Step -Section 'Exec' -Message (Get-I18n 'RunningExecTasks') -Level Info
        Invoke-DeferredAdminCommands -Commands $DeferredAdminCommands -WhatIf:$UseWhatIf
    }

    # Computer name
    if ($Config.ComputerName -and $env:COMPUTERNAME -ne $Config.ComputerName) {
        if ($UseWhatIf) {
            Write-Step -Section 'System' -Message (Get-I18n 'WhatIfRenameComputer' @($Config.ComputerName)) -Level Info
        }
        else {
            try {
                Rename-Computer -NewName $Config.ComputerName -Force
                Write-Step -Section 'System' -Message (Get-I18n 'ComputerRenamed' @($Config.ComputerName)) -Level Success
            }
            catch {
                Write-Step -Section 'System' -Message (Get-I18n 'RenameFailed' @($_)) -Level Error
            }
        }
    }
}
else {
    # Not elevated — serialize admin work and launch a single elevated session
    Write-Step -Section 'Admin' -Message (Get-I18n 'ElevationRequired') -Level Info

    $AdminScriptPath = Join-Path $env:TEMP 'Invoke-Setup-Admin.ps1'
    $LogPath = Get-LogPath

    $CurrentLang = Get-CurrentLanguage

    # Build the elevated script
    $AdminScript = @"
# Auto-generated elevated script — runs all admin-level operations.
Set-StrictMode -Version Latest
`$ErrorActionPreference = 'Stop'

# Import modules
`$ModuleDir = '$($ModuleDir -replace "'", "''")'
`$LangDir   = '$($LangDir -replace "'", "''")'

Import-Module (Join-Path `$ModuleDir 'logger.psm1')       -Force -DisableNameChecking
Import-Module (Join-Path `$ModuleDir 'global.psm1')       -Force -DisableNameChecking
Import-Module (Join-Path `$ModuleDir 'i18n.psm1')         -Force -DisableNameChecking
Import-Module (Join-Path `$ModuleDir 'registry.psm1')     -Force -DisableNameChecking
Import-Module (Join-Path `$ModuleDir 'package.psm1')      -Force -DisableNameChecking
Import-Module (Join-Path `$ModuleDir 'firewall.psm1')     -Force -DisableNameChecking
Import-Module (Join-Path `$ModuleDir 'feature.psm1')      -Force -DisableNameChecking
Import-Module (Join-Path `$ModuleDir 'WindowsApps.psm1')  -Force -DisableNameChecking
Import-Module (Join-Path `$ModuleDir 'execution.psm1')    -Force -DisableNameChecking

# Re-use the same log file opened by the parent session. The logger keeps this
# state in its own module scope, so it must be set through its public function.
Set-LogPath -Path '$($LogPath -replace "'", "''")'

Initialize-Localization -Language '$CurrentLang' -LangDir `$LangDir

Write-Banner (Get-I18n 'BannerElevatedSession')

"@

    # Admin registry entries
    if ($ResolvedRegistry.Admin.Count -gt 0) {
        $AdminScript += "`n# Admin registry entries`n"
        $AdminScript += "`$AdminRegistryEntries = @(`n"
        foreach ($Entry in $ResolvedRegistry.Admin) {
            $AdminScript += "    @{`n"
            $AdminScript += "        EntryName = '$($Entry.EntryName)'`n"
            $AdminScript += "        Path      = '$($Entry.Path)'`n"
            $AdminScript += "        Name      = '$($Entry.Name)'`n"
            $AdminScript += "        Value     = $($Entry.Value)`n"
            if ($Entry.ContainsKey('Type')) {
                $AdminScript += "        Type      = '$($Entry.Type)'`n"
            }
            $AdminScript += "    }`n"
        }
        $AdminScript += ")`n"
        $AdminScript += "Write-Step -Section 'Registry' -Message (Get-I18n 'ApplyingAdminRegistry' @(`$AdminRegistryEntries.Count)) -Level Info`n"
        $AdminScript += "Set-RegistryEntries -Entries `$AdminRegistryEntries$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Chocolatey packages
    if ($ResolvedPackages.Admin.Count -gt 0) {
        $AdminScript += "`n# Chocolatey packages`n"
        $AdminScript += "`$AdminPackages = @(`n"
        foreach ($Pkg in $ResolvedPackages.Admin) {
            $AdminScript += "    @{`n"
            $AdminScript += "        PackageName    = '$($Pkg.PackageName)'`n"
            $AdminScript += "        Id             = '$($Pkg.Id)'`n"
            $AdminScript += "        PackageManager = '$($Pkg.PackageManager)'`n"
            $AdminScript += "        Interactive    = `$$($Pkg.Interactive)`n"
            $AdminScript += "    }`n"
        }
        $AdminScript += ")`n"
        $AdminScript += "Write-Step -Section 'Packages' -Message (Get-I18n 'InstallingPackages' @(`$AdminPackages.Count, 'chocolatey')) -Level Info`n"
        $AdminScript += "Install-ResolvedPackages -Packages `$AdminPackages$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Chocolatey packages to uninstall
    if ($ResolvedUninstallPackages.Admin.Count -gt 0) {
        $AdminScript += "`n# Chocolatey packages to uninstall`n"
        $AdminScript += "`$AdminPackagesToUninstall = @(`n"
        foreach ($Pkg in $ResolvedUninstallPackages.Admin) {
            $AdminScript += "    @{`n"
            $AdminScript += "        PackageName    = '$($Pkg.PackageName)'`n"
            $AdminScript += "        Id             = '$($Pkg.Id)'`n"
            $AdminScript += "        PackageManager = '$($Pkg.PackageManager)'`n"
            $AdminScript += "        Interactive    = `$$($Pkg.Interactive)`n"
            $AdminScript += "    }`n"
        }
        $AdminScript += ")`n"
        $AdminScript += "Uninstall-ResolvedPackages -Packages `$AdminPackagesToUninstall$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Firewall rules
    if ($ResolvedFirewall.Count -gt 0) {
        $AdminScript += "`n# Firewall rules`n"
        $AdminScript += "`$FirewallRules = @(`n"
        foreach ($Rule in $ResolvedFirewall) {
            $AdminScript += "    @{`n"
            $AdminScript += "        RuleKey     = '$($Rule.RuleKey)'`n"
            $AdminScript += "        Name        = '$($Rule.Name)'`n"
            $AdminScript += "        DisplayName = '$($Rule.DisplayName)'`n"
            $AdminScript += "        Enabled     = `$$($Rule.Enabled)`n"
            $ProfileStr = ($Rule.Profile | ForEach-Object { "'$_'" }) -join ', '
            $AdminScript += "        Profile     = @($ProfileStr)`n"
            $AdminScript += "        Direction   = '$($Rule.Direction)'`n"
            $AdminScript += "        Action      = '$($Rule.Action)'`n"
            $AdminScript += "        Protocol    = '$($Rule.Protocol)'`n"
            $AdminScript += "        LocalPort   = $($Rule.LocalPort)`n"
            $AdminScript += "    }`n"
        }
        $AdminScript += ")`n"
        $AdminScript += "Write-Step -Section 'Firewall' -Message (Get-I18n 'CreatingFirewallRules' @(`$FirewallRules.Count)) -Level Info`n"
        $AdminScript += "New-ResolvedFirewallRules -Rules `$FirewallRules$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Firewall rules to remove
    if ($ResolvedFirewallToRemove.Count -gt 0) {
        $AdminScript += "`n# Firewall rules to remove`n"
        $AdminScript += "`$FirewallRulesToRemove = @(`n"
        foreach ($Rule in $ResolvedFirewallToRemove) {
            $AdminScript += "    @{`n"
            $AdminScript += "        Name        = '$($Rule.Name)'`n"
            $AdminScript += "        DisplayName = '$($Rule.DisplayName)'`n"
            $AdminScript += "    }`n"
        }
        $AdminScript += ")`n"
        $AdminScript += "Remove-ResolvedFirewallRules -Rules `$FirewallRulesToRemove$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Features
    if ($Config.Features.Count -gt 0) {
        $FeatStr = ($Config.Features | ForEach-Object { "'$_'" }) -join ",`n        "
        $AdminScript += "`n# Windows features`n"
        $AdminScript += "`$Features = @(`n        $FeatStr`n)`n"
        $AdminScript += "Write-Step -Section 'Features' -Message (Get-I18n 'EnablingFeatures' @(`$Features.Count)) -Level Info`n"
        $AdminScript += "Enable-ResolvedFeatures -Features `$Features$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Windows features to disable
    if ($Config.DisableFeatures.Count -gt 0) {
        $DisableFeatureStr = ($Config.DisableFeatures | ForEach-Object { "'$_'" }) -join ",`n        "
        $AdminScript += "`n# Windows features to disable`n"
        $AdminScript += "`$FeaturesToDisable = @(`n        $DisableFeatureStr`n)`n"
        $AdminScript += "Disable-ResolvedFeatures -Features `$FeaturesToDisable$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Windows capabilities
    if ($Config.WindowsCapabilities.Count -gt 0) {
        $CapabilityStr = ($Config.WindowsCapabilities | ForEach-Object { "'$_'" }) -join ",`n        "
        $AdminScript += "`n# Windows capabilities`n"
        $AdminScript += "`$WindowsCapabilities = @(`n        $CapabilityStr`n)`n"
        $AdminScript += "Write-Step -Section 'Capabilities' -Message (Get-I18n 'InstallingWindowsCapabilities' @(`$WindowsCapabilities.Count)) -Level Info`n"
        $AdminScript += "Install-WindowsCapabilities -Capabilities `$WindowsCapabilities$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Windows capabilities to remove
    if ($Config.RemoveWindowsCapabilities.Count -gt 0) {
        $RemoveCapabilityStr = ($Config.RemoveWindowsCapabilities | ForEach-Object { "'$_'" }) -join ",`n        "
        $AdminScript += "`n# Windows capabilities to remove`n"
        $AdminScript += "`$WindowsCapabilitiesToRemove = @(`n        $RemoveCapabilityStr`n)`n"
        $AdminScript += "Remove-WindowsCapabilities -Capabilities `$WindowsCapabilitiesToRemove$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Remove Windows apps
    if ($Config.RemoveApps.Count -gt 0) {
        $AppsStr = ($Config.RemoveApps | ForEach-Object { "'$_'" }) -join ",`n        "
        $AdminScript += "`n# Remove Windows apps`n"
        $AdminScript += "`$RemoveAppsList = @(`n        $AppsStr`n)`n"
        $AdminScript += "Write-Step -Section 'Apps' -Message (Get-I18n 'RemovingApps' @(`$RemoveAppsList.Count)) -Level Info`n"
        $AdminScript += "Remove-ResolvedWindowsApps -Apps `$RemoveAppsList -UserName '$($SystemInfo.UserName)'$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Deferred admin commands
    if ($DeferredAdminCommands.Count -gt 0) {
        $AdminScript += "`n# Deferred admin commands`n"
        $AdminScript += "`$DeferredCommands = @(`n"
        foreach ($Cmd in $DeferredAdminCommands) {
            $AdminScript += "    @{`n"
            $AdminScript += "        Shell                = '$($Cmd.Shell)'`n"
            $AdminScript += "        Command              = '$($Cmd.Command -replace "'", "''")'`n"
            $AdminScript += "        RequiresAdministrator = `$$($Cmd.RequiresAdministrator)`n"
            $AdminScript += "    }`n"
        }
        $AdminScript += ")`n"
        $AdminScript += "Write-Step -Section 'Exec' -Message (Get-I18n 'RunningExecTasks') -Level Info`n"
        $AdminScript += "Invoke-DeferredAdminCommands -Commands `$DeferredCommands$(if ($UseWhatIf) { ' -WhatIf' })`n"
    }

    # Computer name
    if ($Config.ComputerName -and $env:COMPUTERNAME -ne $Config.ComputerName) {
        if ($UseWhatIf) {
            $AdminScript += "`nWrite-Step -Section 'System' -Message (Get-I18n 'WhatIfRenameComputer' @('$($Config.ComputerName)')) -Level Info`n"
        }
        else {
            $AdminScript += @"

# Rename computer
try {
    Rename-Computer -NewName '$($Config.ComputerName)' -Force
    Write-Step -Section 'System' -Message (Get-I18n 'ComputerRenamed' @('$($Config.ComputerName)')) -Level Success
}
catch {
    Write-Step -Section 'System' -Message (Get-I18n 'RenameFailed' @("`$_")) -Level Error
}
"@
        }
    }

    $AdminScript += "`n`nWrite-Banner (Get-I18n 'BannerComplete')`n"
    $AdminScript += "Write-Host (Get-I18n 'PressKeyToClose') -ForegroundColor DarkGray`n"
    $AdminScript += "`$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')`n"

    # Write and launch
    $AdminScript | Out-File -FilePath $AdminScriptPath -Encoding UTF8 -Force

    Write-Step -Section 'Admin' -Message (Get-I18n 'LaunchingElevated') -Level Info

    Start-Process -FilePath 'pwsh.exe' `
        -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $AdminScriptPath `
        -Verb RunAs `
        -Wait

    # Clean up
    Remove-Item -Path $AdminScriptPath -Force -ErrorAction SilentlyContinue
}

# ════════════════════════════════════════════════════════════════════════════
Write-Banner (Get-I18n 'BannerComplete')
Write-Step -Section 'Setup' -Message (Get-I18n 'AllFinished') -Level Success
Write-Log -Level 'INFO' -Section 'Setup' -Message "Finished. Log: $(Get-LogPath)"
