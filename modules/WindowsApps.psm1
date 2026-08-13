# WindowsApps.psm1
# Removes pre-installed Windows Store apps (AppX packages and provisioned packages).

function Remove-ResolvedWindowsApps {
    <#
    .SYNOPSIS
        Removes a list of AppX packages and provisioned packages for the system / user.
    #>
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Apps,

        [string]$UserName = $env:USERNAME,

        [switch]$WhatIf
    )

    $IsAdmin = Test-IsAdministrator

    foreach ($App in $Apps) {
        if ($WhatIf) {
            Write-Step -Section 'Apps' -Message (Get-I18n 'WhatIfRemoveApp' @($App)) -Level Info
            continue
        }

        try {
            # 1. Remove Provisioned Package (prevents reinstall for new users)
            if ($IsAdmin) {
                $ProvPackage = Get-AppxProvisionedPackage -Online |
                    Where-Object { $_.DisplayName -like "*$App*" -or $_.PackageName -like "*$App*" }
                if ($ProvPackage) {
                    foreach ($Prov in $ProvPackage) {
                        Remove-AppxProvisionedPackage -Online -PackageName $Prov.PackageName 
                    }
                }
            }

            # 2. Get AppX Package for current user / all users
            if ($IsAdmin) {
                $Packages = Get-AppxPackage -AllUsers -Name "*$App*"
            }
            else {
                $Packages = Get-AppxPackage -User $UserName -Name "*$App*"
            }

            if (-not $Packages) {
                Write-Step -Section 'Apps' -Message (Get-I18n 'AppNotInstalled' @($App)) -Level Skip
                continue
            }

            foreach ($Pkg in $Packages) {
                if ($IsAdmin) {
                    Remove-AppxPackage -Package $Pkg.PackageFullName -AllUsers 
                }
                else {
                    Remove-AppxPackage -Package $Pkg.PackageFullName -User $UserName
                }
            }

            Write-Step -Section 'Apps' -Message (Get-I18n 'AppRemoved' @($App)) -Level Success
        }
        catch {
            Write-Step -Section 'Apps' -Message (Get-I18n 'AppRemoveFailed' @($App, $_)) -Level Error
        }
    }
}

Export-ModuleMember -Function Remove-ResolvedWindowsApps