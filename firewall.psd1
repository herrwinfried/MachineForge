<#
FIREWALL RULE ARCHIVE
=====================
Every key in this file can be referenced from Firewall = @('RuleName') in a
profile or template. Rules are created during the elevated phase; an existing
rule with the same Name is not created again.

Example rule:

    BlockExamplePort = @{
        Name        = 'BlockExamplePort' # optional; the archive key is used when omitted
        DisplayName = 'Block example service'
        Enabled     = $true
        Profile     = @('Domain', 'Private', 'Public')
        Direction   = 'Inbound'
        Action      = 'Block'
        Protocol    = 'TCP'
        LocalPort   = 12345
    }

Fields and options:
  Name        : Technical, unique rule name. Optional; the archive key is used when omitted.
  DisplayName : Name displayed in the Windows Firewall user interface.
  Enabled     : $true or $false.
  Profile     : One or more of 'Domain', 'Private', 'Public', or 'Any'.
  Direction   : 'Inbound' or 'Outbound'.
  Action      : 'Allow' or 'Block'.
  Protocol    : Usually 'TCP', 'UDP', or 'Any'.
  LocalPort   : For TCP/UDP: one port (443), a range ('5000-5010'), multiple
                ports (@('80', '443')), or 'Any'. For protocol 'Any', normally
                use 'Any'.

LocalPort can also reference a Variables value from a profile or template:

    Variables = @{ MyServicePort = 8443 }
    # In this file: LocalPort = 'MyServicePort'

Rules are not removed or updated. If a rule with the same Name already exists,
it is skipped. Review the effect with -WhatIf first.
#>
@{
    WindowsAdminCenterBlockPort = @{
        Name        = 'WindowsAdminCenterBlockPort'
        DisplayName = 'Windows Admin Center Block Port'
        Enabled     = $true
        Profile     = @(
            'Domain'
            'Public'
        )
        Direction   = 'Inbound'
        Action      = 'Block'
        Protocol    = 'TCP'
        LocalPort   = 'WACPort'
    }
}
