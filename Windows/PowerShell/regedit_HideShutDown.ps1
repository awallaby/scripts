<#
.DESCRIPTION
    Hide "Shut down" option from Windows Start menu  
.LANGUAGE
    PowerShell
.TIMEOUT
    100
.LINK
    https://github.com/awallaby/scripts/blob/main/Windows/PowerShell/regedit_HideShutDown.ps1
#>

$script_name = $MyInvocation.MyCommand.Name
$log_path = ("C:\level_automation_logs\${script_name}") -Replace '.ps1', ""
$datetime   = Get-Date -f 'yyyyMMddHHmmss'
$filename   = "Transcript-${script_name}-${datetime}.log"
Start-Transcript -Path (Join-Path $log_path -ChildPath $filename)

$registry_path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown"
$name         = "value"
$value        = "1"
If (-NOT (Test-Path $registry_path)) {
  New-Item -Path $registry_path -Force | Out-Null
}  
New-ItemProperty -Path $registry_path -Name $name -Value $value -PropertyType DWORD -Force 