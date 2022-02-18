 configuration NewCreateADPDC {
  param
   (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )

  Import-DscResource -ModuleName StorageDsc

  # Create domain admin creds
  [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

  # Get network adapter
  $Interface=Get-NetAdapter|Where Name -Like "Ethernet*"|Select-Object -First 1
  $InterfaceAlias=$($Interface.Name)

  # Apply configuration
  Node localhost {
    LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        WaitForDisk Disk2
        {
             DiskId = 1
             RetryIntervalSec = $RetryIntervalSec
             RetryCount = $RetryCount
        }

        Disk FVolume
        {
             DiskId = 1
             DriveLetter = 'F'
             FSLabel = 'Data'
             DependsOn = '[WaitForDisk]Disk2'
        }
  }
}

NewCreateADPDC -OutputPath:"./NewCreateADPDC"
