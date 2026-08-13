# MachineForge Configuration Reference Manual

**Architecture, Profile Specification, and Component Reference for the MachineForge Tool**

This document serves as the complete technical manual for configuring, extending, and maintaining MachineForge environment states.

[!NOTE]
This reference currently documents the Windows implementation (windows branch), which targets Windows PowerShell 5.1. Future platform-specific branches may use different runtimes, scripting languages, configuration structures, and implementation conventions. MachineForge decouples workstation state definitions (`.psd1`) from Windows execution logic (`.psm1`), enabling modular, declarative, and repeatable workstation provisioning.

---

## 1. System Requirements & Execution Environment

MachineForge target environments must satisfy the following baseline specifications:

* **Operating System**: Windows 11 Pro (Build **26200** or higher).
* **PowerShell**: Windows PowerShell 5.1.
* **Default Profile**: [`Profile/asuswindows11.psd1`](../Profile/asuswindows11.psd1)
* **Target Hardware Specifications**:

  * **Board Vendor**: `ASUSTeK COMPUTER INC.`
  * **System Model**: `ASUS TUF Gaming F15 FX506HC_FX506HC` *(or compatible system)*
* **Script Execution Policy**: `RemoteSigned` or `Unrestricted`.

Enable the recommended execution policy for the current user with:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

> [!IMPORTANT]
> MachineForge currently targets **Windows PowerShell 5.1**. PowerShell 7 (`pwsh`) is not currently a supported runtime.

---

## 2. Configuration Data Files (`.psd1`) Overview

All configuration files in MachineForge are native PowerShell Data (`.psd1`) files containing static hashtables and arrays.

They are strictly declarative. Do not include executable code, function calls, or dynamic expressions inside `.psd1` files.

