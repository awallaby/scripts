$registry_path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown"
$name         = "value"
$value        = "1"
If (-NOT (Test-Path $registry_path)) {
  New-Item -Path $registry_path -Force | Out-Null
}  
New-ItemProperty -Path $registry_path -Name $name -Value $value -PropertyType DWORD -Force 