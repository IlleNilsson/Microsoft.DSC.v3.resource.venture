#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [parameter(position = 0, mandatory = $true)]
    [validateNotNullOrWhiteSpace()]
    [string]$name,

    [parameter(position = 1, mandatory = $true)]
    [validateSet('enabled', 'disabled')]
    [string]$ensure
)

$platform = [System.Environment]::OSVersion.Platform
$supportedPlatforms = @('Win32NT')
if (!($supportedPlatforms -contains $platform)) {
    throw New-Object ArgumentException "Unsupported Platform: $platform, supported platforms: $supportedPlatforms"    
}

$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
$feature = switch ($ensure) {
    'enabled' {
        switch ($osType) {
            1       { Enable-WindowsOptionalFeature -Online -FeatureName $name -EA Silent }
            default { Enable-WindowsFeature -Name $name -EA Silent }
        }
    }
    'disabled' { 
        switch ($osType) {
            1       { Disable-WindowsOptionalFeature -Online -FeatureName $name -EA Silent }
            default { Disable-WindowsFeature -Name $name -EA Silent }  
        }
    }
}

if (!$feature) { 
    throw New-Object ArgumentException "Feature '$name' not found on Windows OS Type: $osType"
}

$featureProperties = @( 
    @{ Name = 'name'; Expression = { $_.FeatureName } },
    @{ Name = 'ensure'; Expression = { "$($_.State)".ToLower() } }, 
    @{ Name = 'restartNeeded'; Expression = { $_.RestartNeeded } },
    @{ Name = 'restartRequired'; Expression = { "$($_.RestartRequired)".ToLower() } }
)

$feature | Select-Object $featureProperties | ConvertTo-Yaml
