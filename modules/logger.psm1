# logger.psm1
# Centralized file logging. All Write-Step calls are also mirrored here.
# Uses direct System.IO methods to ensure logging works seamlessly even during -WhatIf mode.

$script:LogFile = $null

function Initialize-Logger {
    <#
    .SYNOPSIS
        Creates the logs directory and opens a timestamped log file.
    #>
    param (
        [Parameter(Mandatory)]
        [string]$ScriptDir
    )

    $LogDir = Join-Path $ScriptDir 'logs'
    if (-not [System.IO.Directory]::Exists($LogDir)) {
        [System.IO.Directory]::CreateDirectory($LogDir) | Out-Null
    }

    $Timestamp      = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
    $script:LogFile = Join-Path $LogDir "setup_$Timestamp.log"

    $Now            = Get-Date
    $UtcOffset      = $Now.ToString('zzz')
    $TimeZoneName   = try { [System.TimeZoneInfo]::Local.DisplayName } catch { 'UTC' }
    $StartFormatted = "$($Now.ToString('yyyy-MM-dd HH:mm:ss.fff')) $UtcOffset ($TimeZoneName)"

    # Write header
    $Header = "=" * 60
    $HeaderContent = @"
$Header
  Windows Setup Log
  Started : $StartFormatted
  Host    : $env:COMPUTERNAME
  User    : $env:USERNAME
$Header

"@
    [System.IO.File]::WriteAllText($script:LogFile, $HeaderContent, [System.Text.Encoding]::UTF8)
}

function Write-Log {
    <#
    .SYNOPSIS
        Appends a line to the active log file. Safe to call even if logger is not initialized.
    #>
    param (
        [string]$Level   = 'INFO',
        [string]$Section = '',
        [string]$Message = ''
    )

    if (-not $script:LogFile) { return }

    $Timestamp = (Get-Date).ToString('HH:mm:ss.fff zzz')
    $Line      = "[$Timestamp] [$Level] [$Section] $Message`r`n"

    try {
        [System.IO.File]::AppendAllText($script:LogFile, $Line, [System.Text.Encoding]::UTF8)
    }
    catch {
        # Silently ignore log write errors — never crash the main flow
    }
}

function Get-LogPath {
    return $script:LogFile
}

function Set-LogPath {
    <#
    .SYNOPSIS
        Reuses an existing log file, for example from an elevated child process.
    #>
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    $script:LogFile = $Path
}

Export-ModuleMember -Function Initialize-Logger, Write-Log, Get-LogPath, Set-LogPath
