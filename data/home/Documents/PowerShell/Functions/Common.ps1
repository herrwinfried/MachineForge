function Test-CommandExists {
    param(
        [Parameter(Mandatory)]
        [string]$CommandName
    )

    return [bool](Get-Command -Name $CommandName -ErrorAction SilentlyContinue)
}

function IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}