| File Path          | Functional Role                                          | Key Structure / Top-Level Schema                                                                                                                                                                                       |
| ------------------ | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Profile/*.psd1`   | Machine-specific target profile and hardware constraints | `Name`, `MinimumBuild`, `MaximumBuild`, `Variables`, `Hardware`, `Templates`, plus configuration keys                                                                                                                  |
| `Templates/*.psd1` | Reusable software and system configuration groups        | `Packages`, `UninstallPackages`, `Npm`, `UninstallNpm`, `Registry`, `Firewall`, `RemoveFirewall`, `Features`, `DisableFeatures`, `WindowsCapabilities`, `RemoveWindowsCapabilities`, `RemoveApps`, `Exec`, `Variables` |
| `package.psd1`     | Global package archive catalog                           | Package alias → `Id`, `PackageManager`, `enabled`, optional `interactive`                                                                                                                                              |
| `registry.psd1`    | Global registry tweak archive catalog                    | Registry alias → `Path`, `Name`, `Value`, optional `Type`, `RequiresAdministrator`                                                                                                                                     |
| `firewall.psd1`    | Global Windows Defender Firewall archive catalog         | Rule alias → `DisplayName`, `Enabled`, `Profile`, `Direction`, `Action`, `Protocol`, `LocalPort`                                                                                                                       |
| `lang/*.psd1`      | Internationalization localization dictionaries           | Translation key → localized string                                                                                                                                                                                     |

---

# 3. Configuration Schema

MachineForge normalizes profile and template data into a common configuration structure before execution.

The complete internal configuration model is:

```powershell
$Config = @{
    ComputerName              = $null

    Packages                  = [System.Collections.Generic.List[string]]::new()
    UninstallPackages         = [System.Collections.Generic.List[string]]::new()

    Npm                       = [System.Collections.Generic.List[string]]::new()
    UninstallNpm              = [System.Collections.Generic.List[string]]::new()

    Registry                  = [System.Collections.Generic.List[string]]::new()

    Firewall                  = [System.Collections.Generic.List[string]]::new()
    RemoveFirewall            = [System.Collections.Generic.List[string]]::new()

    Features                  = [System.Collections.Generic.List[string]]::new()
    DisableFeatures           = [System.Collections.Generic.List[string]]::new()

    WindowsCapabilities       = [System.Collections.Generic.List[string]]::new()
    RemoveWindowsCapabilities = [System.Collections.Generic.List[string]]::new()

    RemoveApps                = [System.Collections.Generic.List[string]]::new()

    Variables                 = @{}

    Exec                      = @{
        Mkdir        = [System.Collections.Generic.List[string]]::new()
        Copy         = [System.Collections.Generic.List[hashtable]]::new()
        DownloadFile = [System.Collections.Generic.List[hashtable]]::new()
        AppInstaller = [System.Collections.Generic.List[hashtable]]::new()
        Command      = [System.Collections.Generic.List[hashtable]]::new()
    }
}
```

### Top-Level Configuration Keys

| Key                         | Type           | Description                                      |
| --------------------------- | -------------- | ------------------------------------------------ |
| `ComputerName`              | `string`       | Target computer name                             |
| `Packages`                  | `List[string]` | Package aliases to install                       |
| `UninstallPackages`         | `List[string]` | Package aliases to remove                        |
| `Npm`                       | `List[string]` | Global NPM package aliases to install            |
| `UninstallNpm`              | `List[string]` | Global NPM package aliases to remove             |
| `Registry`                  | `List[string]` | Registry aliases to apply                        |
| `Firewall`                  | `List[string]` | Firewall rule aliases to create or configure     |
| `RemoveFirewall`            | `List[string]` | Firewall rule aliases to remove                  |
| `Features`                  | `List[string]` | Windows optional features to enable              |
| `DisableFeatures`           | `List[string]` | Windows optional features to disable             |
| `WindowsCapabilities`       | `List[string]` | Windows capabilities to install                  |
| `RemoveWindowsCapabilities` | `List[string]` | Windows capabilities to remove                   |
| `RemoveApps`                | `List[string]` | AppX/MSIX applications to remove                 |
| `Variables`                 | `Hashtable`    | Variables available to configuration definitions |
| `Exec`                      | `Hashtable`    | Custom execution actions                         |

The configuration keys are intentionally symmetrical where possible:

```text
Packages                  ↔ UninstallPackages
Npm                       ↔ UninstallNpm
Firewall                  ↔ RemoveFirewall
Features                  ↔ DisableFeatures
WindowsCapabilities       ↔ RemoveWindowsCapabilities
```

This allows both the desired installation/enabled state and removal/disabled state to be represented declaratively.

---

# 4. Detailed Profile Analysis (`asuswindows11.psd1`)

The primary reference profile is defined in `Profile/asuswindows11.psd1`:

```powershell
@{
    Name         = @('Microsoft Windows 11 Pro')
    MinimumBuild = 26200
    MaximumBuild = $null

    Variables = @{
        ComputerName = 'HR-WINFRIED'
    }

    Hardware = @{
        RequireModels       = $false
        RequireBoardVendors = $false
        Models              = @(
            'ASUS TUF Gaming F15 FX506HC_FX506HC'
        )
        BoardVendors        = @(
            'ASUSTeK COMPUTER INC.'
        )
    }

    Templates = @(
        'basic'
        'asus'
        'apple'
        'desktop'
        'developer'
        'communication'
        'gaming'
    )

    Exec = @{
        Command = @(
            @{
                Shell                 = 'cmd'
                Command               = 'sudo config --enable forceNewWindow'
                RequiresAdministrator = $true
            }
            @{
                Shell                 = 'cmd'
                Command               = 'powercfg /hibernate on'
                RequiresAdministrator = $true
            }
        )
    }
}
```

The profile contains both machine-selection information and machine-specific configuration.

### 4.1 `Name`

Defines the operating system name or names targeted by the profile.

```powershell
Name = @(
    'Microsoft Windows 11 Pro'
)
```

### 4.2 `MinimumBuild`

Defines the minimum supported Windows build.

```powershell
MinimumBuild = 26200
```

### 4.3 `MaximumBuild`

Defines an optional maximum Windows build.

Use `$null` when no maximum build is required.

```powershell
MaximumBuild = $null
```

### 4.4 `Variables`

Defines profile-specific variables.

```powershell
Variables = @{
    ComputerName = 'HR-WINFRIED'
}
```

Variables can also be consumed by other configuration components, such as firewall definitions.

### 4.5 `Hardware`

Defines hardware matching information.

```powershell
Hardware = @{
    RequireModels       = $false
    RequireBoardVendors = $false

    Models = @(
        'ASUS TUF Gaming F15 FX506HC_FX506HC'
    )

    BoardVendors = @(
        'ASUSTeK COMPUTER INC.'
    )
}
```

### 4.6 `Templates`

Defines reusable templates that should be merged into the profile.

```powershell
Templates = @(
    'basic'
    'asus'
    'apple'
    'desktop'
    'developer'
    'communication'
    'gaming'
)
```

### 4.7 Profile-Level Configuration

A profile may also contain the same configuration keys used by templates.

For example:

```powershell
@{
    Templates = @(
        'basic'
        'developer'
    )

    Packages = @(
        'vscode'
        'git'
    )

    Registry = @(
        'ShowFileExtensions'
    )
}
```

This allows machine-specific settings to be defined directly in the profile.

---

# 5. Template Inheritance Chain

When `asuswindows11` is executed, MachineForge merges templates sequentially in the exact order specified by the profile:

```text
basic
  ↓
asus
  ↓
apple
  ↓
desktop
  ↓
developer
  ↓
communication
  ↓
gaming
  ↓
Profile-specific configuration
```

List items are deduplicated while preserving first-occurrence precedence.

This allows reusable configuration to remain in templates while machine-specific settings can be added at the profile level.

---

# 6. Reusable Software Templates (`Templates/*.psd1`)

MachineForge includes pre-configured modular templates for targeted software suites:

* **`basic.psd1`**: Foundational system packages and utilities.
* **`asus.psd1`**: ASUS hardware management tools and drivers.
* **`apple.psd1`**: Apple software suite and device drivers.
* **`desktop.psd1`**: Desktop UI tweaks, Explorer configurations, and shell customizations.
* **`developer.psd1`**: Developer toolchains, runtimes, Git, VS Code, Docker, and command-line utilities.
* **`communication.psd1`**: Collaboration platforms such as Slack, Teams, Discord, and Zoom.
* **`gaming.psd1`**: Gaming clients and graphics runtime optimizations.

A template can contain any supported configuration key.

Example:

```powershell
@{
    Packages = @(
        'git'
        'vscode'
    )

    Npm = @(
        'codex'
    )

    Registry = @(
        'ShowFileExtensions'
    )

    Features = @(
        'Microsoft-Windows-Subsystem-Linux'
    )
}
```

---

# 7. Package Management

MachineForge provides separate declarative operations for package installation and removal.

```text
Packages
    │
    └── Install packages

UninstallPackages
    │
    └── Remove packages

Npm
    │
    └── Install global NPM packages

UninstallNpm
    │
    └── Remove global NPM packages
```

---

## 7.1 Package Installation (`Packages`)

`Packages` defines package aliases that should be installed.

```powershell
Packages = @(
    'vscode'
    'git'
    '7zip'
)
```

The entries reference package aliases defined in `package.psd1`.

For example:

```powershell
Packages = @(
    'vscode'
    'nvm'
)
```

---

## 7.2 Package Removal (`UninstallPackages`)

`UninstallPackages` defines package aliases that should be removed.

```powershell
UninstallPackages = @(
    'some-package'
    'another-package'
)
```

For example:

```powershell
UninstallPackages = @(
    'vlc'
    '7zip'
)
```

The entries reference package aliases defined in `package.psd1`.

This allows package removal to be represented independently from package installation.

A configuration can therefore contain both:

```powershell
Packages = @(
    'vscode'
    'git'
)

UninstallPackages = @(
    'legacy-editor'
)
```

---

## 7.3 NPM Package Installation (`Npm`)

`Npm` defines global NPM package aliases that should be installed.

```powershell
Npm = @(
    'codex'
)
```

Multiple packages can be specified:

```powershell
Npm = @(
    'codex'
    'typescript'
    'eslint'
)
```

The aliases reference package definitions in `package.psd1`.

---

## 7.4 NPM Package Removal (`UninstallNpm`)

`UninstallNpm` defines global NPM package aliases that should be removed.

```powershell
UninstallNpm = @(
    'some-package'
    'another-package'
)
```

For example:

```powershell
UninstallNpm = @(
    'old-cli'
    'deprecated-tool'
)
```

This provides the removal counterpart to `Npm`.

A profile may therefore define:

```powershell
Npm = @(
    'codex'
)

UninstallNpm = @(
    'old-cli'
)
```

---

## 7.5 Package Archive (`package.psd1`)

Package definitions unify different package managers under stable short aliases.

```powershell
# Winget Package
vscode = @{
    Id             = 'Microsoft.VisualStudioCode'
    PackageManager = 'winget'
    interactive    = $false
    enabled        = $true
}

# Chocolatey Package
nvm = @{
    Id             = 'nvm'
    PackageManager = 'chocolatey'
    enabled        = $true
}

# Global NPM Package
codex = @{
    Id             = '@openai/codex'
    PackageManager = 'npm'
    enabled        = $true
}
```

### Package Properties

| Property         | Description                                           |
| ---------------- | ----------------------------------------------------- |
| `Id`             | Package identifier passed to the package manager      |
| `PackageManager` | Package manager used for the package                  |
| `enabled`        | Determines whether the package definition is active   |
| `interactive`    | Determines whether installation uses interactive mode |

Supported package managers include:

* `winget`
* `chocolatey`
* `npm`

---

# 8. Registry Configuration

## 8.1 Registry (`Registry`)

`Registry` defines registry aliases that should be applied.

```powershell
Registry = @(
    'ShowFileExtensions'
)
```

Multiple registry definitions can be specified:

```powershell
Registry = @(
    'ShowFileExtensions'
    'DisableWidgets'
    'EnableLongPaths'
)
```

The aliases reference definitions in `registry.psd1`.

---

## 8.2 Registry Archive (`registry.psd1`)

Registry modifications target `HKCU` or `HKLM` hives.

```powershell
ShowFileExtensions = @{
    Path                 = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Name                 = 'HideFileExt'
    Value                = 0
    Type                 = 'DWord'
    RequiresAdministrator = $false
}
```

### Registry Properties

| Property                | Description                                              |
| ----------------------- | -------------------------------------------------------- |
| `Path`                  | Registry key path                                        |
| `Name`                  | Registry value name                                      |
| `Value`                 | Value to apply                                           |
| `Type`                  | Registry value type                                      |
| `RequiresAdministrator` | Determines whether Administrator privileges are required |

Registry aliases are then referenced from profiles or templates:

```powershell
Registry = @(
    'ShowFileExtensions'
)
```

---

# 9. Firewall Configuration

## 9.1 Firewall (`Firewall`)

`Firewall` defines firewall rule aliases that should be created or configured.

```powershell
Firewall = @(
    'BlockCustomPort'
)
```

Multiple rules can be specified:

```powershell
Firewall = @(
    'BlockCustomPort'
    'AllowSSH'
    'BlockLegacyApplication'
)
```

---

## 9.2 Remove Firewall Rules (`RemoveFirewall`)

`RemoveFirewall` defines firewall rule aliases that should be removed.

```powershell
RemoveFirewall = @(
    'OldFirewallRule'
    'UnusedFirewallRule'
)
```

For example:

```powershell
RemoveFirewall = @(
    'BlockCustomPort'
    'LegacyApplicationRule'
)
```

The entries reference firewall rule aliases defined in `firewall.psd1`.

This allows firewall configuration and cleanup to be expressed independently:

```powershell
Firewall = @(
    'AllowRequiredApplication'
)

RemoveFirewall = @(
    'LegacyApplicationRule'
)
```

---

## 9.3 Firewall Archive (`firewall.psd1`)

Windows Defender Firewall rules target specific ports or dynamic variables.

```powershell
BlockCustomPort = @{
    DisplayName = 'Block Custom Application Port'
    Enabled     = $true
    Profile     = @(
        'Domain'
        'Private'
        'Public'
    )
    Direction   = 'Inbound'
    Action      = 'Block'
    Protocol    = 'TCP'
    LocalPort   = 'CustomPort'
}
```

### Firewall Properties

| Property      | Description                                    |
| ------------- | ---------------------------------------------- |
| `DisplayName` | Display name of the firewall rule              |
| `Enabled`     | Determines whether the rule is enabled         |
| `Profile`     | Windows Firewall profiles targeted by the rule |
| `Direction`   | Traffic direction                              |
| `Action`      | Firewall action such as `Allow` or `Block`     |
| `Protocol`    | Network protocol                               |
| `LocalPort`   | Local port targeted by the rule                |

### Firewall Variable Example

A firewall definition can reference a variable:

```powershell
BlockCustomPort = @{
    DisplayName = 'Block Custom Application Port'
    Enabled     = $true
    Profile     = @(
        'Domain'
        'Private'
        'Public'
    )
    Direction = 'Inbound'
    Action    = 'Block'
    Protocol  = 'TCP'
    LocalPort = 'CustomPort'
}
```

The corresponding profile/template can define:

```powershell
Variables = @{
    CustomPort = 25565
}
```

---

# 10. Windows Optional Features

## 10.1 Enable Features (`Features`)

`Features` defines Windows optional features that should be enabled.

```powershell
Features = @(
    'Microsoft-Windows-Subsystem-Linux'
)
```

Multiple features can be specified:

```powershell
Features = @(
    'Microsoft-Windows-Subsystem-Linux'
    'VirtualMachinePlatform'
)
```

---

## 10.2 Disable Features (`DisableFeatures`)

`DisableFeatures` defines Windows optional features that should be disabled.

```powershell
DisableFeatures = @(
    'Some-Windows-Feature'
    'Another-Windows-Feature'
)
```

For example:

```powershell
DisableFeatures = @(
    'WorkFolders-Client'
    'Some-Optional-Feature'
)
```

This provides the inverse operation of `Features`.

A configuration can contain both:

```powershell
Features = @(
    'Microsoft-Windows-Subsystem-Linux'
    'VirtualMachinePlatform'
)

DisableFeatures = @(
    'Some-Unwanted-Feature'
)
```

The entries represent the desired feature operations for the target workstation.

---

# 11. Windows Capabilities

## 11.1 Install Capabilities (`WindowsCapabilities`)

`WindowsCapabilities` defines Windows capabilities that should be installed.

```powershell
WindowsCapabilities = @(
    'OpenSSH.Client~~~~0.0.1.0'
)
```

Multiple capabilities can be specified:

```powershell
WindowsCapabilities = @(
    'OpenSSH.Client~~~~0.0.1.0'
    'OpenSSH.Server~~~~0.0.1.0'
)
```

---

## 11.2 Remove Capabilities (`RemoveWindowsCapabilities`)

`RemoveWindowsCapabilities` defines Windows capabilities that should be removed.

```powershell
RemoveWindowsCapabilities = @(
    'Some-Capability~~~~0.0.1.0'
    'Another-Capability~~~~0.0.1.0'
)
```

For example:

```powershell
RemoveWindowsCapabilities = @(
    'OpenSSH.Client~~~~0.0.1.0'
)
```

This provides the removal counterpart to `WindowsCapabilities`.

A configuration can therefore express both operations:

```powershell
WindowsCapabilities = @(
    'OpenSSH.Server~~~~0.0.1.0'
)

RemoveWindowsCapabilities = @(
    'Some-Unwanted-Capability~~~~0.0.1.0'
)
```

---

# 12. AppX / MSIX Debloating (`RemoveApps`)

Unwanted Windows AppX / MSIX packages can be targeted for automated removal.

```powershell
RemoveApps = @(
    'Microsoft.BingNews'
    'Microsoft.GamingApp'
    'Microsoft.GetHelp'
    'Microsoft.ZuneVideo'
)
```

A larger example:

```powershell
RemoveApps = @(
    'Microsoft.BingNews'
    'Microsoft.GamingApp'
    'Microsoft.GetHelp'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.ZuneVideo'
)
```

MachineForge processes AppX removal in separate user and elevated phases.

* **Non-Elevated Phase**: Executes `Remove-AppxPackage` for the current user profile.
* **Elevated Phase**: Executes `Remove-AppxProvisionedPackage -Online` to remove provisioned packages from the OS image.

---

# 13. Variables

`Variables` provides reusable values that can be consumed by configuration definitions.

Example:

```powershell
Variables = @{
    ComputerName = 'HR-WINFRIED'
    CustomPort   = 25565
}
```

Multiple variables can be defined:

```powershell
Variables = @{
    ComputerName = 'HR-WINFRIED'
    CustomPort   = 25565
    ToolsPath    = 'HOME\Tools'
}
```

Variables can be referenced by supported configuration components.

For example, the firewall archive can use:

```powershell
LocalPort = 'CustomPort'
```

while the profile or template provides:

```powershell
Variables = @{
    CustomPort = 25565
}
```

---

# 14. Execution Engine (`Exec`) & Path Substitutions

The `Exec` block in profiles or templates manages custom system actions.

The supported execution actions are:

```text
Exec
├── Mkdir
├── Copy
├── DownloadFile
├── AppInstaller
└── Command
```

MachineForge automatically expands the following path placeholders before execution:

| Placeholder | Resolution Context                                   | Example Output           |
| ----------- | ---------------------------------------------------- | ------------------------ |
| `HOME`      | Active user's profile directory (`$env:USERPROFILE`) | `C:\Users\winfried`      |
| `SCRIPTDIR` | Root folder containing `Invoke-Setup.ps1`            | `C:\source\machineforge` |

---

## 14.1 `Exec.Mkdir`

Creates directories.

```powershell
Exec = @{
    Mkdir = @(
        'HOME\Tools'
        'HOME\Projects'
    )
}
```

Multiple directories can be created:

```powershell
Exec = @{
    Mkdir = @(
        'HOME\Tools'
        'HOME\Projects'
        'HOME\Downloads'
        'HOME\Scripts'
    )
}
```

---

## 14.2 `Exec.Copy`

Copies files or directories.

```powershell
Exec = @{
    Copy = @(
        @{
            source = 'SCRIPTDIR\data\home'
            target = 'HOME'
        }
    )
}
```

Multiple copy operations can be specified:

```powershell
Exec = @{
    Copy = @(
        @{
            source = 'SCRIPTDIR\data\home'
            target = 'HOME'
        }
        @{
            source = 'SCRIPTDIR\data\config'
            target = 'HOME\Tools'
        }
    )
}
```

### Properties

| Property | Description              |
| -------- | ------------------------ |
| `source` | Source file or directory |
| `target` | Destination path         |

---

## 14.3 `Exec.DownloadFile`

Downloads a remote file.

```powershell
Exec = @{
    DownloadFile = @(
        @{
            url          = 'https://example.com/tool.zip'
            target       = 'HOME\Downloads'
            fullFileName = 'tool.zip'
        }
    )
}
```

Multiple downloads can be specified:

```powershell
Exec = @{
    DownloadFile = @(
        @{
            url          = 'https://example.com/tool.zip'
            target       = 'HOME\Downloads'
            fullFileName = 'tool.zip'
        }
        @{
            url          = 'https://example.com/config.json'
            target       = 'HOME\Tools'
            fullFileName = 'config.json'
        }
    )
}
```

### Properties

| Property       | Description           |
| -------------- | --------------------- |
| `url`          | Remote file URL       |
| `target`       | Destination directory |
| `fullFileName` | Output filename       |

---

## 14.4 `Exec.AppInstaller`

Installs application packages using an App Installer-compatible package.

Supported package types include:

* `.appinstaller`
* `.msix`
* `.appx`

Example:

```powershell
Exec = @{
    AppInstaller = @(
        @{
            source = 'SCRIPTDIR\Installers\App.appinstaller'
        }
    )
}
```

Multiple installers can be specified:

```powershell
Exec = @{
    AppInstaller = @(
        @{
            source = 'SCRIPTDIR\Installers\App1.appinstaller'
        }
        @{
            source = 'SCRIPTDIR\Installers\App2.msix'
        }
        @{
            source = 'SCRIPTDIR\Installers\App3.appx'
        }
    )
}
```

### Properties

| Property | Description                       |
| -------- | --------------------------------- |
| `source` | Path to the application installer |

---

## 14.5 `Exec.Command`

Executes a shell command.

```powershell
Exec = @{
    Command = @(
        @{
            Shell                 = 'cmd'
            Command               = 'powercfg /hibernate on'
            RequiresAdministrator = $true
        }
    )
}
```

Multiple commands can be specified:

```powershell
Exec = @{
    Command = @(
        @{
            Shell                 = 'cmd'
            Command               = 'powercfg /hibernate on'
            RequiresAdministrator = $true
        }
        @{
            Shell                 = 'powershell'
            Command               = 'Write-Host "MachineForge command"'
            RequiresAdministrator = $false
        }
    )
}
```

The supported shell values are:

```text
cmd
powershell
pwsh
```

### Properties

| Property                | Description                                              |
| ----------------------- | -------------------------------------------------------- |
| `Shell`                 | Shell used to execute the command                        |
| `Command`               | Command to execute                                       |
| `RequiresAdministrator` | Determines whether Administrator privileges are required |

---

# 15. Complete Configuration Example

The following example demonstrates how the supported configuration components can be combined in a profile or template:

```powershell
@{
    Name = @(
        'Microsoft Windows 11 Pro'
    )

    MinimumBuild = 26200
    MaximumBuild = $null

    Variables = @{
        ComputerName = 'HR-WINFRIED'
        CustomPort   = 25565
    }

    Hardware = @{
        RequireModels       = $false
        RequireBoardVendors = $false

        Models = @(
            'ASUS TUF Gaming F15 FX506HC_FX506HC'
        )

        BoardVendors = @(
            'ASUSTeK COMPUTER INC.'
        )
    }

    Templates = @(
        'basic'
        'developer'
        'gaming'
    )

    Packages = @(
        'vscode'
        'git'
    )

    UninstallPackages = @(
        'legacy-package'
    )

    Npm = @(
        'codex'
    )

    UninstallNpm = @(
        'old-cli'
    )

    Registry = @(
        'ShowFileExtensions'
    )

    Firewall = @(
        'BlockCustomPort'
    )

    RemoveFirewall = @(
        'LegacyFirewallRule'
    )

    Features = @(
        'Microsoft-Windows-Subsystem-Linux'
        'VirtualMachinePlatform'
    )

    DisableFeatures = @(
        'Some-Windows-Feature'
    )

    WindowsCapabilities = @(
        'OpenSSH.Server~~~~0.0.1.0'
    )

    RemoveWindowsCapabilities = @(
        'Some-Capability~~~~0.0.1.0'
    )

    RemoveApps = @(
        'Microsoft.BingNews'
        'Microsoft.GamingApp'
        'Microsoft.GetHelp'
    )

    Exec = @{
        Mkdir = @(
            'HOME\Tools'
            'HOME\Projects'
        )

        Copy = @(
            @{
                source = 'SCRIPTDIR\data\home'
                target = 'HOME'
            }
        )

        DownloadFile = @(
            @{
                url          = 'https://example.com/tool.zip'
                target       = 'HOME\Downloads'
                fullFileName = 'tool.zip'
            }
        )

        AppInstaller = @(
            @{
                source = 'SCRIPTDIR\Installers\App.appinstaller'
            }
        )

        Command = @(
            @{
                Shell                 = 'cmd'
                Command               = 'powercfg /hibernate on'
                RequiresAdministrator = $true
            }
        )
    }
}
```

---

# 16. Internationalization Engine (`lang/*.psd1`)

MachineForge uses a dynamic localization loader located at:

```text
modules/i18n.psm1
```

The localization process consists of three steps:

1. **Auto-Detection**: Queries `[System.Globalization.CultureInfo]::CurrentUICulture.Name` on startup.
2. **Dictionary Matching**: Automatically checks `lang/<culture_code>.psd1`, such as `lang/en-US.psd1` and `lang/tr-TR.psd1`.
3. **Extensibility**: Adding support for a new culture, such as `de-DE.psd1`, requires placing a valid dictionary file into `lang/`. No codebase modifications are required.

Example:

```text
lang/
├── en-US.psd1
├── tr-TR.psd1
└── de-DE.psd1
```

---

# 17. Phased Execution Architecture

To minimize unnecessary Administrative UAC prompts, MachineForge executes configuration in two distinct phases.

```text
                    ┌───────────────────────────────┐
                    │       Invoke-Setup.ps1        │
                    └──────────────┬────────────────┘
                                   │
                         [System & Hardware Inspection]
                         [Profile Match & Template Merge]
                                   │
          ┌────────────────────────┴────────────────────────┐
          │                                                 │
┌─────────▼──────────────────────┐          ┌───────────────▼─────────────────┐
│ Phase 1: Non-Elevated Session │          │ Phase 2: Consolidated Elevation │
├───────────────────────────────┤          ├─────────────────────────────────┤
│ • HKCU Registry Tweaks        │          │ • HKLM Policy Registry Tweaks   │
│ • Winget Package Installs     │          │ • Chocolatey Package Installs   │
│ • NPM Global Packages         │          │ • Firewall Rule Configuration   │
│ • User AppX Package Removal   │          │ • Windows Features & Capabilities│
│ • User Exec Tasks             │          │ • Provisioned AppX Removal      │
│   (Mkdir, Copy)               │          │ • Elevated Exec Commands        │
└───────────────────────────────┘          └─────────────────────────────────┘
```

MachineForge separates user-level and system-level operations to reduce unnecessary UAC prompts. The existing execution model explicitly separates non-elevated operations such as HKCU registry changes, Winget, NPM, user AppX removal, and user execution tasks from elevated operations such as HKLM registry changes, Chocolatey, firewall configuration, Windows features/capabilities, provisioned AppX removal, and elevated commands.

---

# 18. Configuration Operation Categories

MachineForge configuration keys can be grouped by the type of operation they perform.

### Installation / Enablement

```text
Packages
Npm
Registry
Firewall
Features
WindowsCapabilities
Exec
```

### Removal / Disablement

```text
UninstallPackages
UninstallNpm
RemoveFirewall
DisableFeatures
RemoveWindowsCapabilities
RemoveApps
```

This distinction is useful when reviewing a profile before execution.

For example:

```powershell
@{
    # Install / enable
    Packages = @(
        'vscode'
    )

    Npm = @(
        'codex'
    )

    Features = @(
        'Microsoft-Windows-Subsystem-Linux'
    )

    # Remove / disable
    UninstallPackages = @(
        'legacy-package'
    )

    UninstallNpm = @(
        'old-cli'
    )

    DisableFeatures = @(
        'Some-Windows-Feature'
    )

    RemoveApps = @(
        'Microsoft.BingNews'
    )
}
```

---

# 19. Configuration Precedence

MachineForge combines configuration from global definitions, templates, and profiles.

The general configuration flow is:

```text
Global Definitions
       │
       ▼
Templates
       │
       ▼
Profile
       │
       ▼
Merged Configuration
       │
       ▼
Execution Engine
```

Templates are merged sequentially according to the order specified by the profile.

Profile-specific definitions are then incorporated into the resulting configuration.

This allows common configuration to be maintained in reusable templates while machine-specific requirements remain in the target profile.

---

# 20. Operational Best Practices

## 20.1 Always Preview with `-WhatIf`

Perform a dry-run before executing configuration changes on an important system:

```powershell
.\Invoke-Setup.ps1 -ProfileName asuswindows11 -WhatIf
```

Review the output before performing the actual provisioning run.

> [!NOTE]
> `-WhatIf` should be treated as a preview mechanism for operations that support PowerShell's `ShouldProcess` / `-WhatIf` behavior.

---

## 20.2 Inspect Log Files

Execution logs are written to:

```text
logs/YYYYMMDD-HHmmss.log
```

Use these logs to investigate failures and verify executed operations.

---

## 20.3 Keep Data Files Declarative

Do not place executable logic, function calls, or dynamic expressions inside `.psd1` configuration files.

Keep configuration data separate from execution logic.

---

## 20.4 Review Removal and Disable Operations

Pay particular attention to the following configuration keys:

```text
UninstallPackages
UninstallNpm
RemoveFirewall
DisableFeatures
RemoveWindowsCapabilities
RemoveApps
```

These operations can remove software, firewall rules, Windows features, Windows capabilities, or AppX/MSIX applications.

Review these entries carefully before executing a profile.

For example:

```powershell
@{
    UninstallPackages = @(
        'legacy-package'
    )

    UninstallNpm = @(
        'old-cli'
    )

    RemoveFirewall = @(
        'LegacyFirewallRule'
    )

    DisableFeatures = @(
        'Unused-Windows-Feature'
    )

    RemoveWindowsCapabilities = @(
        'Some-Capability~~~~0.0.1.0'
    )

    RemoveApps = @(
        'Microsoft.BingNews'
    )
}
```

---

## 20.5 Use Reusable Templates

Place configuration shared across multiple machines inside `Templates/`.

Keep hardware- or machine-specific configuration inside `Profile/`.

For example:

```text
Templates/
├── basic.psd1
├── developer.psd1
└── gaming.psd1

Profile/
└── asuswindows11.psd1
```

This keeps profiles smaller and makes shared configuration easier to maintain.

---

# 21. Complete Configuration Key Reference

For quick reference, the complete top-level configuration model is:

```text
ComputerName

Packages
UninstallPackages

Npm
UninstallNpm

Registry

Firewall
RemoveFirewall

Features
DisableFeatures

WindowsCapabilities
RemoveWindowsCapabilities

RemoveApps

Variables

Exec
├── Mkdir
├── Copy
├── DownloadFile
├── AppInstaller
└── Command
```

### Configuration Key Summary

| Configuration Key           | Operation                               | Example                               |
| --------------------------- | --------------------------------------- | ------------------------------------- |
| `ComputerName`              | Target computer name                    | `ComputerName = 'WORKSTATION'`        |
| `Packages`                  | Install packages                        | `@('vscode', 'git')`                  |
| `UninstallPackages`         | Remove packages                         | `@('legacy-package')`                 |
| `Npm`                       | Install global NPM packages             | `@('codex')`                          |
| `UninstallNpm`              | Remove global NPM packages              | `@('old-cli')`                        |
| `Registry`                  | Apply registry definitions              | `@('ShowFileExtensions')`             |
| `Firewall`                  | Create/configure firewall rules         | `@('BlockCustomPort')`                |
| `RemoveFirewall`            | Remove firewall rules                   | `@('LegacyFirewallRule')`             |
| `Features`                  | Enable Windows features                 | `@('VirtualMachinePlatform')`         |
| `DisableFeatures`           | Disable Windows features                | `@('Unused-Feature')`                 |
| `WindowsCapabilities`       | Install Windows capabilities            | `@('OpenSSH.Server~~~~0.0.1.0')`      |
| `RemoveWindowsCapabilities` | Remove Windows capabilities             | `@('OpenSSH.Client~~~~0.0.1.0')`      |
| `RemoveApps`                | Remove AppX/MSIX applications           | `@('Microsoft.BingNews')`             |
| `Variables`                 | Define reusable values                  | `@{ CustomPort = 25565 }`             |
| `Exec.Mkdir`                | Create directories                      | `@('HOME\Tools')`                     |
| `Exec.Copy`                 | Copy files/directories                  | `@{ source = '...'; target = '...' }` |
| `Exec.DownloadFile`         | Download files                          | `@{ url = '...'; target = '...' }`    |
| `Exec.AppInstaller`         | Install AppX/MSIX/AppInstaller packages | `@{ source = '...' }`                 |
| `Exec.Command`              | Execute shell commands                  | `@{ Shell = 'cmd'; Command = '...' }` |

---

## 22. Summary

MachineForge uses a declarative configuration model where `.psd1` files describe the desired workstation state and `.psm1` modules provide the execution logic.

The configuration system supports:

* Package installation and removal
* NPM package installation and removal
* Registry configuration
* Firewall rule configuration and removal
* Windows optional feature enablement and disablement
* Windows capability installation and removal
* AppX/MSIX application removal
* Reusable variables
* Directory creation
* File and directory copying
* Remote file downloads
* App Installer package installation
* Shell command execution
* Machine-specific hardware and OS targeting
* Reusable configuration templates
* Profile-specific configuration
* Dynamic localization

The architecture keeps configuration separate from execution logic, allowing the same MachineForge execution engine to be reused across different workstation profiles while maintaining machine-specific configuration in `.psd1` files.

The result is a modular, declarative, and repeatable workstation provisioning tool.