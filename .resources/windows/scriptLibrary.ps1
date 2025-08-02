# Get Feature State
#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator

$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
$feature = $null
switch ($osType) {
    1       { $feature = Get-WindowsOptionalFeature -Online -FeatureName $name }
    default { $feature = Get-WindowsFeature -Name $name }  
}

if (!$feature) { 
    throw New-Object ArgumentException "Feature '$name' not found"
}

return $feature | ConvertTo-Yaml

# Test Feature
#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator

$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
switch ($osType) {
    1       { }
    default { }  
}

# Set Feature
#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator

$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
switch ($osType) {
    1       { }
    default { }  
}
