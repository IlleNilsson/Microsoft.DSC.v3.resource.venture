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
$feature = switch ($osType) {
    1       { Get-WindowsOptionalFeature -Online -FeatureName $args['name'] }
    default { Get-WindowsFeature -Name $args['name'] }  
}

if (!$feature) { 
    throw New-Object ArgumentException "Feature '$($args['name'])' not found on Windows OS Type: $osType"
}

return $feature | ConvertTo-Yaml
