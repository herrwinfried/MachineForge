# MachineForge Configuration Reference Manual

**Architecture, Profile Specification, and Component Reference for MachineForge Engine**

This document serves as the complete technical manual for configuring, extending, and maintaining MachineForge environment states. MachineForge decouples workstation state definitions (`.psd1`) from Windows execution logic (`.psm1`), enabling modular, declarative, and repeatable workstation provisioning.

---

## 1. System Requirements & Execution Environment

MachineForge target environments must satisfy the following baseline specifications:

- **Operating System**: Windows 11 Pro (Build **26200** or higher).
- **Execution Engine**: **PowerShell Core 7.6.4+** (`pwsh`).
- **Default Profile**: [`Profile/asuswindows11.psd1`](../Profile/asuswindows11.psd1)
- **Target Hardware Specifications**:
  - **Board Vendor**: `ASUSTeK COMPUTER INC.`
  - **System Model**: `ASUS TUF Gaming F15 FX506HC_FX506HC` *(or compatible system)*
- **Script Execution Policy**: `RemoteSigned` or `Unrestricted` (`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`).

---

## 2. Configuration Data Files (`.psd1`) Overview

All configuration files in MachineForge are native PowerShell Data (`.psd1`) files containing static hashtables and arrays. They are strictly declarative—do not include executable code, function calls, or dynamic expressions inside `.psd1` files.

| File Path | Functional Role | Key Structure / Top-Level Schema |
| --- | --- | --- |
| `Profile/*.psd1` | Machine-specific target profile & hardware constraints | `Name`, `MinimumBuild`, `MaximumBuild`, `Variables`, `Hardware`, `Templates`, plus merged keys |
| `Templates/*.psd1` | Reusable software & system configuration groups | `Packages`, `Npm`, `Registry`, `Features`, `WindowsCapabilities`, `RemoveApps`, `Exec`, `Variables` |
| `package.psd1` | Global package archive catalog | package alias → `Id`, `PackageManager`, `enabled`, optional `interactive` |
| `registry.psd1` | Global registry tweak archive catalog | registry alias → `Path`, `Name`, `Value`, optional `Type`, `RequiresAdministrator` |
| `firewall.psd1` | Global Windows Defender Firewall archive catalog | rule alias → `DisplayName`, `Enabled`, `Profile`, `Direction`, `Action`, `Protocol`, `LocalPort` |
| `lang/*.psd1` | Internationalization (i18n) localization dictionaries | translation key → localized string |

---

## 3. Detailed Profile Analysis (`asuswindows11.psd1`)

The primary reference profile is defined in `Profile/asuswindows11.psd1`:

```powershell
@{
    Name         = @('Microsoft Windows 11 Pro')
    MinimumBuild = 26200
    MaximumBuild = $null

    Variables    = @{ 
        ComputerName = 'HR-WINFRIED' 
    }

    Hardware     = @{
        RequireModels       = $false
        RequireBoardVendors = $false
        Models              = @('ASUS TUF Gaming F15 FX506HC_FX506HC')
        BoardVendors        = @('ASUSTeK COMPUTER INC.')
    }

    Templates    = @(
        'basic'
        'asus'
        'apple'
        'desktop'
        'developer'
        'communication'
        'gaming'
    )

    Exec         = @{
        Command = @(
            @{
                Shell                 = 'cmd'
                Command               = 'sudo config --enable forceNewWindow'
                RequiresAdministrator = $true
            }
            @{
                Shell                 = 'cmd'
                Command               = 'powercfg /hibernate on'
                RequiresAdministrator = $true
            }
        )
    }
}
```

### Template Inheritance Chain

When `asuswindows11` is executed, MachineForge merges templates sequentially in the exact order listed (`basic` → `asus` → `apple` → `desktop` → `developer` → `communication` → `gaming`), followed by the profile's own inline definitions. List items are deduplicated while preserving first-occurrence precedence.

---

## 4. Reusable Software Templates (`Templates/*.psd1`)

MachineForge includes pre-configured modular templates for targeted software suites:

- **`basic.psd1`**: Foundational system packages and utilities.
- **`asus.psd1`**: ASUS hardware management tools and drivers.
- **`apple.psd1`**: Apple software suite & device drivers.
- **`desktop.psd1`**: Desktop UI tweaks, explorer configurations, and shell customizations.
- **`developer.psd1`**: Developer toolchains, runtimes, Git, VS Code, Docker, and command-line utilities.
- **`communication.psd1`**: Collaboration platforms (Slack, Teams, Discord, Zoom).
- **`gaming.psd1`**: Gaming clients and graphics runtime optimizations.

---

## 5. Global Package, Registry, and Firewall Archives

### Package Archive (`package.psd1`)

Package definitions unify package managers under stable short aliases:

```powershell
# Winget Package (User Phase)
vscode = @{
    Id             = 'Microsoft.VisualStudioCode'
    PackageManager = 'winget'
    interactive    = $false
    enabled        = $true
}

# Chocolatey Package (Elevated Phase)
nvm = @{
    Id             = 'nvm'
    PackageManager = 'chocolatey'
    enabled        = $true
}

# Global NPM Package (User Phase)
codex = @{
    Id             = '@openai/codex'
    PackageManager = 'npm'
    enabled        = $true
}
```

