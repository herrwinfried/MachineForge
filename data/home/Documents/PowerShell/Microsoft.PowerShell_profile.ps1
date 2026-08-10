if (-not $IsWindows) {
    return
}

$FunctionsPath = Join-Path $PSScriptRoot 'Functions'
if (Test-Path $FunctionsPath) {
    Get-ChildItem -Path $FunctionsPath -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object { . $_.FullName }
}

Initialize-OhMyPosh -ThemePath (Join-Path $HOME '.poshthemes\default.omp.json')