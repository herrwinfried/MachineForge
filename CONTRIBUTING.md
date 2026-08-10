<p align="center">
  <picture>
    <source
      media="(prefers-color-scheme: dark)"
      srcset="Docs/Assets/banner-dark.svg">
    <source
      media="(prefers-color-scheme: light)"
      srcset="Docs/Assets/banner-light.svg">
    <img
      src="Docs/Assets/banner-light.svg"
      alt="MachineForge">
  </picture>
</p>

# Contributing to MachineForge

Thank you for your interest in contributing to **MachineForge**! Contributions from the community help make machine setup and workstation provisioning better for everyone.

---

## 🤝 How You Can Contribute

There are several ways you can contribute to the project:

1. **Adding Reusable Templates (`Templates/*.psd1`)**
   - Create new configuration groups for software suites, developer tools, or system tweaks.
   - Ensure definitions follow native PowerShell hashtable format.

2. **Adding Machine Profiles (`Profile/*.psd1`)**
   - Share tailored profiles for specific hardware setups, work environments, or role-based configurations.

3. **Adding Localizations (`lang/*.psd1`)**
   - Help translate MachineForge UI messages into new languages by adding hashtable files in `lang/` (e.g., `de-DE.psd1`, `fr-FR.psd1`).

4. **Engine & Module Improvements (`modules/*.psm1`)**
   - Fix bugs, refine execution logic, or enhance module features.

---

## 🛠️ Getting Started & Local Development

1. **Fork and Clone the Repository**
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

2. **Always Test with Dry-Run (`-WhatIf`)**  
   Before submitting changes, test your configuration or code changes without modifying your local system state:
   ```powershell
   pwsh .\Invoke-Setup.ps1 -ProfileName <profile-name> -WhatIf
   ```

3. **Code Style & Formatting**
   - Follow standard PowerShell naming conventions (Verb-Noun for functions).
   - Maintain CRLF line endings for text files as specified in `.gitattributes` and `.editorconfig`.
   - Keep configuration files (`.psd1`) strictly declarative (no inline executable code).

---

## 📬 Submitting a Pull Request (PR)

1. Create a branch for your changes and use a clear name that describes what you are working on.
```powershell
git checkout -b [branch-type]/[branch-name]
```

Branch types:
- win: Windows specific changes
- lin: Linux specific changes
- mac: MacOS specific changes

> **Note:** Branch types are not permanent and may change as the project evolves. This section may be updated as new platforms, components, or contribution types are introduced.

2. Commit your changes with clear, concise commit messages.
3. Push your branch to your fork and open a Pull Request against the main branch.
4. Describe what your PR changes and include dry-run test outputs if applicable.

---

## 📜 License

By contributing to MachineForge, you agree that your contributions will be licensed under the project's [Apache License 2.0](LICENSE).
