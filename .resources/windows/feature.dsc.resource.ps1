#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

function Request-FeatureState {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Validate')]
    [switch]$Validate,

    [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Get')]
    [switch]$Get,

    [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Test')]
    [switch]$Test,

    [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Set')]
    [switch]$Set,

    [Parameter(ParameterSetName = 'Validate', DontShow)]
    [Parameter(ParameterSetName = 'Get')]
    [Parameter(ParameterSetName = 'Test')]
    [Parameter(ParameterSetName = 'Set')]
    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrWhiteSpace()]
    [string]$Name,

    [Parameter(ParameterSetName = 'Validate', DontShow)]
    [Parameter(ParameterSetName = 'Get', DontShow)]
    [Parameter(ParameterSetName = 'Test')]
    [Parameter(ParameterSetName = 'Set')]
    [Parameter(Position = 2)]
    [ValidateNotNullOrWhiteSpace()]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$Ensure
  )

  $supportedPlatforms = @('Win32NT')
  $platform = [System.Environment]::OSVersion.Platform
  if (!($supportedPlatforms -contains $platform)) {
    $exceptionMessage = "Unsupported Platform: $platform, supported platforms: $supportedPlatforms"
    exit 2; throw New-Object ArgumentException $exceptionMessage    
  }

  $osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
  $feature = switch ($PsCmdlet.ParameterSetName) {
    'Validate' 
      { Test-Instance }
    'Get' 
      { Get-Feature -OSType $osType -Name $Name }
    'Test' 
      { Test-Feature -OSType $osType -Name $Name -Ensure $Ensure }
    'Set' 
      { Set-Feature -OSType $osType -Name $Name -Ensure $Ensure }
  }

  if (!$feature) { 
    exit 3; throw New-Object ArgumentException "Feature '$Name' not found on Windows OS Type: $(
      switch($osType) { 1 { 'Client' } default { 'Server' } } )"
  }

  $featureProperties = @( 
    @{ Name = 'name'; Expression = { $_.FeatureName } },
    @{ Name = 'ensure'; Expression = { "$($_.State)".ToLower() } }, 
    @{ Name = 'restartNeeded'; Expression = { $_.RestartNeeded } },
    @{ Name = 'restartRequired'; Expression = { "$($_.RestartRequired)".ToLower() } }
  )

  $feature | Select-Object $featureProperties | ConvertTo-Yaml
}

function Get-Feature {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [int]$OSType,

    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrWhiteSpace()]
    [string]$Name
  )

  switch ($OSType) {
    1 { Get-WindowsOptionalFeature -Online -FeatureName $Name }
    default { Get-WindowsFeature -Name $Name }  
  }
}

function Test-Instance {
  [CmdletBinding()]
  param() 

  throw New-Object NotImplementedException 'Test-Instance'
}

function Test-Feature {
  [CmdletBinding()]
  param( 
    [Parameter(Position = 0, Mandatory = $true)]
    [int]$OSType,

    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrWhiteSpace()]
    [string]$Name,

    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateNotNullOrWhiteSpace()]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$Ensure
  )

  $feature = Get-Feature -OSType $OSType -Name $Name
  if ($feature.State -eq $Ensure) {
    'Fine'
  } else {
    'NotFine'
  }
}

function Set-Feature { 
  [CmdletBinding()]
  param( 
    [Parameter(Position = 0, Mandatory = $true)]
    [int]$OSType,

    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrWhiteSpace()]
    [string]$Name,

    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateSet('Enabled', 'Disabled')]
    [ValidateNotNullOrWhiteSpace()]
    [string]$Ensure
  )
  
  switch ($Ensure) {
    'Enabled' {
      switch ($OSType) {
        1 { Enable-WindowsOptionalFeature -Online -FeatureName $Name -EA Silent }
        default { Enable-WindowsFeature -Name $Name -EA Silent }
      }
    }
    'Disabled' { 
      switch ($OSType) {
        1 { Disable-WindowsOptionalFeature -Online -FeatureName $Name -EA Silent }
        default { Disable-WindowsFeature -Name $Name -EA Silent }  
      }
    }
    default {
      exit 4; throw New-Object ArgumentException "Invalid Ensure type: $Ensure"  
    }
  }
}