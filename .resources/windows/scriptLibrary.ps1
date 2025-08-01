# Get Feature State
$computerType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
$feature = $null
switch ($computerType) {
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
$computerType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
switch ($computerType) {
    1 { 
    }
    default {
    }  
}

# Set Feature
$computerType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
switch ($computerType) {
    1 { 
    }
    default {
    }  
}
