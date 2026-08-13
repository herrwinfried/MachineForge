<p align="center">
  <picture>
    <img
      src="Docs/Assets/banner.svg"
      alt="MachineForge">
  </picture>
</p>

<p align="center">
  <strong>MachineForge</strong><br>
</p>

**Declarative workstation setup and provisioning automation 1.0.0.**

MachineForge originally started as a personal setup script to quickly provision and customize my own workstations. As the setup grew, it was modularized and decoupled so that configuration data (`.psd1`) could be separated from execution logic (`.psm1`), resulting in a clean, declarative automation tool that can be customized for different machines and environments.

MachineForge is designed to be adapted to your needs. Review and adjust the configurations, templates, and profiles to match your hardware, software requirements, and personal preferences.

---

## 📋 Requirements & Target Profile

| Component              | Specification                                                                                      |
| ---------------------- | -------------------------------------------------------------------------------------------------- |
| **Operating System**   | Windows 11                                                                            |
| **PowerShell Version** | **Windows PowerShell 5.1**                                                                         |
| **Default Profile**    | [`Profile/asuswindows11.psd1`](Profile/asuswindows11.psd1)                                         |
| **Privileges**         | Standard User for user-scope tasks; Administrator elevation when system-level changes are required |
| **Git**                | Required for cloning the repository                                                                |
| **Winget**             | Required for package management through Winget                                                     |
| **Chocolatey**         | Optional; required only for Chocolatey package definitions                                         |
| **Node.js / NPM**      | Optional; required only for NPM package definitions                                                |

---

## ⚡ Key Features

* **Declarative Configuration**: Keeps state definitions (`.psd1`) completely separated from PowerShell execution logic (`.psm1`).
* **Custom Machine Profiles**: Create your own profiles in `Profile/` and combine reusable software and system-tweak templates from `Templates/`.
* **Separated User & Admin Execution**: Runs user-scope tasks such as NPM packages and HKCU registry changes without elevation, requesting Administrator privileges only when system-wide changes are required.
* **Safe Dry-Run (`-WhatIf`)**: Uses PowerShell's native `-WhatIf` functionality for supported operations, allowing changes to be previewed before modifying system state.
* **Built-in i18n**: Automatically detects the system culture and loads the corresponding translation dictionary from `lang/`.
* **Unified Package Management**: Manage packages from Winget, Chocolatey, and NPM through structured profile and template definitions.
* **Debloating & Tweaks**: Remove unwanted system applications, manage optional Windows features, configure firewall rules, modify registry settings, and tune system behavior.
* **Modular Architecture**: Individual capabilities are implemented as independent PowerShell modules, making the tool easier to maintain and extend.
* **Reusable Templates**: Common software and configuration definitions can be shared across multiple machine profiles.

---

## 🏗️ Architecture

MachineForge separates **what should be configured** from **how that configuration is applied**.

```text
Profile/*.psd1
      │
      │  Machine-specific configuration
      ▼
 profile.psm1
      │
      │  Detects system & merges templates
      ▼
 Templates/*.psd1
      │
      ├── Software definitions
      ├── System tweaks
      └── Hardware-specific configuration
      │
      ▼
 Execution Modules (*.psm1)
      │
      ├── package.psm1
      ├── registry.psm1
      ├── firewall.psm1
      ├── feature.psm1
      ├── WindowsApps.psm1
      ├── execution.psm1
      └── ...
      │
      ▼
 Windows Workstation
```

The general design follows a simple principle:

> **Profiles describe the desired workstation state; modules provide the logic required to apply that state.**

This allows the same execution engine to be reused across different machines while keeping machine-specific configuration isolated in profile and template files.

---

## 📥 Getting Started

MachineForge currently targets **Windows PowerShell 5.1**.

> [!IMPORTANT]
> Run MachineForge with **Windows PowerShell**, not PowerShell Core (`pwsh`).

### Why Windows PowerShell instead of PowerShell Core?

MachineForge currently depends on Windows-specific PowerShell functionality and compatibility behavior provided by Windows PowerShell 5.1.

Several built-in modules, including `registry.psm1`, `firewall.psm1`, and `WindowsApps.psm1`, interact with Windows-specific APIs, providers, modules, AppX/MSIX infrastructure, registry functionality, and other system components.

