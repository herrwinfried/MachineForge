@{
    Packages            = @(
        "jdkLatest"
        "jdk8"
        "bulkCrapUninstaller"
        "nanazip"
        "wireguard"
        "warp"
        "wsl"
        "powertoys"
        "protonAuthenticator"
        "brave"
        "filelight"
        "libreoffice"
        "obs"
        "kdenlive"
        "gdrive"
        "kate"
        "obsidian"
        "choco"
        "blip"
        "windowsill"
        "espanso"
        "scolect"
        "winbtrfs"
        "meslofont"
        "adminCenter"
    )
    Npm                 = @(
        '@openai/codex'
        '@anthropic-ai/claude-code'
    )

    Registry            = @(
        # File Explorer
        'ShowHiddenFiles'
        'EnableSyncProviderNotifications'
        'EnableNtfsFileColor'
        'EnableItemCheckBoxes'
        'ShowFileNameExtensions'
        'DisableRecentFiles'
        'DisableFrequentFolders'
        'DisableCloudFilesInQuickAccess'

        # Start menu and developer features
        'DisableStartMenuDocumentTracking'
        'DisableStartMenuAppTracking'
        'EnableDeveloperMode'
        'EnableTaskbarEndTask'
        'EnableRunAsDifferentUser'

        # Privacy, search, and diagnostics
        'DisableTelemetry'
        'DisableActivityFeed'
        'DisableUserActivityPublishing'
        'DisableUserActivityUpload'
        'DisableOneDriveFileSync'
        'DisableCloudSearch'
        'DisableSearchLocationAccess'
        'DisableWindowsErrorReporting'
        'DisableAdditionalErrorData'
        'DisableDesktopAnalyticsProcessing'
        'DisableDeviceNameInTelemetry'
        'DisableAdvertisingId'
        'DisablePrivacyExperience'
        'DisableImplicitInkCollection'
        'DisableImplicitTextCollection'

        # Update and device data controls
        'UseHttpOnlyDeliveryOptimization'
        'DisableDeviceMetadataDownloads'
        'DisableDriverNotFoundErrorReporting'
        'DisableFastStartup'
        'DisableCrossDeviceClipboard'

        # Windows AI
        'DisableWindowsCopilot'
        'DisableRecall'
        'DisableRecallSnapshots'
        'DisallowRecallExport'
        'DisableClickToDo'
        'DisablePaintCocreator'
        'DisablePaintGenerativeFill'
        'DisableSettingsAgent'
        'DisableRemoteAgentConnectors'

        # Settings sync
        'DisableSettingsSync'
        'DisallowSettingsSyncUserOverride'
        'DisableAccessibilitySettingsSync'
        'DisallowAccessibilitySettingsSyncUserOverride'
        'DisableAppSettingsSync'
        'DisallowAppSettingsSyncUserOverride'
        'DisableAppSync'
        'DisallowAppSyncUserOverride'
        'DisableThemeSettingsSync'
        'DisallowThemeSettingsSyncUserOverride'
        'DisablePersonalizationSettingsSync'
        'DisallowPersonalizationSettingsSyncUserOverride'
        'DisableStartLayoutSettingsSync'
        'DisallowStartLayoutSettingsSyncUserOverride'
        'DisallowSettingsSyncOnMeteredNetworks'
        'DisableBrowserSettingsSync'
        'DisallowBrowserSettingsSyncUserOverride'
        'DisableWindowsSettingsSync'
        'DisallowWindowsSettingsSyncUserOverride'
        'HideAccountRelatedNotifications'
    )
    Features            = @(
        "Microsoft-Hyper-V-All"
        "VirtualMachinePlatform"
        "HypervisorPlatform"
        "Containers"
        "Containers-HNS"
        "Containers-SDN"
        "Containers-DisposableClientVM"
        "LegacyComponents"
        "DirectPlay"
        "Printing-XPSServices-Features"
        "Printing-PrintToPDFServices-Features"
    )
    WindowsCapabilities = @(
        'OpenSSH.Client~~~~0.0.1.0'
        'OpenSSH.Server~~~~0.0.1.0'
    )

    RemoveApps          = @(
        "Microsoft.BingWeather"
        "Microsoft.BingNews"
        "Clipchamp.Clipchamp"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
    )

    Variables           = @{
        WACPort = 6516
    }
    Firewall            = @(
        'WindowsAdminCenterBlockPort'
    )
    

    Exec                = @{
        Mkdir        = @(
            'HOME\.poshthemes'
            'HOME\Documents\WindowsPowerShell'
            'HOME\Documents\PowerShell'
            'HOME\sources'
            'HOME\sources\github'
            'HOME\sources\gitlab'
            'HOME\sources\local'
            'HOME\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}'
        )
        Copy         = @(
            @{
                source = 'SCRIPTDIR/data/home'
                target = 'HOME'
            }
        )
        DownloadFile = @(
            @{
                url          = 'https://raw.githubusercontent.com/herrwinfried/myconfig/linux/data/home/.poshthemes/default.omp.json'
                target       = 'HOME\.poshthemes'
                fullFileName = 'default.omp.json'
            }
        )
        AppInstaller = @(
            @{
                source = 'https://magicpods.app/installer/MagicPods.appinstaller'
            }
        )
        Command      = @(
            @{
                Shell                 = 'cmd'
                Command               = 'bcdedit /set hypervisorlaunchtype auto'
                RequiresAdministrator = $true
            }
        )
    }
}