### Registry Archive (`registry.psd1`)

Registry modifications target `HKCU` or `HKLM` hives:

```powershell
ShowFileExtensions = @{
    Path                  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Name                  = 'HideFileExt'
    Value                 = 0
    Type                  = 'DWord'
    RequiresAdministrator = $false
}
```

### Firewall Archive (`firewall.psd1`)

Windows Defender Firewall rules target specific ports or dynamic variables:

```powershell
BlockCustomPort = @{
    DisplayName = 'Block Custom Application Port'
    Enabled     = $true
    Profile     = @('Domain', 'Private', 'Public')
    Direction   = 'Inbound'
    Action      = 'Block'
    Protocol    = 'TCP'
    LocalPort   = 'CustomPort' # References Variables.CustomPort from profile/template
}
```

---

## 6. Execution Engine (`Exec`) & Path Substitutions

The `Exec` block in profiles or templates manages custom system actions. Two path placeholders are automatically expanded before execution:

| Placeholder | Resolution Context | Example Output |
| --- | --- | --- |
| `HOME` | Active user's profile directory (`$env:USERPROFILE`) | `C:\Users\winfried` |
| `SCRIPTDIR` | Root folder containing `Invoke-Setup.ps1` | `C:\source\machineforge` |

### Supported `Exec` Actions

```powershell
Exec = @{
    # Directory creation
    Mkdir = @(
        'HOME\Tools'
        'HOME\Projects'
    )

    # File / Directory copying
    Copy = @(
        @{ source = 'SCRIPTDIR\data\home'; target = 'HOME' }
    )

    # Remote file download
    DownloadFile = @(
        @{
            url          = 'https://example.com/tool.zip'
            target       = 'HOME\Downloads'
            fullFileName = 'tool.zip'
        }
    )

    # Application Installers (.appinstaller / .msix / .appx)
    AppInstaller = @(
        @{ source = 'SCRIPTDIR\Installers\App.appinstaller' }
    )

    # Shell Command Execution
    Command = @(
        @{
            Shell                 = 'cmd' # 'pwsh', 'powershell', or 'cmd'
            Command               = 'powercfg /hibernate on'
            RequiresAdministrator = $true
        }
    )
}
```

---

## 7. AppX Debloating Engine (`RemoveApps`)

Unwanted Windows AppX / MSIX bloatware packages can be targeted for automated removal:

```powershell
RemoveApps = @(
    'Microsoft.BingNews'
    'Microsoft.GamingApp'
    'Microsoft.GetHelp'
    'Microsoft.ZuneVideo'
)
```

- **Non-Elevated Phase**: Executes `Remove-AppxPackage` for the current user profile.
- **Elevated Phase**: Executes `Remove-AppxProvisionedPackage -Online` to remove provisioned packages from the OS image.

---

## 8. Internationalization Engine (`lang/*.psd1`)

MachineForge uses a dynamic localization loader (`modules/i18n.psm1`):

1. **Auto-Detection**: Queries `[System.Globalization.CultureInfo]::CurrentUICulture.Name` on startup.
2. **Dictionary Matching**: Automatically checks `lang/<culture_code>.psd1` (e.g., `lang/en-US.psd1`, `lang/tr-TR.psd1`).
3. **Extensibility**: Adding support for a new culture (e.g., `de-DE.psd1`) requires only placing a valid dictionary file into `lang/`. No codebase modifications are needed.

---

## 9. Phased Execution Architecture

To minimize Administrative UAC prompts, MachineForge executes in two distinct phases:

```
                  ┌───────────────────────────────┐
                  │      Invoke-Setup.ps1         │
                  └──────────────┬────────────────┘
                                 │
                 [System & Hardware Inspection]
                 [Profile Match & Template Merge]
                                 │
        ┌────────────────────────┴────────────────────────┐
        │                                                 │
┌───────▼────────────────────────┐      ┌─────────────────▼─────────────────┐
│ Phase 1: Non-Elevated Session │      │ Phase 2: Consolidated Elevation   │
├────────────────────────────────┤      ├───────────────────────────────────┤
│ • HKCU Registry Tweaks         │      │ • HKLM Policy Registry Tweaks     │
│ • Winget Package Installs      │      │ • Chocolatey Package Installs     │
│ • NPM Global Packages          │      │ • Firewall Rule Configuration     │
│ • User AppX Package Removal    │      │ • Windows Features & Capabilities │
│ • User Exec Tasks (Mkdir, Copy)│      │ • Provisioned AppX Bloat Removal  │
└────────────────────────────────┘      │ • Elevated Exec Commands & Rename │
                                        └───────────────────────────────────┘
```

---

## 10. Operational Best Practices

1. **Always Preview with `-WhatIf`**: Perform a dry-run prior to executing on production systems:
   ```powershell
   pwsh .\Invoke-Setup.ps1 -ProfileName asuswindows11 -WhatIf
   ```
2. **Inspect Log Files**: Logs are written with microsecond precision to `logs/YYYYMMDD-HHmmss.log`.
3. **Keep Data Files Declarative**: Never inject logic or variable expressions into `.psd1` configuration files.
