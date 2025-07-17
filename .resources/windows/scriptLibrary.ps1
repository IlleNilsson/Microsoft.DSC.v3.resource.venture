# Get Feature State
$computerType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
$feature = $null
switch ($computerType) {
    1 { 
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName 
    }
    default {
        $feature = Get-WindowsFeature -Name $FeatureName
    }  
}

if (!$feature) { 
    throw New-Object ArgumentException "Feature '$FeatureName' not found"
}

return ($feature | ConvertTo-Json -Compress)

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