Although PowerShell 7 (`pwsh`) provides extensive Windows support, its execution environment is not completely equivalent to Windows PowerShell 5.1 for all of the functionality used by MachineForge.

For reliable execution of the current Windows implementation and its built-in modules, **Windows PowerShell 5.1 is therefore the supported runtime**.

---

### Enable Script Execution

Ensure that script execution is enabled for your current user:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📥 Clone the Repository

### Clone a Specific Release

For a stable and reproducible setup, cloning a specific release or tag is recommended.

Replace `<tag>` with the desired release:

**From GitLab:**

```powershell
git clone --branch <tag> https://gitlab.com/herrwinfried/machineforge.git
cd machineforge
```

**From GitHub:**

```powershell
git clone --branch <tag> https://github.com/herrwinfried/machineforge.git
cd machineforge
```

For example:

```powershell
git clone --branch v1.0.0-win https://gitlab.com/herrwinfried/machineforge.git
cd machineforge
```

Using a release tag provides a fixed version of the tool and avoids unexpected changes from ongoing development.

### Clone the Development Branch

The `windows` branch contains the current Windows PowerShell-oriented development version:

**From GitLab:**

```powershell
git clone -b windows https://gitlab.com/herrwinfried/machineforge.git
cd machineforge
```

**From GitHub:**

```powershell
git clone -b windows https://github.com/herrwinfried/machineforge.git
cd machineforge
```

> [!NOTE]
> The development branch may contain changes that have not yet been published as a stable release. Use a release tag when reproducibility and stability are more important than the latest changes.

---

## 🚀 Quick Start & Usage

### 1. Preview Changes

Use `-WhatIf` to preview supported workstation changes without applying them:

```powershell
 .\Invoke-Setup.ps1 -ProfileName asuswindows11 -WhatIf
```

This is recommended before running MachineForge on a new system so that you can review the intended operations.

### 2. Run Workstation Provisioning

Apply the configuration defined by the target profile:

```powershell
 .\Invoke-Setup.ps1 -ProfileName asuswindows11
```

You can replace `asuswindows11` with your own profile name.

### 3. User-Level Setup

Skip the Administrator elevation stage and execute only operations that can be performed within the current user context:

```powershell
 .\Invoke-Setup.ps1 -ProfileName asuswindows11 -SkipAdmin
```

This is useful when you want to configure user-level software, files, environment variables, or HKCU settings without applying system-wide changes.

### 4. Custom Language Override

MachineForge automatically detects the system culture. You can override this behavior by explicitly specifying a language culture available in `lang/`:

```powershell
 .\Invoke-Setup.ps1 -ProfileName asuswindows11 -Language en-US
```

For example:

```powershell
 .\Invoke-Setup.ps1 -ProfileName asuswindows11 -Language tr-TR
```

---

## 📂 Workspace Structure

```text
machineforge/
├── Invoke-Setup.ps1          # Main orchestration script
├── Profile/                  # Machine-specific target profiles
│   └── asuswindows11.psd1    # Example profile configuration
├── Templates/                # Modular software & system tweak templates
│   ├── apple.psd1            # Apple software suite definitions
│   ├── asus.psd1             # ASUS hardware-specific utilities
│   ├── basic.psd1            # Core system utilities
│   ├── communication.psd1    # Communication & collaboration tools
│   ├── desktop.psd1          # Desktop environment tweaks & UI customizations
│   ├── developer.psd1        # Developer tools, runtimes, and IDEs
│   └── gaming.psd1           # Gaming launchers & optimizations
├── data/                     # Static files copied during setup
│   └── home/                 # Default user profile templates
├── lang/                     # Localization dictionaries
│   ├── en-US.psd1
│   └── tr-TR.psd1
├── modules/                  # Modular PowerShell execution engine
│   ├── execution.psm1        # Exec action handler & path placeholder resolution
│   ├── feature.psm1          # Optional Windows features manager
│   ├── firewall.psm1         # Firewall rule orchestration
│   ├── global.psm1           # Console formatting & elevation checks
│   ├── i18n.psm1             # Localization loader
│   ├── logger.psm1           # Logging engine
│   ├── package.psm1          # Winget, Chocolatey, and NPM package engine
│   ├── profile.psm1          # System detection & template merger
│   ├── registry.psm1         # HKCU/HKLM registry manager
│   └── WindowsApps.psm1      # AppX/MSIX app management engine
├── Docs/                     # Documentation & reference manuals
│   └── Configuration-Reference.md
├── CONTRIBUTING.md           # Contribution guidelines & PR workflow
├── LICENSE                   # Apache License 2.0
├── package.psd1              # Package archive definitions
├── registry.psd1             # System registry tweak definitions
├── firewall.psd1             # Firewall rule definitions
├── .editorconfig             # Workspace formatting rules
├── .gitignore                # Excludes logs and editor metadata
└── .gitattributes            # Repository line ending rules
```

