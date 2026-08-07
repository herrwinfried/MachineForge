# package.psm1
# Resolves package names from the archive and installs them (Winget, Chocolatey, NPM).

function Resolve-Packages {
    <#
    .SYNOPSIS
        Takes a list of package names and the archive, returns resolved package objects
        split into user-level and admin-level groups.
    #>
    param (
        [Parameter(Mandatory)]
        [string[]]$Names,

        [Parameter(Mandatory)]
        [hashtable]$Archive
    )

    $UserPackages  = @()
    $AdminPackages = @()

    foreach ($Name in $Names) {
        if (-not $Archive.ContainsKey($Name)) {
            Write-Step -Section 'Packages' -Message (Get-I18n 'UnknownPackage' @($Name)) -Level Warning
            continue
        }

        $Pkg = $Archive[$Name]

        if (-not $Pkg.enabled) {
            Write-Step -Section 'Packages' -Message (Get-I18n 'DisabledPackage' @($Name)) -Level Skip
            continue
        }

        $Resolved = @{
            PackageName    = $Name
            Id             = $Pkg.Id
            PackageManager = $Pkg.PackageManager
            Interactive    = if ($Pkg.ContainsKey('interactive')) { $Pkg.interactive } else { $false }
        }

        # Chocolatey requires admin
        if ($Pkg.PackageManager -eq 'chocolatey') {
            $AdminPackages += $Resolved
        }
        else {
            $UserPackages += $Resolved
        }
    }

    return @{
        User  = $UserPackages
        Admin = $AdminPackages
    }
}


function Install-ResolvedPackages {
    <#
    .SYNOPSIS
        Installs an array of resolved package objects (winget / chocolatey / npm).
    #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Packages,

        [switch]$WhatIf
    )

    foreach ($Pkg in $Packages) {
        if ($WhatIf) {
            Write-Step -Section 'Packages' -Message (Get-I18n 'WhatIfInstallPackage' @($Pkg.Id, $Pkg.PackageManager)) -Level Info
            continue
        }

        switch ($Pkg.PackageManager.ToLower()) {
            'winget' {
                if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
                    Write-Step -Section 'Packages' -Message (Get-I18n 'WingetNotInstalled') -Level Error
                    continue
                }

                $Arguments = @(
                    'install'
                    '--id'
                    $Pkg.Id
                    '--exact'
                    '--accept-source-agreements'
                    '--accept-package-agreements'
                )

                if ($Pkg.Interactive) {
                    $Arguments += '--interactive'
                }

                Write-Step -Section 'Packages' -Message (Get-I18n 'InstallingPackages' @($Pkg.Id, 'winget')) -Level Info
                & winget @Arguments
            }

            'chocolatey' {
                if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
                    Write-Step -Section 'Packages' -Message (Get-I18n 'ChocoNotInstalled') -Level Error
                    continue
                }

                Write-Step -Section 'Packages' -Message (Get-I18n 'InstallingPackages' @($Pkg.Id, 'chocolatey')) -Level Info
                & choco install $Pkg.Id -y
            }

            'npm' {
                if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
                    Write-Step -Section 'Packages' -Message (Get-I18n 'NpmNotInstalled') -Level Error
                    continue
                }

                Write-Step -Section 'Packages' -Message (Get-I18n 'InstallingPackages' @($Pkg.Id, 'npm -g')) -Level Info
                & npm install -g $Pkg.Id
            }

            default {
                Write-Step -Section 'Packages' -Message (Get-I18n 'UnknownPkgManager' @($Pkg.PackageManager)) -Level Warning
            }
        }
    }
}


function Install-NpmPackages {
    <#
    .SYNOPSIS
        Installs an array of global npm package names directly (npm install -g <name>).
        These come from the Npm = @(...) array in profiles/templates — no archive lookup.
    #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$NpmPackages,

        [switch]$WhatIf
    )

    if ($NpmPackages.Count -eq 0) {
        Write-Step -Section 'Packages' -Message (Get-I18n 'NoNpmPackages') -Level Skip
        return
    }

    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Step -Section 'Packages' -Message (Get-I18n 'NpmNotInstalled') -Level Error
        return
    }

    Write-Step -Section 'Packages' -Message (Get-I18n 'InstallingNpmPackages' @($NpmPackages.Count)) -Level Info

    foreach ($Pkg in $NpmPackages) {
        if ($WhatIf) {
            Write-Step -Section 'Packages' -Message (Get-I18n 'WhatIfInstallPackage' @($Pkg, 'npm -g')) -Level Info
            continue
        }

        Write-Step -Section 'Packages' -Message (Get-I18n 'InstallingPackages' @($Pkg, 'npm -g')) -Level Info
        & npm install -g $Pkg
    }
}


