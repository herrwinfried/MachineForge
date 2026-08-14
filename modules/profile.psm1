# profile.psm1
# Handles system detection, profile matching, template loading, and configuration merging.

function Get-SystemInfo {
    <#
    .SYNOPSIS
        Gathers OS and hardware information for the current machine.
    #>
    param (
        [string]$ScriptDir
    )

    $Info = [PSCustomObject]@{
        ScriptDir     = $ScriptDir
        UserName      = $env:USERNAME
        UserHome      = $env:USERPROFILE
        OsName        = $null
        OsBuild       = $null
        BoardVendor   = $null
        Model         = $null
        ScriptVersion = "1.1.0"
    }

    $OS = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $BOARD = Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue
    $PC = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue

    if ($OS) {
        $Info.OsName = $OS.Caption
        $Info.OsBuild = [int]$OS.BuildNumber
    }

    $BoardVendor = if ($BOARD) { $BOARD.Vendor } else { $null }
    if ([string]::IsNullOrWhiteSpace($BoardVendor)) {
        $BaseBoard = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
        $BoardVendor = if ($BaseBoard) { $BaseBoard.Manufacturer } else { $null }
    }
    if ([string]::IsNullOrWhiteSpace($BoardVendor) -and $PC) {
        $BoardVendor = $PC.Manufacturer
    }
    $Info.BoardVendor = $BoardVendor

    $Info.Model = if ($PC) { $PC.Model } else { $null }

    return $Info
}


