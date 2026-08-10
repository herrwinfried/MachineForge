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
                Shell                = 'cmd'
                Command              = 'sudo config --enable forceNewWindow'
                RequiresAdministrator = $true
            }
            @{
                Shell                = 'cmd'
                Command              = 'powercfg /hibernate on'
                RequiresAdministrator = $true
            }
        )
    }
}
