<#
REGISTRY ARCHIVE
================
This file defines entries referenced by Registry = @('EntryName') in profiles
and templates. Create a unique key for a new value, then add that key to the
appropriate Registry list:

    EnableMySetting = @{
        Path  = 'HKCU:\Software\Contoso\Example'
        Name  = 'Enabled'
        Type  = 'DWord'
        Value = 1
    }

Fields:
  Path  : PowerShell registry path. Common roots are HKCU:, HKLM:, HKCR:, HKU:,
          and HKCC:. Missing subkeys are created automatically.
  Name  : Value name. Use '' for the default/unnamed registry value.
  Value : Data to write. Use a number for DWord (such as 0 or 1), text for
          String, and an array of strings for MultiString.
  Type  : Optional registry-provider type: String, ExpandString, Binary, DWord,
          MultiString, QWord, or Unknown. Omit it to preserve an existing type.
  RequiresAdministrator : Optional $true/$false. HKLM:, HKU:, HKCR:, HKCC:, and
          Software\Policies paths automatically require elevation. Set $true to
          force elevation for another path.

Create a separate, descriptive entry to reverse a value (for example EnableX
and DisableX). Verify the target with reg.exe query or PowerShell
Get-ItemProperty first, then test with -WhatIf.
#>
@{
    # File Explorer
    # Description: Controls whether File Explorer displays files and folders with the hidden attribute.
    # Available values:
    # - HideHiddenFiles: 2
    # - ShowHiddenFiles: 1
    ShowHiddenFiles                                 = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'Hidden'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether File Explorer displays files and folders with the hidden attribute.
    # Available values:
    # - HideHiddenFiles: 2
    # - ShowHiddenFiles: 1
    HideHiddenFiles                                 = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'Hidden'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls File Explorer notifications from cloud-sync providers, such as OneDrive.
    # Available values:
    # - DisableSyncProviderNotifications: 0
    # - EnableSyncProviderNotifications: 1
    EnableSyncProviderNotifications                 = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'ShowSyncProviderNotifications'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls File Explorer notifications from cloud-sync providers, such as OneDrive.
    # Available values:
    # - DisableSyncProviderNotifications: 0
    # - EnableSyncProviderNotifications: 1
    DisableSyncProviderNotifications                = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'ShowSyncProviderNotifications'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether encrypted or NTFS-compressed files are displayed in a distinct color.
    # Available values:
    # - DisableNtfsFileColor: 0
    # - EnableNtfsFileColor: 1
    EnableNtfsFileColor                             = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'ShowEncryptCompressedColor'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether encrypted or NTFS-compressed files are displayed in a distinct color.
    # Available values:
    # - DisableNtfsFileColor: 0
    # - EnableNtfsFileColor: 1
    DisableNtfsFileColor                            = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'ShowEncryptCompressedColor'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls the item-selection check boxes displayed beside files and folders.
    # Available values:
    # - DisableItemCheckBoxes: 0
    # - EnableItemCheckBoxes: 1
    EnableItemCheckBoxes                            = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'AutoCheckSelect'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls the item-selection check boxes displayed beside files and folders.
    # Available values:
    # - DisableItemCheckBoxes: 0
    # - EnableItemCheckBoxes: 1
    DisableItemCheckBoxes                           = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'AutoCheckSelect'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether File Explorer hides known file-name extensions.
    # Available values:
    # - HideFileNameExtensions: 1
    # - ShowFileNameExtensions: 0
    ShowFileNameExtensions                          = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'HideFileExt'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether File Explorer hides known file-name extensions.
    # Available values:
    # - HideFileNameExtensions: 1
    # - ShowFileNameExtensions: 0
    HideFileNameExtensions                          = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'HideFileExt'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether File Explorer shows recently used files in Home or Quick access.
    # Available values:
    # - DisableRecentFiles: 0
    # - EnableRecentFiles: 1
    EnableRecentFiles                               = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
        Name  = 'ShowRecent'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether File Explorer shows recently used files in Home or Quick access.
    # Available values:
    # - DisableRecentFiles: 0
    # - EnableRecentFiles: 1
    DisableRecentFiles                              = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
        Name  = 'ShowRecent'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether File Explorer shows frequently used folders in Home or Quick access.
    # Available values:
    # - DisableFrequentFolders: 0
    # - EnableFrequentFolders: 1
    EnableFrequentFolders                           = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
        Name  = 'ShowFrequent'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether File Explorer shows frequently used folders in Home or Quick access.
    # Available values:
    # - DisableFrequentFolders: 0
    # - EnableFrequentFolders: 1
    DisableFrequentFolders                          = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
        Name  = 'ShowFrequent'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether cloud files appear in File Explorer Home or Quick access.
    # Available values:
    # - DisableCloudFilesInQuickAccess: 0
    # - EnableCloudFilesInQuickAccess: 1
    EnableCloudFilesInQuickAccess                   = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
        Name  = 'ShowCloudFilesInQuickAccess'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether cloud files appear in File Explorer Home or Quick access.
    # Available values:
    # - DisableCloudFilesInQuickAccess: 0
    # - EnableCloudFilesInQuickAccess: 1
    DisableCloudFilesInQuickAccess                  = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
        Name  = 'ShowCloudFilesInQuickAccess'
        Type  = 'DWord'
        Value = 0
    }

    # Start menu and developer features
    # Description: Controls whether Windows tracks recently opened documents.
    # Available values:
    # - DisableStartMenuDocumentTracking: 0
    # - EnableStartMenuDocumentTracking: 1
    EnableStartMenuDocumentTracking                 = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'Start_TrackDocs'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows tracks recently opened documents.
    # Available values:
    # - DisableStartMenuDocumentTracking: 0
    # - EnableStartMenuDocumentTracking: 1
    DisableStartMenuDocumentTracking                = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'Start_TrackDocs'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows tracks application launches.
    # Available values:
    # - DisableStartMenuAppTracking: 0
    # - EnableStartMenuAppTracking: 1
    EnableStartMenuAppTracking                      = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'Start_TrackProgs'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows tracks application launches.
    # Available values:
    # - DisableStartMenuAppTracking: 0
    # - EnableStartMenuAppTracking: 1
    DisableStartMenuAppTracking                     = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'Start_TrackProgs'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Developer Mode is enabled without a developer license.
    # Available values:
    # - DisableDeveloperMode: 0
    # - EnableDeveloperMode: 1
    EnableDeveloperMode                             = @{
        Path  = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock'
        Name  = 'AllowDevelopmentWithoutDevLicense'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Developer Mode is enabled without a developer license.
    # Available values:
    # - DisableDeveloperMode: 0
    # - EnableDeveloperMode: 1
    DisableDeveloperMode                            = @{
        Path  = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock'
        Name  = 'AllowDevelopmentWithoutDevLicense'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether the End task command is available from taskbar application buttons.
    # Available values:
    # - DisableTaskbarEndTask: 0
    # - EnableTaskbarEndTask: 1
    EnableTaskbarEndTask                            = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings'
        Name  = 'TaskbarEndTask'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether the End task command is available from taskbar application buttons.
    # Available values:
    # - DisableTaskbarEndTask: 0
    # - EnableTaskbarEndTask: 1
    DisableTaskbarEndTask                           = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings'
        Name  = 'TaskbarEndTask'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Start shows the Run as different user command.
    # Available values:
    # - DisableRunAsDifferentUser: 0
    # - EnableRunAsDifferentUser: 1
    EnableRunAsDifferentUser                        = @{
        Path                  = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
        Name                  = 'ShowRunAsDifferentUserInStart'
        Type                  = 'DWord'
        RequiresAdministrator = $true
        Value                 = 1
    }
    # Description: Controls whether Start shows the Run as different user command.
    # Available values:
    # - DisableRunAsDifferentUser: 0
    # - EnableRunAsDifferentUser: 1
    DisableRunAsDifferentUser                       = @{
        Path                  = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
        Name                  = 'ShowRunAsDifferentUserInStart'
        Type                  = 'DWord'
        RequiresAdministrator = $true
        Value                 = 0
    }

    # Privacy, search, and diagnostics
    # Description: Controls the diagnostic-data level permitted by the Windows telemetry policy.
    # Available values:
    # - DisableTelemetry: 0
    # - EnableTelemetry: 1
    EnableTelemetry                                 = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'AllowTelemetry'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls the diagnostic-data level permitted by the Windows telemetry policy.
    # Available values:
    # - DisableTelemetry: 0
    # - EnableTelemetry: 1
    DisableTelemetry                                = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'AllowTelemetry'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows can collect local user activity history.
    # Available values:
    # - DisableActivityFeed: 0
    # - EnableActivityFeed: 1
    EnableActivityFeed                              = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'EnableActivityFeed'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows can collect local user activity history.
    # Available values:
    # - DisableActivityFeed: 0
    # - EnableActivityFeed: 1
    DisableActivityFeed                             = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'EnableActivityFeed'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows can publish user activity history for connected experiences.
    # Available values:
    # - DisableUserActivityPublishing: 0
    # - EnableUserActivityPublishing: 1
    EnableUserActivityPublishing                    = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'PublishUserActivities'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows can publish user activity history for connected experiences.
    # Available values:
    # - DisableUserActivityPublishing: 0
    # - EnableUserActivityPublishing: 1
    DisableUserActivityPublishing                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'PublishUserActivities'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows can upload user activity history to Microsoft services.
    # Available values:
    # - DisableUserActivityUpload: 0
    # - EnableUserActivityUpload: 1
    EnableUserActivityUpload                        = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'UploadUserActivities'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows can upload user activity history to Microsoft services.
    # Available values:
    # - DisableUserActivityUpload: 0
    # - EnableUserActivityUpload: 1
    DisableUserActivityUpload                       = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'UploadUserActivities'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether the OneDrive sync client is allowed to synchronize files.
    # Available values:
    # - DisableOneDriveFileSync: 1
    # - EnableOneDriveFileSync: 0
    EnableOneDriveFileSync                          = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\OneDrive'
        Name  = 'DisableFileSyncNGSC'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether the OneDrive sync client is allowed to synchronize files.
    # Available values:
    # - DisableOneDriveFileSync: 1
    # - EnableOneDriveFileSync: 0
    DisableOneDriveFileSync                         = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\OneDrive'
        Name  = 'DisableFileSyncNGSC'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows Search can include cloud content in results.
    # Available values:
    # - DisableCloudSearch: 0
    # - EnableCloudSearch: 1
    EnableCloudSearch                               = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search'
        Name  = 'AllowCloudSearch'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows Search can include cloud content in results.
    # Available values:
    # - DisableCloudSearch: 0
    # - EnableCloudSearch: 1
    DisableCloudSearch                              = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search'
        Name  = 'AllowCloudSearch'
        Type  = 'DWord'
        Value = 0
    }
    EnableSearchBoxSuggestions                      = @{
        Path                  = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
        Name                  = 'DisableSearchBoxSuggestions'
        RequiresAdministrator = $true
        Type                  = 'DWord'
        Value                 = 0
    }
    DisableSearchBoxSuggestions                     = @{
        Path                  = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
        Name                  = 'DisableSearchBoxSuggestions'
        RequiresAdministrator = $true
        Type                  = 'DWord'
        Value                 = 1
    }
    # Description: Controls whether Windows Search can use device location.
    # Available values:
    # - DisableSearchLocationAccess: 0
    # - EnableSearchLocationAccess: 1
    EnableSearchLocationAccess                      = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search'
        Name  = 'AllowSearchToUseLocation'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows Search can use device location.
    # Available values:
    # - DisableSearchLocationAccess: 0
    # - EnableSearchLocationAccess: 1
    DisableSearchLocationAccess                     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search'
        Name  = 'AllowSearchToUseLocation'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows Error Reporting is enabled.
    # Available values:
    # - DisableWindowsErrorReporting: 1
    # - EnableWindowsErrorReporting: 0
    EnableWindowsErrorReporting                     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'
        Name  = 'Disabled'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows Error Reporting is enabled.
    # Available values:
    # - DisableWindowsErrorReporting: 1
    # - EnableWindowsErrorReporting: 0
    DisableWindowsErrorReporting                    = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'
        Name  = 'Disabled'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows Error Reporting can send diagnostic data beyond the initial report.
    # Available values:
    # - DisableAdditionalErrorData: 1
    # - EnableAdditionalErrorData: 0
    EnableAdditionalErrorData                       = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'
        Name  = 'DontSendAdditionalData'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows Error Reporting can send diagnostic data beyond the initial report.
    # Available values:
    # - DisableAdditionalErrorData: 1
    # - EnableAdditionalErrorData: 0
    DisableAdditionalErrorData                      = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'
        Name  = 'DontSendAdditionalData'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether diagnostic data can be processed for Desktop Analytics.
    # Available values:
    # - DisableDesktopAnalyticsProcessing: 0
    # - EnableDesktopAnalyticsProcessing: 1
    EnableDesktopAnalyticsProcessing                = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'AllowDesktopAnalyticsProcessing'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether diagnostic data can be processed for Desktop Analytics.
    # Available values:
    # - DisableDesktopAnalyticsProcessing: 0
    # - EnableDesktopAnalyticsProcessing: 1
    DisableDesktopAnalyticsProcessing               = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'AllowDesktopAnalyticsProcessing'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether the device name is included in Windows diagnostic data.
    # Available values:
    # - DisableDeviceNameInTelemetry: 0
    # - EnableDeviceNameInTelemetry: 1
    EnableDeviceNameInTelemetry                     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'AllowDeviceNameInTelemetry'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether the device name is included in Windows diagnostic data.
    # Available values:
    # - DisableDeviceNameInTelemetry: 0
    # - EnableDeviceNameInTelemetry: 1
    DisableDeviceNameInTelemetry                    = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'AllowDeviceNameInTelemetry'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether apps can use the advertising identifier for personalized advertising.
    # Available values:
    # - DisableAdvertisingId: 1
    # - EnableAdvertisingId: 0
    EnableAdvertisingId                             = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo'
        Name  = 'DisabledByGroupPolicy'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether apps can use the advertising identifier for personalized advertising.
    # Available values:
    # - DisableAdvertisingId: 1
    # - EnableAdvertisingId: 0
    DisableAdvertisingId                            = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo'
        Name  = 'DisabledByGroupPolicy'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows shows the privacy-settings experience during setup and feature updates.
    # Available values:
    # - DisablePrivacyExperience: 1
    # - EnablePrivacyExperience: 0
    EnablePrivacyExperience                         = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\OOBE'
        Name  = 'DisablePrivacyExperience'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows shows the privacy-settings experience during setup and feature updates.
    # Available values:
    # - DisablePrivacyExperience: 1
    # - EnablePrivacyExperience: 0
    DisablePrivacyExperience                        = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\OOBE'
        Name  = 'DisablePrivacyExperience'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows can collect inking data for personalization.
    # Available values:
    # - DisableImplicitInkCollection: 1
    # - EnableImplicitInkCollection: 0
    EnableImplicitInkCollection                     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\InputPersonalization'
        Name  = 'RestrictImplicitInkCollection'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows can collect inking data for personalization.
    # Available values:
    # - DisableImplicitInkCollection: 1
    # - EnableImplicitInkCollection: 0
    DisableImplicitInkCollection                    = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\InputPersonalization'
        Name  = 'RestrictImplicitInkCollection'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows can collect typed text data for personalization.
    # Available values:
    # - DisableImplicitTextCollection: 1
    # - EnableImplicitTextCollection: 0
    EnableImplicitTextCollection                    = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\InputPersonalization'
        Name  = 'RestrictImplicitTextCollection'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows can collect typed text data for personalization.
    # Available values:
    # - DisableImplicitTextCollection: 1
    # - EnableImplicitTextCollection: 0
    DisableImplicitTextCollection                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\InputPersonalization'
        Name  = 'RestrictImplicitTextCollection'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows uses diagnostic data for personalized tips, recommendations, and offers.
    # Available values:
    # - DisableTailoredExperiences: 1
    # - EnableTailoredExperiences: 0
    EnableTailoredExperiences                       = @{
        Path  = 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent'
        Name  = 'DisableTailoredExperiencesWithDiagnosticData'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows uses diagnostic data for personalized tips, recommendations, and offers.
    # Available values:
    # - DisableTailoredExperiences: 1
    # - EnableTailoredExperiences: 0
    DisableTailoredExperiences                      = @{
        Path  = 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent'
        Name  = 'DisableTailoredExperiencesWithDiagnosticData'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows Spotlight shows third-party app and content suggestions.
    # Available values:
    # - DisableThirdPartySpotlightSuggestions: 1
    # - EnableThirdPartySpotlightSuggestions: 0
    EnableThirdPartySpotlightSuggestions            = @{
        Path  = 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent'
        Name  = 'DisableThirdPartySuggestions'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows Spotlight shows third-party app and content suggestions.
    # Available values:
    # - DisableThirdPartySpotlightSuggestions: 1
    # - EnableThirdPartySpotlightSuggestions: 0
    DisableThirdPartySpotlightSuggestions           = @{
        Path  = 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent'
        Name  = 'DisableThirdPartySuggestions'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows installs or suggests consumer experiences, such as promoted apps.
    # Available values:
    # - DisableWindowsConsumerFeatures: 1
    # - EnableWindowsConsumerFeatures: 0
    EnableWindowsConsumerFeatures                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent'
        Name  = 'DisableWindowsConsumerFeatures'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows installs or suggests consumer experiences, such as promoted apps.
    # Available values:
    # - DisableWindowsConsumerFeatures: 1
    # - EnableWindowsConsumerFeatures: 0
    DisableWindowsConsumerFeatures                  = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent'
        Name  = 'DisableWindowsConsumerFeatures'
        Type  = 'DWord'
        Value = 1
    }

    # Updates, device metadata, and cross-device features
    # Description: Controls the Delivery Optimization download source mode for Windows updates and Store content.
    # Available values:
    # - UseHttpOnlyDeliveryOptimization: 0
    # - UseLanDeliveryOptimization: 1
    UseLanDeliveryOptimization                      = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization'
        Name  = 'DODownloadMode'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls the Delivery Optimization download source mode for Windows updates and Store content.
    # Available values:
    # - UseHttpOnlyDeliveryOptimization: 0
    # - UseLanDeliveryOptimization: 1
    UseHttpOnlyDeliveryOptimization                 = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization'
        Name  = 'DODownloadMode'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows downloads enhanced device metadata from Microsoft.
    # Available values:
    # - DisableDeviceMetadataDownloads: 1
    # - EnableDeviceMetadataDownloads: 0
    EnableDeviceMetadataDownloads                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Device Metadata'
        Name  = 'PreventDeviceMetadataFromNetwork'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows downloads enhanced device metadata from Microsoft.
    # Available values:
    # - DisableDeviceMetadataDownloads: 1
    # - EnableDeviceMetadataDownloads: 0
    DisableDeviceMetadataDownloads                  = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\Device Metadata'
        Name  = 'PreventDeviceMetadataFromNetwork'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows Error Reporting is notified when a device driver cannot be found.
    # Available values:
    # - DisableDriverNotFoundErrorReporting: 1
    # - EnableDriverNotFoundErrorReporting: 0
    EnableDriverNotFoundErrorReporting              = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings'
        Name  = 'DisableSendGenericDriverNotFoundToWER'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows Error Reporting is notified when a device driver cannot be found.
    # Available values:
    # - DisableDriverNotFoundErrorReporting: 1
    # - EnableDriverNotFoundErrorReporting: 0
    DisableDriverNotFoundErrorReporting             = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DeviceInstall\Settings'
        Name  = 'DisableSendGenericDriverNotFoundToWER'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls Windows Fast Startup (hybrid boot).
    # Available values:
    # - EnableFastStartup: 1
    # - DisableFastStartup: 0
    EnableFastStartup                               = @{
        Path  = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
        Name  = 'HiberbootEnabled'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls Windows Fast Startup (hybrid boot).
    # Available values:
    # - DisableFastStartup: 0
    # - EnableFastStartup: 1
    DisableFastStartup                              = @{
        Path  = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
        Name  = 'HiberbootEnabled'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether clipboard data can synchronize between the user devices.
    # Available values:
    # - DisableCrossDeviceClipboard: 0
    # - EnableCrossDeviceClipboard: 1
    EnableCrossDeviceClipboard                      = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'AllowCrossDeviceClipboard'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether clipboard data can synchronize between the user devices.
    # Available values:
    # - DisableCrossDeviceClipboard: 0
    # - EnableCrossDeviceClipboard: 1
    DisableCrossDeviceClipboard                     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'AllowCrossDeviceClipboard'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows keeps a local clipboard history.
    # Available values:
    # - DisableClipboardHistory: 0
    # - EnableClipboardHistory: 1
    EnableClipboardHistory                          = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'AllowClipboardHistory'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows keeps a local clipboard history.
    # Available values:
    # - DisableClipboardHistory: 0
    # - EnableClipboardHistory: 1
    DisableClipboardHistory                         = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'AllowClipboardHistory'
        Type  = 'DWord'
        Value = 0
    }

    # Microsoft Defender SmartScreen: enable it before selecting the warning or blocking mode.
    # Description: Controls whether Microsoft Defender SmartScreen checks downloaded apps and files.
    # Available values:
    # - DisableSmartScreenAppReputation: 0
    # - EnableSmartScreenAppReputation: 1
    EnableSmartScreenAppReputation                  = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'EnableSmartScreen'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Microsoft Defender SmartScreen checks downloaded apps and files.
    # Available values:
    # - DisableSmartScreenAppReputation: 0
    # - EnableSmartScreenAppReputation: 1
    DisableSmartScreenAppReputation                 = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'EnableSmartScreen'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether SmartScreen warns about suspicious apps or blocks them.
    # Available values:
    # - UseSmartScreenBlockMode: 'Block'
    # - UseSmartScreenWarnMode: 'Warn'
    UseSmartScreenWarnMode                          = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'ShellSmartScreenLevel'
        Type  = 'String'
        Value = 'Warn'
    }
    # Description: Controls whether SmartScreen warns about suspicious apps or blocks them.
    # Available values:
    # - UseSmartScreenBlockMode: 'Block'
    # - UseSmartScreenWarnMode: 'Warn'
    UseSmartScreenBlockMode                         = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\System'
        Name  = 'ShellSmartScreenLevel'
        Type  = 'String'
        Value = 'Block'
    }

    # Windows 11 diagnostic-data safeguards.
    # Description: Controls whether users can delete diagnostic data already collected by Microsoft.
    # Available values:
    # - AllowDiagnosticDataDeletion: 0
    # - DisallowDiagnosticDataDeletion: 1
    AllowDiagnosticDataDeletion                     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'DisableDeviceDelete'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users can delete diagnostic data already collected by Microsoft.
    # Available values:
    # - AllowDiagnosticDataDeletion: 0
    # - DisallowDiagnosticDataDeletion: 1
    DisallowDiagnosticDataDeletion                  = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'DisableDeviceDelete'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether users can enable and open the Diagnostic Data Viewer.
    # Available values:
    # - DisableDiagnosticDataViewer: 1
    # - EnableDiagnosticDataViewer: 0
    EnableDiagnosticDataViewer                      = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'DisableDiagnosticDataViewer'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users can enable and open the Diagnostic Data Viewer.
    # Available values:
    # - DisableDiagnosticDataViewer: 1
    # - EnableDiagnosticDataViewer: 0
    DisableDiagnosticDataViewer                     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'DisableDiagnosticDataViewer'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows can collect additional diagnostic logs.
    # Available values:
    # - AllowAdditionalDiagnosticLogs: 0
    # - LimitAdditionalDiagnosticLogs: 1
    AllowAdditionalDiagnosticLogs                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'LimitDiagnosticLogCollection'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows can collect additional diagnostic logs.
    # Available values:
    # - AllowAdditionalDiagnosticLogs: 0
    # - LimitAdditionalDiagnosticLogs: 1
    LimitAdditionalDiagnosticLogs                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'LimitDiagnosticLogCollection'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows Error Reporting can collect full or heap crash dumps.
    # Available values:
    # - AllowFullDiagnosticDumps: 0
    # - LimitDiagnosticDumps: 1
    AllowFullDiagnosticDumps                        = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'LimitDumpCollection'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows Error Reporting can collect full or heap crash dumps.
    # Available values:
    # - AllowFullDiagnosticDumps: 0
    # - LimitDiagnosticDumps: 1
    LimitDiagnosticDumps                            = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
        Name  = 'LimitDumpCollection'
        Type  = 'DWord'
        Value = 1
    }

    # Windows AI features. Some policies require Windows 11 24H2 or a Copilot+ PC.
    # Description: Controls whether the legacy Windows Copilot experience is available. This policy does not control the newer Copilot app.
    # Available values:
    # - DisableWindowsCopilot: 1
    # - EnableWindowsCopilot: 0
    EnableWindowsCopilot                            = @{
        Path                  = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'
        Name                  = 'TurnOffWindowsCopilot'
        Type                  = 'DWord'
        RequiresAdministrator = $true
        Value                 = 0
    }
    # Description: Controls whether the legacy Windows Copilot experience is available. This policy does not control the newer Copilot app.
    # Available values:
    # - DisableWindowsCopilot: 1
    # - EnableWindowsCopilot: 0
    DisableWindowsCopilot                           = @{
        Path                  = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'
        Name                  = 'TurnOffWindowsCopilot'
        Type                  = 'DWord'
        RequiresAdministrator = $true
        Value                 = 1
    }
    # Description: Controls whether the Recall optional component can be installed and enabled. Disabling it removes Recall and deletes saved snapshots after a restart.
    # Available values:
    # - DisableRecall: 0
    # - EnableRecall: 1
    EnableRecall                                    = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'AllowRecallEnablement'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether the Recall optional component can be installed and enabled. Disabling it removes Recall and deletes saved snapshots after a restart.
    # Available values:
    # - DisableRecall: 0
    # - EnableRecall: 1
    DisableRecall                                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'AllowRecallEnablement'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Recall is allowed to save screen snapshots for local AI analysis.
    # Available values:
    # - DisableRecallSnapshots: 1
    # - EnableRecallSnapshots: 0
    EnableRecallSnapshots                           = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'DisableAIDataAnalysis'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Recall is allowed to save screen snapshots for local AI analysis. Enabling this policy deletes previously saved snapshots.
    # Available values:
    # - DisableRecallSnapshots: 1
    # - EnableRecallSnapshots: 0
    DisableRecallSnapshots                          = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'DisableAIDataAnalysis'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Recall data and snapshots can be exported in the European Economic Area.
    # Available values:
    # - AllowRecallExport: 1
    # - DisallowRecallExport: 0
    AllowRecallExport                               = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'AllowRecallExport'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Recall data and snapshots can be exported in the European Economic Area.
    # Available values:
    # - AllowRecallExport: 1
    # - DisallowRecallExport: 0
    DisallowRecallExport                            = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'AllowRecallExport'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Click to Do can analyze the current screen locally and offer contextual actions.
    # Available values:
    # - DisableClickToDo: 1
    # - EnableClickToDo: 0
    EnableClickToDo                                 = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'DisableClickToDo'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Click to Do can analyze the current screen locally and offer contextual actions.
    # Available values:
    # - DisableClickToDo: 1
    # - EnableClickToDo: 0
    DisableClickToDo                                = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'DisableClickToDo'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Paint Cocreator is available.
    # Available values:
    # - DisablePaintCocreator: 1
    # - EnablePaintCocreator: 0
    EnablePaintCocreator                            = @{
        Path  = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Paint'
        Name  = 'DisableCocreator'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Paint Cocreator is available.
    # Available values:
    # - DisablePaintCocreator: 1
    # - EnablePaintCocreator: 0
    DisablePaintCocreator                           = @{
        Path  = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Paint'
        Name  = 'DisableCocreator'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Paint Generative Fill is available.
    # Available values:
    # - DisablePaintGenerativeFill: 1
    # - EnablePaintGenerativeFill: 0
    EnablePaintGenerativeFill                       = @{
        Path  = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Paint'
        Name  = 'DisableGenerativeFill'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Paint Generative Fill is available.
    # Available values:
    # - DisablePaintGenerativeFill: 1
    # - EnablePaintGenerativeFill: 0
    DisablePaintGenerativeFill                      = @{
        Path  = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Paint'
        Name  = 'DisableGenerativeFill'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether the Settings app provides its agentic AI search experience. This policy is currently limited to eligible Windows Insider Enterprise and Education devices.
    # Available values:
    # - DisableSettingsAgent: 1
    # - EnableSettingsAgent: 0
    EnableSettingsAgent                             = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'DisableSettingsAgent'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether the Settings app provides its agentic AI search experience. This policy is currently limited to eligible Windows Insider Enterprise and Education devices.
    # Available values:
    # - DisableSettingsAgent: 1
    # - EnableSettingsAgent: 0
    DisableSettingsAgent                            = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'DisableSettingsAgent'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls remote agent connectors used by Windows AI. This policy is currently limited to eligible Windows Insider Enterprise and Education devices.
    # Available values:
    # - AllowUserControlOfRemoteAgentConnectors: 0
    # - EnableRemoteAgentConnectors: 1
    # - DisableRemoteAgentConnectors: 2
    AllowUserControlOfRemoteAgentConnectors         = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'DisableRemoteAgentConnectors'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls remote agent connectors used by Windows AI. This policy is currently limited to eligible Windows Insider Enterprise and Education devices.
    # Available values:
    # - AllowUserControlOfRemoteAgentConnectors: 0
    # - EnableRemoteAgentConnectors: 1
    # - DisableRemoteAgentConnectors: 2
    EnableRemoteAgentConnectors                     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'DisableRemoteAgentConnectors'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls remote agent connectors used by Windows AI. This policy is currently limited to eligible Windows Insider Enterprise and Education devices.
    # Available values:
    # - AllowUserControlOfRemoteAgentConnectors: 0
    # - EnableRemoteAgentConnectors: 1
    # - DisableRemoteAgentConnectors: 2
    DisableRemoteAgentConnectors                    = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsAI'
        Name  = 'DisableRemoteAgentConnectors'
        Type  = 'DWord'
        Value = 2
    }

    # Settings sync: a value of 2 disables the individual category; 1 disallows a user override.
    # Description: Controls whether Windows settings sync is available for the user account.
    # Available values:
    # - DisableSettingsSync: 2
    # - EnableSettingsSync: 0
    EnableSettingsSync                              = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableSettingSync'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows settings sync is available for the user account.
    # Available values:
    # - DisableSettingsSync: 2
    # - EnableSettingsSync: 0
    DisableSettingsSync                             = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableSettingSync'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls whether users may override the policy that disables Windows settings sync.
    # Available values:
    # - AllowSettingsSyncUserOverride: 0
    # - DisallowSettingsSyncUserOverride: 1
    AllowSettingsSyncUserOverride                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users may override the policy that disables Windows settings sync.
    # Available values:
    # - AllowSettingsSyncUserOverride: 0
    # - DisallowSettingsSyncUserOverride: 1
    DisallowSettingsSyncUserOverride                = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether application settings can synchronize between devices.
    # Available values:
    # - DisableAppSettingsSync: 2
    # - EnableAppSettingsSync: 0
    EnableAppSettingsSync                           = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableApplicationSettingSync'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether application settings can synchronize between devices.
    # Available values:
    # - DisableAppSettingsSync: 2
    # - EnableAppSettingsSync: 0
    DisableAppSettingsSync                          = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableApplicationSettingSync'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls whether users may override the application-settings sync policy.
    # Available values:
    # - AllowAppSettingsSyncUserOverride: 0
    # - DisallowAppSettingsSyncUserOverride: 1
    AllowAppSettingsSyncUserOverride                = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableApplicationSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users may override the application-settings sync policy.
    # Available values:
    # - AllowAppSettingsSyncUserOverride: 0
    # - DisallowAppSettingsSyncUserOverride: 1
    DisallowAppSettingsSyncUserOverride             = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableApplicationSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether app synchronization settings can synchronize between devices.
    # Available values:
    # - DisableAppSync: 2
    # - EnableAppSync: 0
    EnableAppSync                                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableAppSyncSettingSync'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether app synchronization settings can synchronize between devices.
    # Available values:
    # - DisableAppSync: 2
    # - EnableAppSync: 0
    DisableAppSync                                  = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableAppSyncSettingSync'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls whether users may override the app-sync policy.
    # Available values:
    # - AllowAppSyncUserOverride: 0
    # - DisallowAppSyncUserOverride: 1
    AllowAppSyncUserOverride                        = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableAppSyncSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users may override the app-sync policy.
    # Available values:
    # - AllowAppSyncUserOverride: 0
    # - DisallowAppSyncUserOverride: 1
    DisallowAppSyncUserOverride                     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableAppSyncSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether desktop theme settings can synchronize between devices.
    # Available values:
    # - DisableThemeSettingsSync: 2
    # - EnableThemeSettingsSync: 0
    EnableThemeSettingsSync                         = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableDesktopThemeSettingSync'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether desktop theme settings can synchronize between devices.
    # Available values:
    # - DisableThemeSettingsSync: 2
    # - EnableThemeSettingsSync: 0
    DisableThemeSettingsSync                        = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableDesktopThemeSettingSync'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls whether users may override the desktop-theme sync policy.
    # Available values:
    # - AllowThemeSettingsSyncUserOverride: 0
    # - DisallowThemeSettingsSyncUserOverride: 1
    AllowThemeSettingsSyncUserOverride              = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableDesktopThemeSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users may override the desktop-theme sync policy.
    # Available values:
    # - AllowThemeSettingsSyncUserOverride: 0
    # - DisallowThemeSettingsSyncUserOverride: 1
    DisallowThemeSettingsSyncUserOverride           = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableDesktopThemeSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether personalization settings can synchronize between devices.
    # Available values:
    # - DisablePersonalizationSettingsSync: 2
    # - EnablePersonalizationSettingsSync: 0
    EnablePersonalizationSettingsSync               = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisablePersonalizationSettingSync'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether personalization settings can synchronize between devices.
    # Available values:
    # - DisablePersonalizationSettingsSync: 2
    # - EnablePersonalizationSettingsSync: 0
    DisablePersonalizationSettingsSync              = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisablePersonalizationSettingSync'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls whether users may override the personalization-settings sync policy.
    # Available values:
    # Description: Controls whether users may override the personalization-settings sync policy.
    # Available values:
    # - AllowPersonalizationSettingsSyncUserOverride: 0
    # - DisallowPersonalizationSettingsSyncUserOverride: 1
    AllowPersonalizationSettingsSyncUserOverride    = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisablePersonalizationSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 0
    }
    # - AllowPersonalizationSettingsSyncUserOverride: 0
    # - DisallowPersonalizationSettingsSyncUserOverride: 1
    DisallowPersonalizationSettingsSyncUserOverride = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisablePersonalizationSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Start layout settings can synchronize between devices.
    # Available values:
    # - DisableStartLayoutSettingsSync: 2
    # - EnableStartLayoutSettingsSync: 0
    EnableStartLayoutSettingsSync                   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableStartLayoutSettingSync'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Start layout settings can synchronize between devices.
    # Available values:
    # - DisableStartLayoutSettingsSync: 2
    # - EnableStartLayoutSettingsSync: 0
    DisableStartLayoutSettingsSync                  = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableStartLayoutSettingSync'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls whether users may override the Start layout sync policy.
    # Available values:
    # - AllowStartLayoutSettingsSyncUserOverride: 0
    # - DisallowStartLayoutSettingsSyncUserOverride: 1
    AllowStartLayoutSettingsSyncUserOverride        = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableStartLayoutSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users may override the Start layout sync policy.
    # Available values:
    # - AllowStartLayoutSettingsSyncUserOverride: 0
    # - DisallowStartLayoutSettingsSyncUserOverride: 1
    DisallowStartLayoutSettingsSyncUserOverride     = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableStartLayoutSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether browser settings can synchronize between devices.
    # Available values:
    # - DisableBrowserSettingsSync: 2
    # - EnableBrowserSettingsSync: 0
    EnableBrowserSettingsSync                       = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableWebBrowserSettingSync'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether browser settings can synchronize between devices.
    # Available values:
    # - DisableBrowserSettingsSync: 2
    # - EnableBrowserSettingsSync: 0
    DisableBrowserSettingsSync                      = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableWebBrowserSettingSync'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls whether users may override the browser-settings sync policy.
    # Available values:
    # - AllowBrowserSettingsSyncUserOverride: 0
    # - DisallowBrowserSettingsSyncUserOverride: 1
    AllowBrowserSettingsSyncUserOverride            = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableWebBrowserSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users may override the browser-settings sync policy.
    # Available values:
    # - AllowBrowserSettingsSyncUserOverride: 0
    # - DisallowBrowserSettingsSyncUserOverride: 1
    DisallowBrowserSettingsSyncUserOverride         = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableWebBrowserSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows-specific settings can synchronize between devices.
    # Available values:
    # - DisableWindowsSettingsSync: 2
    # - EnableWindowsSettingsSync: 0
    EnableWindowsSettingsSync                       = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableWindowsSettingSync'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows-specific settings can synchronize between devices.
    # Available values:
    # - DisableWindowsSettingsSync: 2
    # - EnableWindowsSettingsSync: 0
    DisableWindowsSettingsSync                      = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableWindowsSettingSync'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls whether users may override the Windows-settings sync policy.
    # Available values:
    # - AllowWindowsSettingsSyncUserOverride: 0
    # - DisallowWindowsSettingsSyncUserOverride: 1
    AllowWindowsSettingsSyncUserOverride            = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableWindowsSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users may override the Windows-settings sync policy.
    # Available values:
    # - AllowWindowsSettingsSyncUserOverride: 0
    # - DisallowWindowsSettingsSyncUserOverride: 1
    DisallowWindowsSettingsSyncUserOverride         = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableWindowsSettingSyncUserOverride'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether accessibility settings can synchronize between devices.
    # Available values:
    # - DisableAccessibilitySettingsSync: 2
    # - EnableAccessibilitySettingsSync: 0
    EnableAccessibilitySettingsSync                 = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableAccessibilitySettingSync'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether accessibility settings can synchronize between devices.
    # Available values:
    # - DisableAccessibilitySettingsSync: 2
    # - EnableAccessibilitySettingsSync: 0
    DisableAccessibilitySettingsSync                = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableAccessibilitySettingSync'
        Type  = 'DWord'
        Value = 2
    }
    # Description: Controls whether users may override the accessibility-settings sync policy.
    # Available values:
    # - AllowAccessibilitySettingsSyncUserOverride: 0
    # - DisallowAccessibilitySettingsSyncUserOverride: 1
    AllowAccessibilitySettingsSyncUserOverride      = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableAccessibilitySettingSyncUserOverride'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether users may override the accessibility-settings sync policy.
    # Available values:
    # - AllowAccessibilitySettingsSyncUserOverride: 0
    # - DisallowAccessibilitySettingsSyncUserOverride: 1
    DisallowAccessibilitySettingsSyncUserOverride   = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableAccessibilitySettingSyncUserOverride'
        Type  = 'DWord'
        Value = 1
    }
    # Description: Controls whether Windows settings sync is allowed on metered networks.
    # Available values:
    # - AllowSettingsSyncOnMeteredNetworks: 0
    # - DisallowSettingsSyncOnMeteredNetworks: 1
    AllowSettingsSyncOnMeteredNetworks              = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableSyncOnPaidNetwork'
        Type  = 'DWord'
        Value = 0
    }
    # Description: Controls whether Windows settings sync is allowed on metered networks.
    # Available values:
    # - AllowSettingsSyncOnMeteredNetworks: 0
    # - DisallowSettingsSyncOnMeteredNetworks: 1
    DisallowSettingsSyncOnMeteredNetworks           = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\SettingSync'
        Name  = 'DisableSyncOnPaidNetwork'
        Type  = 'DWord'
        Value = 1
    }

    # Description: Controls whether account-related notifications are shown in the Start menu.
    # Available values:
    # - ShowAccountRelatedNotifications: 1
    # - HideAccountRelatedNotifications: 0
    ShowAccountRelatedNotifications                 = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'Start_AccountNotifications'
        Type  = 'DWord'
        Value = 1
    }

    # Description: Controls whether account-related notifications are shown in the Start menu.
    # Available values:
    # - ShowAccountRelatedNotifications: 1
    # - HideAccountRelatedNotifications: 0
    HideAccountRelatedNotifications                 = @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'Start_AccountNotifications'
        Type  = 'DWord'
        Value = 0
    }
}
