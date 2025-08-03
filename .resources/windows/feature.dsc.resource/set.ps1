#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator

$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
$feature = if ($args['ensure'] -eq 'enabled') {
    switch ($osType) {
        1       { Enable-WindowsOptionalFeature -Online -FeatureName $args['name'] -EA Silent }
        default { Enable-WindowsFeature -Name $args['name'] -EA Silent }
    }} else { 
        switch ($osType) {
        1       { Disable-WindowsOptionalFeature -Online -FeatureName $args['name'] -EA Silent }
        default { Disable-WindowsFeature -Name $args['name'] -EA Silent }  
    }}

if (!$feature) { 
    throw New-Object ArgumentException "Feature '$($args['name'])' not found"
}

return $feature | ConvertTo-Yaml
