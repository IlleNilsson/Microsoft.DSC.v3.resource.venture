#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator

function Request-Feature {
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

    [Parameter(Position = 1, Mandatory = $true, ParameterSetName = 'Get', 'Test', 'Set')]
    [ValidateNotNullOrWhiteSpace()]
    [string]$Name,

    [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Test', 'Set')]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$Ensure
  )

  $supportedPlatforms = @('Win32NT')
  $platform = [System.Environment]::OSVersion.Platform
  if (!($supportedPlatforms -contains $platform)) {
    throw New-Object ArgumentException "Unsupported Platform: $platform, supported platforms: $supportedPlatforms"    
  }

  $osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
  $feature = switch ($parameterSetName) {
    'Validate' { Test-Instance }
    'Get' { Get-Feature -OSType $osType -Name $Name }
    'Test' { Test-Feature -OSType $osType -Name $Name -Ensure $Ensure }
    'Set' { Set-Feature -OSType $osType -Name $Name -Ensure $Ensure }
  }

  if (!$feature) { 
    throw New-Object ArgumentException "Feature '$Name' not found on Windows OS Type: $(
      switch($osType) { 1 { 'Client' } default { 'Server' } } )"
  }

  $featureProperties = @( 
    @{ Name = 'name'; Expression = { $_.FeatureName } },
    @{ Name = 'ensure'; Expression = { "$($_.State)".ToLower() } }, 
    @{ Name = 'restartNeeded'; Expression = { $_.RestartNeeded } },
    @{ Name = 'restartRequired'; Expression = { "$($_.RestartRequired)".ToLower() } }
  )

  Select-Object $featureProperties | ConvertTo-Yaml
}

function Test-Instance { 
  throw New-Object NotImplementedException 'Test-Instance'
}

function Get-Feature {
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

function Test-Feature {
  param( 
    [Parameter(Position = 0, Mandatory = $true)]
    [int]$OSType,

    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrWhiteSpace()]
    [string]$Name,

    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$Ensure
  )

  $feature = Get-Feature -OSType $OSType -Name $Name

  if ($feature.State -eq $Ensure) {
    'Fine'
  }
  else {
    'NotFine'
  }
}

function Set-Feature { 
  param( 
    [Parameter(Position = 0, Mandatory = $true)]
    [int]$OSType,

    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrWhiteSpace()]
    [string]$Name,

    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateSet('Enabled', 'Disabled')]
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
      throw New-Object ArgumentException "Invalid Ensure type: $Ensure"  
    }
  }
}