function Uninstall-ResolvedPackages {
    <#
    .SYNOPSIS
        Uninstalls resolved winget or Chocolatey packages.
    #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Packages,

        [switch]$WhatIf
    )

    foreach ($Pkg in $Packages) {
        if ($WhatIf) {
            Write-Step -Section 'Packages' -Message (Get-I18n 'WhatIfUninstallPackage' @($Pkg.Id, $Pkg.PackageManager)) -Level Info
            continue
        }

        try {
            switch ($Pkg.PackageManager.ToLowerInvariant()) {
                'winget' {
                    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
                        Write-Step -Section 'Packages' -Message (Get-I18n 'WingetNotInstalled') -Level Error
                        continue
                    }
                    Write-Step -Section 'Packages' -Message (Get-I18n 'UninstallingPackages' @($Pkg.Id, 'winget')) -Level Info
                    & winget uninstall --id $Pkg.Id --exact --disable-interactivity
                }
                'chocolatey' {
                    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
                        Write-Step -Section 'Packages' -Message (Get-I18n 'ChocoNotInstalled') -Level Error
                        continue
                    }
                    Write-Step -Section 'Packages' -Message (Get-I18n 'UninstallingPackages' @($Pkg.Id, 'chocolatey')) -Level Info
                    & choco uninstall $Pkg.Id -y
                }
                default {
                    Write-Step -Section 'Packages' -Message (Get-I18n 'UnsupportedUninstallManager' @($Pkg.PackageManager)) -Level Warning
                    continue
                }
            }

            if ($LASTEXITCODE -eq 0) {
                Write-Step -Section 'Packages' -Message (Get-I18n 'PackageUninstalled' @($Pkg.Id)) -Level Success
            }
            else {
                Write-Step -Section 'Packages' -Message (Get-I18n 'PackageUninstallFailed' @($Pkg.Id, "exit code $LASTEXITCODE")) -Level Error
            }
        }
        catch {
            Write-Step -Section 'Packages' -Message (Get-I18n 'PackageUninstallFailed' @($Pkg.Id, $_)) -Level Error
        }
    }
}

function Uninstall-NpmPackages {
    <# .SYNOPSIS Uninstalls global npm packages named in UninstallNpm. #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$NpmPackages,
        [switch]$WhatIf
    )

    if ($NpmPackages.Count -eq 0) { return }
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Step -Section 'Packages' -Message (Get-I18n 'NpmNotInstalled') -Level Error
        return
    }

    foreach ($Pkg in $NpmPackages) {
        if ($WhatIf) {
            Write-Step -Section 'Packages' -Message (Get-I18n 'WhatIfUninstallPackage' @($Pkg, 'npm -g')) -Level Info
            continue
        }
        try {
            Write-Step -Section 'Packages' -Message (Get-I18n 'UninstallingPackages' @($Pkg, 'npm -g')) -Level Info
            & npm uninstall -g $Pkg
            if ($LASTEXITCODE -eq 0) {
                Write-Step -Section 'Packages' -Message (Get-I18n 'PackageUninstalled' @($Pkg)) -Level Success
            }
            else {
                Write-Step -Section 'Packages' -Message (Get-I18n 'PackageUninstallFailed' @($Pkg, "exit code $LASTEXITCODE")) -Level Error
            }
        }
        catch {
            Write-Step -Section 'Packages' -Message (Get-I18n 'PackageUninstallFailed' @($Pkg, $_)) -Level Error
        }
    }
}

Export-ModuleMember -Function `
    Resolve-Packages, `
    Install-ResolvedPackages, `
    Install-NpmPackages, `
    Uninstall-ResolvedPackages, `
    Uninstall-NpmPackages
