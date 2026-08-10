function Initialize-OhMyPosh {
    param(
        [Parameter(Mandatory)]
        [string]$ThemePath
    )

    if ((Test-CommandExists 'oh-my-posh') -and (Test-Path $ThemePath)) {
        oh-my-posh init pwsh --config $ThemePath | Invoke-Expression
    }
}