> [!NOTE]
> **About `data/home/`:**
>
> The files included in `data/home/` are personal configuration files and dotfiles such as shell aliases, prompt themes, and environment configurations.
>
> They are included as an example of how MachineForge can automatically deploy user files to `$HOME`.
>
> Feel free to replace, modify, or remove them and use your own dotfiles.

---

## 🧩 Configuration Model

MachineForge uses PowerShell data files (`.psd1`) to describe the desired configuration.

A typical setup consists of:

```text
Profile
   │
   ├── Machine-specific settings
   │
   └── Selected Templates
           │
           ├── Software
           ├── Registry
           ├── Features
           ├── Firewall
           └── Other system configuration
```

This approach keeps configuration separate from the implementation that applies it.

For example, a profile can select reusable templates without requiring the execution logic to be duplicated:

```powershell
@{
    Templates = @(
        'basic'
        'developer'
        'gaming'
    )
}
```

The exact available properties and syntax are documented in the configuration reference.

---

## 📖 Reference Documentation

For detailed technical specifications covering:

* Profile customization
* Template syntax
* Package definitions
* Registry configuration
* Firewall rules
* Variable substitution
* Localization
* Execution behavior

see the full guide:

📖 **[Configuration Reference Guide](Docs/Configuration-Reference.md)**

---

**## 🌐 Platform-Specific Branches

MachineForge is being developed with platform-specific implementations in mind. The current windows branch targets Windows 11 and Windows PowerShell 5.1.

Future branches may target Linux or macOS and may use different implementation technologies, such as Bash or PowerShell 7 (pwsh).

Configuration structure, supported runtimes, installation methods, system APIs, and contribution requirements may therefore differ between branches. Always follow the documentation and conventions of the specific branch you are working on.

🤝 Contributing**

Contributions are always welcome!

See the [Contributing Guide](CONTRIBUTING.md) for information about:

* Adding software templates
* Creating machine profiles
* Adding system tweaks
* Extending MachineForge modules
* Adding UI localizations
* Improving documentation
* Submitting pull requests

> [!IMPORTANT]
> Contribution requirements and development conventions may vary between branches.
>
> MachineForge is intended to support multiple operating systems and execution environments. For example, platform-specific branches may target **Windows**, **Linux**, or **macOS**, and may use different implementation technologies such as **Windows PowerShell**, **PowerShell 7 (`pwsh`)**, or **Bash**.
>
> Before contributing, make sure to review the documentation and contribution guidelines for the specific branch you are working on. Follow that branch's supported operating system, runtime, scripting language, configuration structure, and implementation conventions.

---

## 📝 Logging & Diagnostics

MachineForge automatically generates an execution log for each run.

Logs are stored in:

```text
logs/YYYYMMDD-HHmmss.log
```

Supported log levels include:

* `INFO`
* `WARN`
* `ERROR`
* `SUCCESS`

These logs can be used to diagnose failed operations and review which actions were performed during provisioning.

> [!NOTE]
> The `logs/` directory is excluded from version control by default.

---

## ⚠️ Known Limitations

### Windows PowerShell 5.1

MachineForge currently requires Windows PowerShell 5.1.

PowerShell 7 (`pwsh`) is **not currently a supported runtime**.

### Administrator Privileges

Some operations require Administrator privileges, including certain:

* HKLM registry modifications
* Firewall configuration
* Windows feature changes
* AppX/MSIX operations
* System-wide software installations
* Other machine-level configuration changes

MachineForge attempts to keep user-level operations separate from these system-level operations and requests elevation only when required.

### Configuration Safety

MachineForge can modify system configuration, remove applications, change registry values, configure firewall rules, and install or remove software.

Always review your profile and use `-WhatIf` where supported before applying changes to an important workstation.

---

## 📄 License

Distributed under the Apache License 2.0.

See [`LICENSE`](LICENSE) for more information.