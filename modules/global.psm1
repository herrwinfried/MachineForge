# global.psm1
# Shared utilities: admin check, styled console output, banner.

function Test-IsAdministrator {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = [Security.Principal.WindowsPrincipal]$Identity
    return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-Step {
    param (
        [Parameter(Mandatory)]
        [string]$Section,

        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Skip')]
        [string]$Level = 'Info'
    )

    $Colors = @{
        Info    = 'Cyan'
        Success = 'Green'
        Warning = 'Yellow'
        Error   = 'Red'
        Skip    = 'DarkGray'
    }

$Prefixes = @{
    Info    = '  >'
    Success = '  [+]'
    Warning = '  [!]'
    Error   = '  [X]'
    Skip    = '  [-]'
}

    Write-Host "$($Prefixes[$Level]) " -ForegroundColor $Colors[$Level] -NoNewline
    Write-Host "[$Section] "          -ForegroundColor White             -NoNewline
    Write-Host $Message               -ForegroundColor $Colors[$Level]

    # Mirror to log file if logger is loaded
    if (Get-Command -Name Write-Log -ErrorAction SilentlyContinue) {
        $LogMsg = if (Get-Command -Name Get-I18nLogMessage -ErrorAction SilentlyContinue) {
            Get-I18nLogMessage $Message
        }
        else {
            $Message
        }
        Write-Log -Level $Level.ToUpper() -Section $Section -Message $LogMsg
    }
}

function Write-Banner {
    param (
        [Parameter(Mandatory)]
        [string]$Title
    )

    $Line = '=' * 60
    Write-Host ""
    Write-Host $Line   -ForegroundColor DarkCyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host $Line   -ForegroundColor DarkCyan
    Write-Host ""

    if (Get-Command -Name Write-Log -ErrorAction SilentlyContinue) {
        $LogTitle = if (Get-Command -Name Get-I18nLogMessage -ErrorAction SilentlyContinue) {
            Get-I18nLogMessage $Title
        }
        else {
            $Title
        }
        Write-Log -Level 'BANNER' -Section 'Banner' -Message $LogTitle
    }
}

Export-ModuleMember -Function `
    Test-IsAdministrator, `
    Write-Step, `
    Write-Banner
