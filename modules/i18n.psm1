# i18n.psm1
# Handles localization for the setup system and English mapping for log files.

$script:LocalizedStrings = @{}
$script:EnglishStrings   = @{}
$script:UiToLogMap       = @{}
$script:CurrentLanguage  = 'en-US'

function Initialize-Localization {
    <#
    .SYNOPSIS
        Initializes localization state by loading the requested language file or auto-detecting system culture.
        Always loads en-US.psd1 as the fallback / English reference for logging.
    #>
    param (
        [string]$Language,
        [string]$LangDir
    )

    $script:UiToLogMap.Clear()

    # Always load English reference dictionary for log output
    $EnLangFile = Join-Path $LangDir "en-US.psd1"
    if (Test-Path -LiteralPath $EnLangFile) {
        $script:EnglishStrings = Import-PowerShellDataFile -Path $EnLangFile
    }

    if (-not $Language) {
        try {
            $Culture = (Get-Culture).Name
            if (Test-Path (Join-Path $LangDir "$Culture.psd1")) {
                $Language = $Culture
            }
            elseif ($Culture.StartsWith('tr') -and (Test-Path (Join-Path $LangDir "tr-TR.psd1"))) {
                $Language = 'tr-TR'
            }
            else {
                $Language = 'en-US'
            }
        }
        catch {
            $Language = 'en-US'
        }
    }

    $LangFile = Join-Path $LangDir "$Language.psd1"
    if (-not (Test-Path -LiteralPath $LangFile)) {
        $LangFile = $EnLangFile
        $Language = 'en-US'
    }

    $script:CurrentLanguage = $Language
    if (Test-Path -LiteralPath $LangFile) {
        $script:LocalizedStrings = Import-PowerShellDataFile -Path $LangFile
    }
}

function Get-I18n {
    <#
    .SYNOPSIS
        Returns a localized string for a given key, formatted with optional arguments.
        Registers mapping to English counterpart for logging.
    #>
    param (
        [Parameter(Mandatory)]
        [string]$Key,

        [object[]]$Args = @()
    )

    $UiPattern  = if ($script:LocalizedStrings.ContainsKey($Key)) { $script:LocalizedStrings[$Key] } else { $Key }
    $LogPattern = if ($script:EnglishStrings.ContainsKey($Key))   { $script:EnglishStrings[$Key] }   else { $Key }

    $UiText = if ($Args -and $Args.Count -gt 0) {
        try { ($UiPattern -f $Args) } catch { $UiPattern }
    } else {
        $UiPattern
    }

    $LogText = if ($Args -and $Args.Count -gt 0) {
        try { ($LogPattern -f $Args) } catch { $LogPattern }
    } else {
        $LogPattern
    }

    if ($UiText -and $LogText -and ($UiText -ne $LogText)) {
        $script:UiToLogMap[$UiText] = $LogText
    }

    return $UiText
}

function Get-I18nLogMessage {
    <#
    .SYNOPSIS
        Converts a UI message (which may contain localized strings or fragments) to English for logging.
    #>
    param (
        [string]$Message
    )

    if ([string]::IsNullOrWhiteSpace($Message)) { return $Message }

    $Result = $Message

    # 1. Exact match in UiToLogMap
    if ($script:UiToLogMap.ContainsKey($Result)) {
        return $script:UiToLogMap[$Result]
    }

    # 2. Replace registered UI fragments (sorted by length descending to prevent partial key mismatches)
    $SortedKeys = $script:UiToLogMap.Keys | Sort-Object -Property Length -Descending
    foreach ($UiKey in $SortedKeys) {
        if ($Result.Contains($UiKey)) {
            $Result = $Result.Replace($UiKey, $script:UiToLogMap[$UiKey])
        }
    }

    return $Result
}

function Get-CurrentLanguage {
    return $script:CurrentLanguage
}

Export-ModuleMember -Function `
    Initialize-Localization, `
    Get-I18n, `
    Get-I18nLogMessage, `
    Get-CurrentLanguage
