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

**Declarative workstation setup and provisioning automation framework.**

MachineForge originally started as a personal setup script to quickly provision and customize my own workstations. As my setup grew, I modularized and decoupled configuration data (.psd1) from execution logic (.psm1) to build a clean, declarative framework that anyone can customize and use for their own machines.
MachineForge is designed to be customized to your needs, so don't forget to review and adjust the configurations and profiles to match your own system and preferences.

---

## 📋 Requirements & Target Profile

| Component | Specification |
| --- | --- |
| **PowerShell Version** | **PowerShell (Core) 7+** (`pwsh`) |
| **Default Profile** | [`Profile/asuswindows11.psd1`](Profile/asuswindows11.psd1) |
| **Privileges** | Standard User for user tasks; Administrator elevation when system-level changes are applied |

---

## ⚡ Key Features

- **Declarative Configuration**: Keeps state definitions (`.psd1`) completely separated from PowerShell execution scripts (`.psm1`).
- **Custom Machine Profiles**: Easily create your own profiles in `Profile/` and mix reusable software & tweak templates in `Templates/` tailored to your hardware and setup.
- **Separated User & Admin Execution**: Runs user-scope tasks (NPM, HKCU registry tweaks) without elevation, prompting for administrator privileges only when system-wide changes are required.
- **Safe Dry-Run (`-WhatIf`)**: Supports native PowerShell `-WhatIf` parameter to preview changes before modifying system state.
- **Built-in i18n**: Automatically resolves system culture and loads UI translation dictionaries from `lang/`.
- **Unified Package Management**: Manage packages from Winget, Chocolatey, and NPM within structured profile templates.
- **Debloating & Tweaks**: Easily remove unneeded system apps, manage optional features, and tune system settings.

---

## 📥 Installation & Setup

Ensure script execution is enabled in PowerShell prior to running:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Clone Repository

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

---

## 🚀 Quick Start & Usage

### 1. Preview Changes (Dry-Run)
Inspect all proposed workstation changes using `-WhatIf` without modifying your system:

```powershell
pwsh .\Invoke-Setup.ps1 -ProfileName asuswindows11 -WhatIf
```

### 2. Run Workstation Provisioning
Apply user and system configurations defined in your target profile (e.g., `asuswindows11` or your custom profile):

```powershell
pwsh .\Invoke-Setup.ps1 -ProfileName asuswindows11
```

### 3. User-Level Setup (Skip Elevation)
Execute package installs and user settings without triggering administrator UAC elevation:

```powershell
pwsh .\Invoke-Setup.ps1 -ProfileName asuswindows11 -SkipAdmin
```

### 4. Custom Language Override
Override automatic culture detection by specifying a language culture code from `lang/`:

```powershell
pwsh .\Invoke-Setup.ps1 -ProfileName asuswindows11 -Language en-US
```

---

## 📂 Workspace Structure

```
machineforge/
├── Invoke-Setup.ps1          # Main orchestration script
├── Profile/                  # Machine-specific target profiles
│   └── asuswindows11.psd1    # Example profile configuration
├── Templates/                # Modular software & system tweak templates
│   ├── apple.psd1            # Apple software suite definitions
│   ├── asus.psd1             # ASUS hardware-specific utilities
│   ├── basic.psd1            # Core system utilities
│   ├── communication.psd1    # Communication & collaboration tools
│   ├── desktop.psd1          # Desktop environment tweaks & UI customizations
│   ├── developer.psd1        # Developer tools, runtimes, and IDEs
│   └── gaming.psd1           # Gaming launchers & optimizations
├── data/                     # Static files copied during setup
│   └── home/                 # Default user profile templates
├── lang/                     # Localization dictionaries (en-US.psd1, tr-TR.psd1, etc.)
├── modules/                  # Modular PowerShell engine (.psm1)
│   ├── execution.psm1        # Exec action handler & path placeholder resolution
│   ├── feature.psm1          # Optional features manager
│   ├── firewall.psm1         # Firewall rule orchestration
│   ├── global.psm1           # Console formatting & elevation checks
│   ├── i18n.psm1             # Localization loader
│   ├── logger.psm1           # Logging engine
│   ├── package.psm1          # Winget, Chocolatey, and NPM package engine
│   ├── profile.psm1          # System detection & template merger
│   ├── registry.psm1         # HKCU/HKLM registry manager
│   └── WindowsApps.psm1      # AppX/MSIX app management engine
├── Docs/                     # Documentation & reference manuals
│   └── Configuration-Reference.md
├── CONTRIBUTING.md           # Contribution guidelines & PR workflow
├── LICENSE                   # Apache License 2.0
├── package.psd1              # Package archive definitions
├── registry.psd1             # System registry tweak definitions
├── firewall.psd1             # Firewall rule definitions
├── .editorconfig             # Workspace formatting rules
├── .gitignore                # Excludes logs and editor metadata
└── .gitattributes            # Repository line ending rules
```

> [!NOTE]
> **About `data/home/`**:  
> The files included in `data/home/` are personal configuration files and dotfiles (shell aliases, prompt themes, environment configs). They are included as an example of how MachineForge automatically deploys user files to `$HOME`. Feel free to replace, modify, or remove them with your own dotfiles.

---

## 📖 Reference Documentation

For detailed technical specifications on profile customization, template syntax, variable substitution, and localization, see the full guide:

📖 **[Configuration Reference Guide](Docs/Configuration-Reference.md)**

---

## 🤝 Contributing

Contributions are always welcome! Check out the [Contributing Guide](CONTRIBUTING.md) to learn how to add software templates, machine profiles, or UI localizations.

---

## 📝 Logging & Diagnostics

Execution logs are generated automatically for every run and stored in `logs/`:
- **Path**: `logs/YYYYMMDD-HHmmss.log`
- **Levels**: `INFO`, `WARN`, `ERROR`, `SUCCESS`

---

## 📄 License

Distributed under the Apache License 2.0. See [`LICENSE`](LICENSE) for more information.
