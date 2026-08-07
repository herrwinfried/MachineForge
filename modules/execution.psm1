# execution.psm1
# Handles Exec tasks: Mkdir, Copy, DownloadFile, and Command with placeholder resolution.

function Invoke-ExecTasks {
    <#
    .SYNOPSIS
        Runs Exec tasks (Mkdir, Copy, DownloadFile, Command) with placeholder substitution.
        Returns any commands that require admin for deferred execution.
    #>
    param (
        [Parameter(Mandatory)]
        [hashtable]$ExecConfig,

        [Parameter(Mandatory)]
        [PSCustomObject]$SystemInfo,

        [switch]$WhatIf
    )

    $DeferredAdminCommands = @()

    # --- Mkdir ---
    if ($ExecConfig.Mkdir -and $ExecConfig.Mkdir.Count -gt 0) {
        foreach ($Dir in $ExecConfig.Mkdir) {
            $Resolved = Resolve-Placeholders -Value $Dir -SystemInfo $SystemInfo

            if ($WhatIf) {
                Write-Step -Section 'Exec' -Message (Get-I18n 'WhatIfCreateDir' @($Resolved)) -Level Info
                continue
            }

            if (-not (Test-Path -LiteralPath $Resolved)) {
                New-Item -Path $Resolved -ItemType Directory -Force | Out-Null
                Write-Step -Section 'Exec' -Message (Get-I18n 'CreatedDirectory' @($Resolved)) -Level Success
            }
            else {
                Write-Step -Section 'Exec' -Message (Get-I18n 'DirectoryExists' @($Resolved)) -Level Skip
            }
        }
    }

    # --- Copy ---
    if ($ExecConfig.Copy -and $ExecConfig.Copy.Count -gt 0) {
        foreach ($CopyItem in $ExecConfig.Copy) {
            $Source = Resolve-Placeholders -Value $CopyItem.source -SystemInfo $SystemInfo
            $Target = Resolve-Placeholders -Value $CopyItem.target -SystemInfo $SystemInfo

            if ($WhatIf) {
                Write-Step -Section 'Exec' -Message (Get-I18n 'WhatIfCopy' @($Source, $Target)) -Level Info
                continue
            }

            if (-not (Test-Path -LiteralPath $Source)) {
                Write-Step -Section 'Exec' -Message (Get-I18n 'SourceNotFound' @($Source)) -Level Warning
                continue
            }

            try {
                if (Test-Path -LiteralPath $Source -PathType Container) {
                    Copy-Item -Path (Join-Path $Source '*') -Destination $Target -Recurse -Force
                }
                else {
                    Copy-Item -Path $Source -Destination $Target -Force
                }
                Write-Step -Section 'Exec' -Message (Get-I18n 'CopiedFile' @($Source, $Target)) -Level Success
            }
            catch {
                Write-Step -Section 'Exec' -Message (Get-I18n 'CopyFailed' @($_)) -Level Error
            }
        }
    }

    # --- DownloadFile ---
    if ($ExecConfig.DownloadFile -and $ExecConfig.DownloadFile.Count -gt 0) {
        foreach ($DlItem in $ExecConfig.DownloadFile) {
            $TargetDir = Resolve-Placeholders -Value $DlItem.target -SystemInfo $SystemInfo
            $FullPath  = Join-Path $TargetDir $DlItem.fullFileName

            if ($WhatIf) {
                Write-Step -Section 'Exec' -Message (Get-I18n 'WhatIfDownload' @($DlItem.url, $FullPath)) -Level Info
                continue
            }

            try {
                if (-not (Test-Path -LiteralPath $TargetDir)) {
                    New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
                }

                Invoke-WebRequest -Uri $DlItem.url -OutFile $FullPath -UseBasicParsing
                Write-Step -Section 'Exec' -Message (Get-I18n 'DownloadedFile' @($DlItem.fullFileName)) -Level Success
            }
            catch {
                Write-Step -Section 'Exec' -Message (Get-I18n 'DownloadFailed' @($DlItem.url, $_)) -Level Error
            }
        }
    }

    # --- AppInstaller ---
    if ($ExecConfig.AppInstaller -and $ExecConfig.AppInstaller.Count -gt 0) {
        foreach ($AppItem in $ExecConfig.AppInstaller) {
            $AppInstallerPath = $null

            # Determine if it's a URL or local path
            $Source = $AppItem.source
            $IsUrl = $Source -match '^https?://'

            if ($WhatIf) {
                Write-Step -Section 'Exec' -Message (Get-I18n 'WhatIfDownload' @($Source, 'AppInstaller')) -Level Info
                continue
            }

            try {
                if ($IsUrl) {
                    # Download from URL
                    $TempDir = $env:TEMP
                    $FileName = Split-Path -Leaf $Source
                    $AppInstallerPath = Join-Path $TempDir $FileName

                    if (-not (Test-Path -LiteralPath $TempDir)) {
                        New-Item -Path $TempDir -ItemType Directory -Force | Out-Null
                    }

                    Invoke-WebRequest -Uri $Source -OutFile $AppInstallerPath -UseBasicParsing
                    Write-Step -Section 'Exec' -Message (Get-I18n 'DownloadedFile' @($FileName)) -Level Success
                }
                else {
                    # Use local file with placeholder resolution
                    $AppInstallerPath = Resolve-Placeholders -Value $Source -SystemInfo $SystemInfo

                    if (-not (Test-Path -LiteralPath $AppInstallerPath)) {
                        Write-Step -Section 'Exec' -Message (Get-I18n 'SourceNotFound' @($AppInstallerPath)) -Level Warning
                        continue
                    }

                    Write-Step -Section 'Exec' -Message (Get-I18n 'FoundFile' @($AppInstallerPath)) -Level Success
                }

                # .appinstaller files use the dedicated parameter; .appx/.msix
                # packages continue to use -Path.
                $InstallParameter = if ([IO.Path]::GetExtension($AppInstallerPath) -ieq '.appinstaller') {
                    '-AppInstallerFile'
                }
                else {
                    '-Path'
                }

                # Create deferred admin command for AppxPackage installation
                $InstallCmd = @{
                    Shell                = 'powershell'
                    Command              = "Add-AppxPackage $InstallParameter `"$AppInstallerPath`""
                    RequiresAdministrator = $true
                }
                $DeferredAdminCommands += $InstallCmd
                Write-Step -Section 'Exec' -Message (Get-I18n 'DeferredAppInstaller' @(Split-Path -Leaf $AppInstallerPath)) -Level Info
            }
            catch {
                Write-Step -Section 'Exec' -Message (Get-I18n 'DownloadFailed' @($Source, $_)) -Level Error
            }
        }
    }

    # --- Command ---
    if ($ExecConfig.Command -and $ExecConfig.Command.Count -gt 0) {
        foreach ($Cmd in $ExecConfig.Command) {
            $NeedsAdmin = $false
            if ($Cmd.ContainsKey('RequiresAdministrator')) {
                $NeedsAdmin = $Cmd.RequiresAdministrator
            }

            if ([bool]$NeedsAdmin -and -not (Test-IsAdministrator)) {
                $DeferredAdminCommands += $Cmd
                Write-Step -Section 'Exec' -Message (Get-I18n 'DeferredAdminCmd' @($Cmd.Command)) -Level Info
                continue
            }

            if ($WhatIf) {
                Write-Step -Section 'Exec' -Message (Get-I18n 'WhatIfRunCmd' @($Cmd.Shell, $Cmd.Command)) -Level Info
                continue
            }

            Invoke-ShellCommand -Cmd $Cmd
        }
    }

    return $DeferredAdminCommands
}


function Invoke-ShellCommand {
    <#
    .SYNOPSIS
        Executes a single shell command hashtable.
    #>
    param (
        [Parameter(Mandatory)]
        [hashtable]$Cmd
    )

    if (-not $Cmd.ContainsKey('Shell') -or -not $Cmd.ContainsKey('Command')) {
        Write-Step -Section 'Exec' -Message 'Command entries must include Shell and Command.' -Level Error
        return
    }

    $Shell = $Cmd.Shell.ToLowerInvariant()

    try {
        switch ($Shell) {
            'cmd'        { & cmd.exe    /c           $Cmd.Command }
            'powershell' { & powershell.exe -NoProfile -Command $Cmd.Command }
            'pwsh'       { & pwsh.exe    -NoProfile  -Command $Cmd.Command }
            default {
                Write-Step -Section 'Exec' -Message (Get-I18n 'UnsupportedShell' @($Shell)) -Level Error
                return
            }
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Step -Section 'Exec' -Message (Get-I18n 'RanCmd' @($Shell, $Cmd.Command)) -Level Success
        }
        else {
            Write-Step -Section 'Exec' -Message (Get-I18n 'CmdFailed' @($Shell, $Cmd.Command, "exit code $LASTEXITCODE")) -Level Error
        }
    }
    catch {
        Write-Step -Section 'Exec' -Message (Get-I18n 'CmdFailed' @($Shell, $Cmd.Command, $_)) -Level Error
    }
}


function Invoke-DeferredAdminCommands {
    <#
    .SYNOPSIS
        Runs deferred admin commands (called from within the elevated session).
    #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Commands,

        [switch]$WhatIf
    )

    foreach ($Cmd in $Commands) {
        if ($WhatIf) {
            Write-Step -Section 'Exec' -Message (Get-I18n 'WhatIfRunCmd' @($Cmd.Shell, $Cmd.Command)) -Level Info
            continue
        }

        Invoke-ShellCommand -Cmd $Cmd
    }
}


function Resolve-Placeholders {
    <#
    .SYNOPSIS
        Replaces HOME and SCRIPTDIR placeholders in a string.
    #>
    param (
        [string]$Value,
        [PSCustomObject]$SystemInfo
    )

    if ([string]::IsNullOrWhiteSpace($Value)) { return $Value }

    # Word boundaries make the first substitutions safe even at the start of a path.
    $Value = $Value -creplace '\bSCRIPTDIR\b', $SystemInfo.ScriptDir
    $Value = $Value -creplace '\bHOME\b',      $SystemInfo.UserHome

    $Value = $Value -replace '/', [System.IO.Path]::DirectorySeparatorChar
    return $Value
}


Export-ModuleMember -Function `
    Invoke-ExecTasks, `
    Invoke-ShellCommand, `
    Invoke-DeferredAdminCommands, `
    Resolve-Placeholders
