function Switch-DockerDaemon {
    $dockerCli = Join-Path $env:ProgramFiles 'Docker\Docker\DockerCli.exe'
    if (Test-Path $dockerCli) {
        & $dockerCli -SwitchDaemon
    }
}

function Get-DockerModeValue {
    if (-not (Test-CommandExists docker)) {
        return
    }

    $dockerMode = docker info --format '{{.OSType}}' 2>$null
    if ($dockerMode) {
        return $dockerMode.Trim()
    }
}

function Get-DockerMode {
    $dockerMode = Get-DockerModeValue
    if ($dockerMode) {
        Write-Host -ForegroundColor Green "OS: $dockerMode"
    }
    else {
        Write-Host -ForegroundColor Red 'OS Not Found'
    }
}