function Find-MatchingProfile {
    <#
    .SYNOPSIS
        Scans the Profile directory, evaluates system compatibility for each,
        and allows the user to select which profile to apply, change language, or exit.
    #>
    param (
        [Parameter(Mandatory)]
        [string]$ProfileDir,

        [Parameter(Mandatory)]
        [PSCustomObject]$SystemInfo,

        [string]$ProfileName = $null,

        [string]$LangDir = $null
    )

    $ProfileFiles = Get-ChildItem -Path $ProfileDir -Filter '*.psd1' -File

    if ($ProfileFiles.Count -eq 0) {
        Write-Step -Section 'Profile' -Message (Get-I18n 'NoProfilesFound') -Level Error
        return $null
    }

    # Evaluate compatibility for all available profiles
    $EvaluatedProfiles = @()
    $RecommendedIndex = -1

    for ($i = 0; $i -lt $ProfileFiles.Count; $i++) {
        $File = $ProfileFiles[$i]
        $ProfileData = Import-PowerShellDataFile -Path $File.FullName
        $Name = $File.BaseName
        $Matches = $true
        $HardMismatch = $false
        $SoftMismatch = $false
        $Reasons = @()

        # Check OS name — always a hard mismatch
        if ($ProfileData.Name -and $ProfileData.Name.Count -gt 0) {
            if ($SystemInfo.OsName -notin $ProfileData.Name) {
                $Matches = $false
                $HardMismatch = $true
                $Reasons += (Get-I18n 'ReasonOsMismatch' @(($ProfileData.Name -join ', ')))
            }
        }

        # Check minimum build — always a hard mismatch
        if ($null -ne $ProfileData.MinimumBuild) {
            if ($SystemInfo.OsBuild -lt $ProfileData.MinimumBuild) {
                $Matches = $false
                $HardMismatch = $true
                $Reasons += (Get-I18n 'ReasonBuildMinMismatch' @($SystemInfo.OsBuild, $ProfileData.MinimumBuild))
            }
        }

        # Check maximum build — always a hard mismatch
        if ($null -ne $ProfileData.MaximumBuild) {
            if ($SystemInfo.OsBuild -gt $ProfileData.MaximumBuild) {
                $Matches = $false
                $HardMismatch = $true
                $Reasons += (Get-I18n 'ReasonBuildMaxMismatch' @($SystemInfo.OsBuild, $ProfileData.MaximumBuild))
            }
        }

        # Check hardware
        if ($ProfileData.ContainsKey('Hardware')) {
            $Hw = $ProfileData.Hardware

            # Models
            if ($Hw.Models -and $Hw.Models.Count -gt 0) {
                $reqModels = if ($Hw.ContainsKey('RequireModels')) { $Hw.RequireModels } else { $false }
                if ($SystemInfo.Model -notin $Hw.Models) {
                    if ($reqModels) {
                        # Hard mismatch: required model doesn't match → red, non-startable
                        $Matches = $false
                        $HardMismatch = $true
                        $Reasons += (Get-I18n 'ReasonModelMismatch' @(($Hw.Models -join ', ')))
                    }
                    else {
                        # Soft mismatch: optional model doesn't match → yellow, still startable
                        $SoftMismatch = $true
                        $Reasons += (Get-I18n 'ReasonModelOptional' @(($Hw.Models -join ', ')))
                    }
                }
            }

            # Board vendors
            if ($Hw.BoardVendors -and $Hw.BoardVendors.Count -gt 0) {
                $reqVendors = if ($Hw.ContainsKey('RequireBoardVendors')) { $Hw.RequireBoardVendors } else { $false }
                if ($SystemInfo.BoardVendor -notin $Hw.BoardVendors) {
                    if ($reqVendors) {
                        # Hard mismatch: required vendor doesn't match → red, non-startable
                        $Matches = $false
                        $HardMismatch = $true
                        $Reasons += (Get-I18n 'ReasonVendorMismatch' @(($Hw.BoardVendors -join ', ')))
                    }
                    else {
                        # Soft mismatch: optional vendor doesn't match → yellow, still startable
                        $SoftMismatch = $true
                        $Reasons += (Get-I18n 'ReasonVendorOptional' @(($Hw.BoardVendors -join ', ')))
                    }
                }
            }
        }

        # A profile fully matches only if no hard AND no soft mismatches
        if ($Matches -and -not $SoftMismatch -and $RecommendedIndex -eq -1) {
            $RecommendedIndex = $i
        }

        $EvaluatedProfiles += [PSCustomObject]@{
            Index        = $i + 1
            Name         = $Name
            Path         = $File.FullName
            ProfileData  = $ProfileData
            Matches      = $Matches
            HardMismatch = $HardMismatch
            SoftMismatch = $SoftMismatch
            Reasons      = $Reasons
        }
    }

    # If ProfileName was explicitly passed via parameter
    if ($ProfileName) {
        $DirectMatch = $EvaluatedProfiles | Where-Object { $_.Name -eq $ProfileName }
        if ($DirectMatch) {
            Write-Step -Section 'Profile' -Message (Get-I18n 'UsingSpecifiedProfile' @($DirectMatch.Name)) -Level Success
            return $DirectMatch.ProfileData
        }
        else {
            Write-Step -Section 'Profile' -Message (Get-I18n 'ProfileNotFound' @($ProfileName)) -Level Error
            return $null
        }
    }

    # Interactive selection loop (allows changing language or exiting)
    while ($true) {
        Write-Step -Section 'Profile' -Message (Get-I18n 'AvailableProfiles') -Level Info
        $MatchText = Get-I18n 'TagMatch'
        $MismatchText = Get-I18n 'TagMismatch'
        $RecText = Get-I18n 'TagRecommended'

        $SoftMismatchText = Get-I18n 'TagSoftMismatch'

        foreach ($Item in $EvaluatedProfiles) {
            $Tag = "[$($Item.Index)]"
            if ($Item.Matches -and -not $Item.SoftMismatch) {
                # Fully compatible — green
                $RecTag = if ($Item.Index - 1 -eq $RecommendedIndex) { $RecText } else { "" }
                Write-Step -Section 'Profile' -Message "  $Tag [$MatchText] $($Item.Name)$RecTag" -Level Success
            }
            elseif ($Item.SoftMismatch -and -not $Item.HardMismatch) {
                # Soft mismatch only (Require*=$false) — yellow/warning, still startable
                $ReasonText = $Item.Reasons -join '; '
                Write-Step -Section 'Profile' -Message "  $Tag [$SoftMismatchText] $($Item.Name) ($ReasonText)" -Level Warning

                # Show Require flags for clarity
                $reqModels = $null
                $reqVendors = $null
                if ($Item.ProfileData.ContainsKey('Hardware')) {
                    $hw = $Item.ProfileData.Hardware
                    if ($hw.ContainsKey('RequireModels')) { $reqModels = $hw.RequireModels }
                    if ($hw.ContainsKey('RequireBoardVendors')) { $reqVendors = $hw.RequireBoardVendors }
                }
                
            }
            else {
                # Hard mismatch (Require*=$true or OS/Build mismatch) — red, NOT startable
                $ReasonText = $Item.Reasons -join '; '
                Write-Step -Section 'Profile' -Message "  $Tag [$MismatchText] $($Item.Name) ($ReasonText)" -Level Error

                # Show Require flags for clarity
                $reqModels = $null
                $reqVendors = $null
                if ($Item.ProfileData.ContainsKey('Hardware')) {
                    $hw = $Item.ProfileData.Hardware
                    if ($hw.ContainsKey('RequireModels')) { $reqModels = $hw.RequireModels }
                    if ($hw.ContainsKey('RequireBoardVendors')) { $reqVendors = $hw.RequireBoardVendors }
                }
                Write-Step -Section 'Profile' -Message "    RequireModels       = $reqModels" -Level Error
                Write-Step -Section 'Profile' -Message "    RequireBoardVendors = $reqVendors" -Level Error
            }
        }

        Write-Host ""
        Write-Host (Get-I18n 'ProfileLegendHeader') -ForegroundColor DarkGray
        Write-Host (Get-I18n 'ProfileLegendGreen') -ForegroundColor Green
        Write-Host (Get-I18n 'ProfileLegendYellow') -ForegroundColor Yellow
        Write-Host (Get-I18n 'ProfileLegendRed') -ForegroundColor Red
        Write-Host ""

        Write-Host ""
        $CurrLang = Get-CurrentLanguage
        Write-Host (Get-I18n 'OptionChangeLang' @($CurrLang)) -ForegroundColor Cyan
        Write-Host (Get-I18n 'OptionExit') -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "MachineForge" -ForegroundColor White -NoNewline
        Write-Host " - " -ForegroundColor Blue -NoNewline
        Write-Host "v$($SystemInfo.ScriptVersion)" -ForegroundColor Red
        Write-Host ""
        Write-Host ""

        # Default index selection
        $DefaultIndex = if ($RecommendedIndex -ne -1) { $RecommendedIndex } else { 0 }
        $DefaultProfile = $EvaluatedProfiles[$DefaultIndex]

        $PromptMsg = Get-I18n 'PromptSelectProfile' @($EvaluatedProfiles.Count, $DefaultProfile.Index, $DefaultProfile.Name)
        Write-Host $PromptMsg -NoNewline -ForegroundColor Yellow
        $Selection = Read-Host

        if ([string]::IsNullOrWhiteSpace($Selection)) {
            $Chosen = $DefaultProfile
            if ($Chosen.HardMismatch) {
                Write-Step -Section 'Profile' -Message (Get-I18n 'ProfileHardMismatchNotStartable') -Level Error
                Write-Host ""
                continue
            }
            if ($Chosen.SoftMismatch) {
                Write-Step -Section 'Profile' -Message (Get-I18n 'ProfileSoftMismatchWarning') -Level Warning
            }
            Write-Step -Section 'Profile' -Message (Get-I18n 'SelectedProfile' @($Chosen.Name)) -Level Success
            return $Chosen.ProfileData
        }

        $CleanSelection = $Selection.Trim()

        # Option 0: Exit
        if ($CleanSelection -eq '0') {
            Write-Host ""
            Write-Step -Section 'Setup' -Message (Get-I18n 'ExitingSetup') -Level Warning
            return 'EXIT'
        }

        # Option L: Language change
        if ($CleanSelection -eq 'L' -or $CleanSelection -eq 'l' -or $CleanSelection.ToUpper() -eq 'LANG') {
            if ($LangDir -and (Test-Path $LangDir)) {
                $LangFiles = Get-ChildItem -Path $LangDir -Filter '*.psd1' -File
                if ($LangFiles.Count -gt 0) {
                    Write-Host ""
                    Write-Step -Section 'Language' -Message (Get-I18n 'SelectLanguagePrompt') -Level Info
                    for ($lIdx = 0; $lIdx -lt $LangFiles.Count; $lIdx++) {
                        $LCode = $LangFiles[$lIdx].BaseName
                        Write-Host "  [$($lIdx + 1)] $LCode" -ForegroundColor Cyan
                    }
                    Write-Host (Get-I18n 'PromptSelectLanguage' @($LangFiles.Count)) -NoNewline -ForegroundColor Yellow
                    $LChoice = Read-Host
                    if ([int]::TryParse($LChoice, [ref]$null)) {
                        $LNum = [int]$LChoice
                        if ($LNum -ge 1 -and $LNum -le $LangFiles.Count) {
                            $NewLang = $LangFiles[$LNum - 1].BaseName
                            Initialize-Localization -Language $NewLang -LangDir $LangDir
                            Write-Step -Section 'Language' -Message (Get-I18n 'LanguageChanged' @($NewLang)) -Level Success
                            Start-Sleep -Milliseconds 400
                            return 'RESTART'
                        }
                    }
                }
            }
            Write-Step -Section 'Language' -Message (Get-I18n 'LangChangeFailed') -Level Warning
            continue
        }

        # Number selection
        if ([int]::TryParse($CleanSelection, [ref]$null)) {
            $ParsedNum = [int]$CleanSelection
            if ($ParsedNum -ge 1 -and $ParsedNum -le $EvaluatedProfiles.Count) {
                $Chosen = $EvaluatedProfiles[$ParsedNum - 1]
                if ($Chosen.HardMismatch) {
                    Write-Step -Section 'Profile' -Message (Get-I18n 'ProfileHardMismatchNotStartable') -Level Error
                    Write-Host "" 
                    continue
                }
                if ($Chosen.SoftMismatch) {
                    Write-Step -Section 'Profile' -Message (Get-I18n 'ProfileSoftMismatchWarning') -Level Warning
                }
                Write-Step -Section 'Profile' -Message (Get-I18n 'SelectedProfile' @($Chosen.Name)) -Level Success
                return $Chosen.ProfileData
            }
            else {
                Write-Step -Section 'Profile' -Message (Get-I18n 'InvalidSelectionNum' @($CleanSelection)) -Level Error
                Write-Host ""
                continue
            }
        }
        else {
            $ByName = $EvaluatedProfiles | Where-Object { $_.Name -eq $CleanSelection }
            if ($ByName) {
                $Chosen = $ByName[0]
                if ($Chosen.HardMismatch) {
                    Write-Step -Section 'Profile' -Message (Get-I18n 'ProfileHardMismatchNotStartable') -Level Error
                    Write-Host ""
                    continue
                }
                if ($Chosen.SoftMismatch) {
                    Write-Step -Section 'Profile' -Message (Get-I18n 'ProfileSoftMismatchWarning') -Level Warning
                }
                Write-Step -Section 'Profile' -Message (Get-I18n 'SelectedProfile' @($Chosen.Name)) -Level Success
                return $Chosen.ProfileData
            }
            else {
                Write-Step -Section 'Profile' -Message (Get-I18n 'UnknownProfileName' @($CleanSelection)) -Level Error
                Write-Host ""
                continue
            }
        }
    }
}


