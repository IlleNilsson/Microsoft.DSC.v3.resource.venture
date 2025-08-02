# Get Feature State
$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
$feature = $null
switch ($osType) {
    1 { 
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $Name 
    }
    default {
        $feature = Get-WindowsFeature -Name $Name
    }  
}

if (!$feature) { 
    throw New-Object ArgumentException "Feature '$Name' not found"
}

return $feature | ConvertTo-Yaml

# Test Feature
$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
switch ($osType) {
    1 { 
    }
    default {
    }  
}

# Set Feature
$osType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
switch ($osType) {
    1 { 
    }
    default {
    }  
}
