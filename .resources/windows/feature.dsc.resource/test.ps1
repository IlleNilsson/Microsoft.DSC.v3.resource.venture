#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator

$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
$feature = switch ($osType) {
    1       { Get-WindowsOptionalFeature -Online -FeatureName $args['name'] }
    default { Get-WindowsFeature -Name $args['name'] }  
}

if (!$feature) { 
    throw New-Object ArgumentException "Feature '$($args['name'])' not found"
}

return $feature | ConvertTo-Yaml