function Merge-ProfileConfiguration {
    <#
    .SYNOPSIS
        Loads templates in order, merges all configuration sections,
        then applies profile-level overrides. Returns a unified config hashtable.
    #>
    param (
        [Parameter(Mandatory)]
        [hashtable]$Profile,

        [Parameter(Mandatory)]
        [string]$TemplateDir,

        [Parameter(Mandatory)]
        [hashtable]$RegistryArchive,

        [Parameter(Mandatory)]
        [hashtable]$PackageArchive,

        [Parameter(Mandatory)]
        [hashtable]$FirewallArchive
    )

    # Merged result
    $Config = @{
        ComputerName              = $null
        Packages                  = [System.Collections.Generic.List[string]]::new()
        UninstallPackages         = [System.Collections.Generic.List[string]]::new()
        Npm                       = [System.Collections.Generic.List[string]]::new()
        UninstallNpm              = [System.Collections.Generic.List[string]]::new()
        Registry                  = [System.Collections.Generic.List[string]]::new()
        Firewall                  = [System.Collections.Generic.List[string]]::new()
        RemoveFirewall            = [System.Collections.Generic.List[string]]::new()
        Features                  = [System.Collections.Generic.List[string]]::new()
        DisableFeatures           = [System.Collections.Generic.List[string]]::new()
        WindowsCapabilities       = [System.Collections.Generic.List[string]]::new()
        RemoveWindowsCapabilities = [System.Collections.Generic.List[string]]::new()
        RemoveApps                = [System.Collections.Generic.List[string]]::new()
        Variables                 = @{}
        Exec                      = @{
            Mkdir        = [System.Collections.Generic.List[string]]::new()
            Copy         = [System.Collections.Generic.List[hashtable]]::new()
            DownloadFile = [System.Collections.Generic.List[hashtable]]::new()
            AppInstaller = [System.Collections.Generic.List[hashtable]]::new()
            Command      = [System.Collections.Generic.List[hashtable]]::new()
        }
    }

    # Load and merge templates in order
    if ($Profile.ContainsKey('Templates') -and $Profile.Templates.Count -gt 0) {
        foreach ($TemplateName in $Profile.Templates) {
            $TemplatePath = Join-Path $TemplateDir "$TemplateName.psd1"

            if (-not (Test-Path -LiteralPath $TemplatePath)) {
                Write-Step -Section 'Template' -Message (Get-I18n 'TemplateNotFound' @($TemplateName)) -Level Warning
                continue
            }

            Write-Step -Section 'Template' -Message (Get-I18n 'LoadingTemplate' @($TemplateName)) -Level Info
            $Template = Import-PowerShellDataFile -Path $TemplatePath

            Merge-SectionInto -Config $Config -Source $Template
        }
    }

    # Apply profile-level overrides (merged on top of templates)
    Merge-SectionInto -Config $Config -Source $Profile

    # ComputerName is provided via `Variables` to avoid top-level collisions.
    if ($Config.Variables.ContainsKey('ComputerName') -and $Config.Variables.ComputerName) {
        $Config.ComputerName = $Config.Variables.ComputerName
    }

    # Deduplicate lists
    $Config.Packages = [System.Collections.Generic.List[string]]@($Config.Packages   | Select-Object -Unique)
    $Config.UninstallPackages = [System.Collections.Generic.List[string]]@($Config.UninstallPackages | Select-Object -Unique)
    $Config.Npm = [System.Collections.Generic.List[string]]@($Config.Npm        | Select-Object -Unique)
    $Config.UninstallNpm = [System.Collections.Generic.List[string]]@($Config.UninstallNpm | Select-Object -Unique)
    $Config.Registry = [System.Collections.Generic.List[string]]@($Config.Registry   | Select-Object -Unique)
    $Config.Firewall = [System.Collections.Generic.List[string]]@($Config.Firewall   | Select-Object -Unique)
    $Config.RemoveFirewall = [System.Collections.Generic.List[string]]@($Config.RemoveFirewall | Select-Object -Unique)
    $Config.Features = [System.Collections.Generic.List[string]]@($Config.Features   | Select-Object -Unique)
    $Config.DisableFeatures = [System.Collections.Generic.List[string]]@($Config.DisableFeatures | Select-Object -Unique)
    $Config.WindowsCapabilities = [System.Collections.Generic.List[string]]@($Config.WindowsCapabilities | Select-Object -Unique)
    $Config.RemoveWindowsCapabilities = [System.Collections.Generic.List[string]]@($Config.RemoveWindowsCapabilities | Select-Object -Unique)
    $Config.RemoveApps = [System.Collections.Generic.List[string]]@($Config.RemoveApps | Select-Object -Unique)

    # Validate references against archives
    Confirm-References -Names $Config.Registry -Archive $RegistryArchive -ArchiveName 'registry.psd1' -Section 'Registry'
    Confirm-References -Names $Config.Packages -Archive $PackageArchive  -ArchiveName 'package.psd1'  -Section 'Packages'
    Confirm-References -Names $Config.UninstallPackages -Archive $PackageArchive -ArchiveName 'package.psd1' -Section 'Packages'
    Confirm-References -Names $Config.Firewall -Archive $FirewallArchive -ArchiveName 'firewall.psd1' -Section 'Firewall'
    Confirm-References -Names $Config.RemoveFirewall -Archive $FirewallArchive -ArchiveName 'firewall.psd1' -Section 'Firewall'

    return $Config
}


