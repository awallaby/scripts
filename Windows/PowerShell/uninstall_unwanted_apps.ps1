<#
.DESCRIPTION
    Uninstall unwanted apps
.LANGUAGE
    PowerShell
.TIMEOUT
    100
.LINK
    https://github.com/awallaby/scripts/blob/main/Windows/PowerShell/uninstall_unwanted_apps.ps1
#>

$script_name = $MyInvocation.MyCommand.Name
$log_path = ("C:\level_automation_logs\${script_name}") -Replace '.ps1', ""
$datetime   = Get-Date -f 'yyyyMMddHHmmss'
$filename   = "Transcript-${script_name}-${datetime}.log"
Start-Transcript -Path (Join-Path $log_path -ChildPath $filename)

$unwanted_win32_app_names = @('GoTo Opener', 'Zoom(64bit)', 'Teams Machine-Wide Installer', 'Zoom', 'Adobe Acrobat (64-bit)', 'Adobe Refresh Manager')
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -in $unwanted_win32_app_names } | ForEach-Object { $_.Uninstall() }

# $unwanted_package_names = @('WinRAR 6.11 (64-bit)', 'Mozilla Firefox (x64 en-US)', 'AnyDesk', 'WebAdvisor by McAfee')
# Get-Package -Provider Programs -IncludeWindowsInstaller | Where-Object { $_.Name -in $unwanted_package_names } | Uninstall-Package -Force -AllVersions
# $uninstall_commands = Get-Package -Provider Programs -IncludeWindowsInstaller | Where-Object { $_.Name -in $unwanted_package_names } | Select-Object { $_.Meta.Attributes['UninstallString'] }
# $uninstall_commands = ForEach-Object { Start-Process -FilePath cmd.exe -ArgumentList '/c', $_ -Wait }

Stop-Transcript