# Test Feature
#Requires -Version 7.5
#Requires -PSEdition Core
#Requires -RunAsAdministrator

$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
switch ($osType) {
    1       { }
    default { }  
}
