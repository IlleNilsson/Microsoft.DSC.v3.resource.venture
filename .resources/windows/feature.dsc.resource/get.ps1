#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [parameter(position = 0, mandatory = $true)]
    [validateNotNullOrWhiteSpace()]
    [string]$name
)

$platform = [System.Environment]::OSVersion.Platform
$supportedPlatforms = @('Win32NT')
if (!($supportedPlatforms -contains $platform)) {
    throw New-Object ArgumentException "Unsupported Platform: $platform, supported platforms: $supportedPlatforms"    
}

$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
$feature = switch ($osType) {
    1       { Get-WindowsOptionalFeature -Online -FeatureName $name }
    default { Get-WindowsFeature -Name $name }  
}

if (!$feature) { 
    throw New-Object ArgumentException "Feature '$name' not found on Windows OS Type: $osType"
}

$featureProperties = @( 
    @{ Name = 'name';            Expression = { $_.FeatureName } },
    @{ Name = 'ensure';          Expression = { "$($_.State)".ToLower() } }, 
    @{ Name = 'restartNeeded';   Expression = { $_.RestartNeeded } },
    @{ Name = 'restartRequired'; Expression = { "$($_.RestartRequired)".ToLower() } }
)

$feature | Select-Object $featureProperties | ConvertTo-Yaml