function Merge-SectionInto {
    <#
    .SYNOPSIS
        Merges a source hashtable (template or profile) into the config accumulator.
    #>
    param (
        [hashtable]$Config,
        [hashtable]$Source
    )

    $ListKeys = @('Packages', 'UninstallPackages', 'Npm', 'UninstallNpm', 'Registry', 'Firewall', 'RemoveFirewall', 'Features', 'DisableFeatures', 'WindowsCapabilities', 'RemoveWindowsCapabilities', 'RemoveApps')

    foreach ($Key in $ListKeys) {
        if ($Source.ContainsKey($Key) -and $Source[$Key]) {
            foreach ($Item in $Source[$Key]) {
                $Config[$Key].Add($Item)
            }
        }
    }

    # Merge Variables
    if ($Source.ContainsKey('Variables') -and $Source.Variables) {
        foreach ($VarKey in $Source.Variables.Keys) {
            $Config.Variables[$VarKey] = $Source.Variables[$VarKey]
        }
    }

    # Merge Exec sub-sections
    if ($Source.ContainsKey('Exec') -and $Source.Exec) {
        $ExecSource = $Source.Exec

        if ($ExecSource.ContainsKey('Mkdir') -and $ExecSource.Mkdir) {
            foreach ($Dir in $ExecSource.Mkdir) {
                $Config.Exec.Mkdir.Add($Dir)
            }
        }

        if ($ExecSource.ContainsKey('Copy') -and $ExecSource.Copy) {
            foreach ($CopyItem in $ExecSource.Copy) {
                $Config.Exec.Copy.Add($CopyItem)
            }
        }

        if ($ExecSource.ContainsKey('DownloadFile') -and $ExecSource.DownloadFile) {
            foreach ($DlItem in $ExecSource.DownloadFile) {
                $Config.Exec.DownloadFile.Add($DlItem)
            }
        }

        if ($ExecSource.ContainsKey('AppInstaller') -and $ExecSource.AppInstaller) {
            foreach ($AppItem in $ExecSource.AppInstaller) {
                $Config.Exec.AppInstaller.Add($AppItem)
            }
        }

        if ($ExecSource.ContainsKey('Command') -and $ExecSource.Command) {
            foreach ($Cmd in $ExecSource.Command) {
                $Config.Exec.Command.Add($Cmd)
            }
        }
    }
}


function Confirm-References {
    <#
    .SYNOPSIS
        Validates that all names in a list exist in the corresponding archive.
    #>
    param (
        [System.Collections.Generic.List[string]]$Names,
        [hashtable]$Archive,
        [string]$ArchiveName,
        [string]$Section
    )

    foreach ($Name in $Names) {
        if (-not $Archive.ContainsKey($Name)) {
            Write-Step -Section $Section -Message (Get-I18n 'ArchiveEntryNotFound' @($Name, $ArchiveName)) -Level Warning
        }
    }
}


Export-ModuleMember -Function `
    Get-SystemInfo, `
    Find-MatchingProfile, `
    Merge-ProfileConfiguration
