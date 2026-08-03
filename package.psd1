<#
PACKAGE ARCHIVE
===============
This file defines package aliases. To use an entry, add its key to the
Packages list in a profile or template:

    Packages = @('git', 'benimProgramim')

Example entry:

    benimProgramim = @{
        Id             = 'Yayinci.ProgramKimligi'
        PackageManager = 'winget'
        interactive    = $false
        enabled        = $true
    }

Fields:
  Id             : Package identifier/name used by the package manager.
  PackageManager : Must be 'winget', 'chocolatey', or 'npm'. Chocolatey runs
                   during the elevated phase; winget and npm run as the user.
  interactive    : Optional (default: $false). Adds --interactive for winget
                   only; set to $true when package setup needs user input.
  enabled        : $true enables the entry; $false skips it.

Verify package identifiers with winget search <name>, choco search <name>, or
npm search <name>. Each key must be unique; use a short alias without spaces.
#>
@{
    git                 = @{
        Id             = "Git.Git"
        PackageManager = "winget"
        interactive    = $true
        enabled        = $true
    }

    gitlfs              = @{
        Id             = "GitHub.GitLFS"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }
    gitlab              = @{
        Id             = "GLab.GLab"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    github              = @{
        Id             = "GitHub.cli"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    gpg4win             = @{
        Id             = "GnuPG.Gpg4win"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    gpg                 = @{
        Id             = "GnuPG.GnuPG"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    pwsh                = @{
        Id             = "Microsoft.PowerShell"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    ohmyposh            = @{
        Id             = "JanDeDobbeleer.OhMyPosh"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }    

    sysinternals        = @{
        Id             = "Microsoft.Sysinternals.Suite"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    fastfetch           = @{
        Id             = "Fastfetch-cli.Fastfetch"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }
    bulkCrapUninstaller = @{
        Id             = "Klocman.BulkCrapUninstaller"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }
    jdkLatest           = @{
        Id             = "Microsoft.OpenJDK.25"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }
    jdk8                = @{
        Id             = "EclipseAdoptium.Temurin.8.JDK"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }
    myasus              = @{
        Id             = "9N7R5S6B0ZZH"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }
    glidex              = @{
        Id             = "9PLH2SV1DVK5"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }
    armourycrate        = @{
        Id             = "Asus.ArmouryCrate"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    protonAuthenticator = @{
        Id             = "Proton.ProtonAuthenticator"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }
    brave               = @{
        Id             = "Brave.Brave"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    sevenzip            = @{
        Id             = "7zip.7zip"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    nanazip             = @{
        Id             = "M2Team.NanaZip"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    filelight           = @{
        Id             = "KDE.Filelight"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    wireguard           = @{
        Id             = "WireGuard.WireGuard"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    warp                = @{
        Id             = "Cloudflare.Warp"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    wsl                 = @{
        Id             = "9P9TQF7MRM4R"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    icloud              = @{
        Id             = "9PKTQ5699M62"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    itunes              = @{
        Id             = "9PB2MZ1ZMB1S"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    appleDevice         = @{
        Id             = "9NP83LWLPZ9K"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    appleMusic          = @{
        Id             = "9PFHDD62MXS1"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    appleTv             = @{
        Id             = "9NM4T8B9JQZ1"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }


    steam               = @{
        Id             = "Valve.Steam"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    heroicGamesLauncher = @{
        Id             = "HeroicGamesLauncher.HeroicGamesLauncher"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    epicGames           = @{
        Id             = "EpicGames.EpicGamesLauncher"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    prismLauncher       = @{
        Id             = "PrismLauncher.PrismLauncher"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    hpsmart             = @{
        Id             = "9WZDNCRFHWLH"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    rustdesk            = @{
        Id             = "RustDesk.RustDesk"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    droidcam            = @{
        Id             = "dev47apps.DroidCam"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    kdeconnect          = @{
        Id             = "9N93MRMSXBF0"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    whatsapp            = @{
        Id             = "9NKSQGP7F2NH"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    unigram             = @{
        Id             = "9N97ZCKPD60Q"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    discord             = @{
        Id             = "Discord.Discord"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    element             = @{
        Id             = "Element.Element"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    libreoffice         = @{
        Id             = "TheDocumentFoundation.LibreOffice"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    powertoys           = @{
        Id             = "Microsoft.PowerToys"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    obs                 = @{
        Id             = "OBSProject.OBSStudio"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    kdenlive            = @{
        Id             = "KDE.Kdenlive"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    gdrive              = @{
        Id             = "Google.GoogleDrive"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }


    kate                = @{
        Id             = "9NWMW7BB59HW"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    obsidian            = @{
        Id             = "Obsidian.Obsidian"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    vscode              = @{
        Id             = "Microsoft.VisualStudioCode"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    jbtoolbox           = @{
        Id             = "JetBrains.Toolbox"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    nodejs              = @{
        Id             = "OpenJS.NodeJS"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    docker              = @{
        Id             = "Docker.DockerDesktop"
        PackageManager = "winget"
        interactive    = $false
        enabled        = $true
    }

    adminCenter         = @{
        Id             = "Microsoft.WindowsAdminCenter"
        PackageManager = "winget"
        interactive    = $true
        enabled        = $true
    }

    winbtrfs            = @{
        Id             = "winbtrfs"
        PackageManager = "chocolatey"
        enabled        = $true
    }

    meslofont           = @{
        Id             = "nerd-fonts-meslo"
        PackageManager = "chocolatey"
        enabled        = $true
    }
    choco               = @{
        Id             = "Chocolatey.Chocolatey"
        PackageManager = "winget"
        enabled        = $true
    }

    blip                = @{
        Id             = "9N7JSXC1SJK6"
        PackageManager = "winget"
        enabled        = $true
    }

    windowsill          = @{
        Id             = "9PG6CJPXTPZ0"
        PackageManager = "winget"
        enabled        = $true
    }

    espanso             = @{
        Id             = "Espanso.Espanso"
        PackageManager = "winget"
        enabled        = $true
    }

    scolect             = @{
        Id             = "9PHBZXNPVHSQ"
        PackageManager = "winget"
        enabled        = $true
    }
}
