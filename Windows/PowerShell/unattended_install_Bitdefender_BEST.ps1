<#
.DESCRIPTION
    Downloads the Bitdefender BEST installer wrapper and runs the installation silently,
    using the extracted GZ_PACKAGE_ID (the base64 string) from the second link.
    After successful installation, it cleans up the downloaded files.
.LANGUAGE
    PowerShell
.TIMEOUT
    300
.LINK
    N/A (Custom Script)
#>

# --- Transcript Setup ---
$script_name = $MyInvocation.MyCommand.Name
# Define a general log directory and create a specific path for this script's logs
$log_dir = "C:\level_automation_logs"
$log_path = (Join-Path $log_dir -ChildPath $script_name) -Replace '.ps1', ""
$datetime = Get-Date -f 'yyyyMMddHHmmss'
$filename = "Transcript-${script_name}-${datetime}.log"

# Create log directory if it doesn't exist
If (-NOT (Test-Path $log_path)) {
    Write-Host "Creating log directory: $log_path"
    New-Item -Path $log_path -ItemType Directory -Force | Out-Null
}

# Start logging the script's execution
Start-Transcript -Path (Join-Path $log_path -ChildPath $filename) -Force

# --- Configuration Variables ---
$msi_url = "https://download.bitdefender.com/SMB/Hydra/release/bst_win/downloaderWrapper/BEST_downloaderWrapper.msi?_gl=1*1rf0son*_ga*OTU1MDM4Mjc3LjE3NTk1MjA0Nzc.*_ga_6M0GWNLLWF*czE3NTk3MDU3NjYkbzQkZzEkdDE3NTk3MDc0MjkkajYwJGwwJGgxMzcyNDAxNDg."
$exe_url = "https://cloud.gravityzone.bitdefender.com/Packages/BSTWIN/0/setupdownloader_[aHR0cHM6Ly9jbG91ZC1lY3MuZ3Jhdml0eXpvbmUuYml0ZGVmZW5kZXIuY29tL1BhY2thZ2VzL0JTVFdJTi8wL3FOQzBHNC9pbnN0YWxsZXIueG1sP2xhbmc9ZW4tVVM=].exe"
# Using a temporary, reliably writable location for downloads
$target_dir = Join-Path $env:TEMP "Bitdefender_Install"
$msi_filename = "BEST_MSIWrapper.msi"
$exe_filename = "BEST_setup.exe" # Use a consistent name for local file
$msi_file_path = Join-Path $target_dir $msi_filename
$exe_file_path = Join-Path $target_dir $exe_filename

# --- 1. Ensure Download Directory Exists ---
Write-Host "Checking if target directory '$target_dir' exists..."
If (-NOT (Test-Path $target_dir)) {
    Write-Host "Directory not found. Creating '$target_dir'..."
    New-Item -Path $target_dir -ItemType Directory -Force | Out-Null
}

# --- 2. Extract GZ_PACKAGE_ID (the 'string') ---
# Use regex to find the content between '[' and ']'
Write-Host "Extracting GZ_PACKAGE_ID from the EXE URL..."
$regex_match = [regex]::Match($exe_url, "\[(.+?)\]")
if ($regex_match.Success) {
    $gz_package_id = $regex_match.Groups[1].Value
    Write-Host "Extracted GZ_PACKAGE_ID: $gz_package_id"
} else {
    Write-Error "Failed to extract GZ_PACKAGE_ID from the EXE URL. Aborting."
    Stop-Transcript
    exit 1
}

# --- 3. Download Files ---

function Download-File {
    param (
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$OutFile
    )
    Write-Host "Attempting to download '$Uri' to '$OutFile'..."
    try {
        # Using Invoke-WebRequest for file download
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile -ErrorAction Stop
        Write-Host "Download successful: $OutFile"
        return $true
    } catch {
        Write-Error "Download failed for $Uri. Error: $($_.Exception.Message)"
        return $false
    }
}

# Download MSI
$msi_download_success = Download-File -Uri $msi_url -OutFile $msi_file_path
if (-not $msi_download_success) {
    Stop-Transcript
    exit 1
}

# Download EXE (The second download is requested, though likely not strictly necessary for the MSI)
$exe_download_success = Download-File -Uri $exe_url -OutFile $exe_file_path
if (-not $exe_download_success) {
    Write-Warning "EXE file download failed. Continuing to MSI installation as planned."
}

# --- 4. Run Installation Command ---
$install_command = "msiexec"
$install_args = @(
    "/i",
    "`"$msi_file_path`"",  # Path to the MSI file (now points to temp directory)
    "/qn",                 # Quiet mode (no UI)
    "GZ_PACKAGE_ID=$gz_package_id", # The string we extracted
    "REBOOT_IF_NEEDED=1"   # Installation parameter
)

Write-Host "Starting installation..."
Write-Host "Command: $install_command $($install_args -join ' ')"

try {
    # Use Start-Process -Wait to ensure the script pauses until installation is complete
    $process = Start-Process -FilePath $install_command -ArgumentList $install_args -Wait -PassThru -ErrorAction Stop
    
    # 0 is success, 3010 is success with pending reboot (common for installers)
    if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) { 
        Write-Host "Installation completed successfully (Exit Code: $($process.ExitCode))."
        $install_success = $true
    } else {
        Write-Error "Installation failed with exit code: $($process.ExitCode)."
        $install_success = $false
    }
} catch {
    Write-Error "Error executing installation command: $($_.Exception.Message)"
    $install_success = $false
}

# --- 5. Cleanup ---
if ($install_success) {
    Write-Host "Installation successful. Starting cleanup..."
    
    # Remove MSI file
    try {
        Remove-Item -Path $msi_file_path -Force -ErrorAction Stop
        Write-Host "Successfully removed MSI file: $msi_file_path"
    } catch {
        Write-Warning "Failed to remove MSI file: $msi_file_path. Error: $($_.Exception.Message)"
    }
    
    # Remove EXE file (if it was downloaded)
    if (Test-Path $exe_file_path) {
        try {
            Remove-Item -Path $exe_file_path -Force -ErrorAction Stop
            Write-Host "Successfully removed EXE file: $exe_file_path"
        } catch {
            Write-Warning "Failed to remove EXE file: $exe_file_path. Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "EXE file was not present for removal."
    }

    # Remove the temporary folder
    try {
        Remove-Item -Path $target_dir -Recurse -Force -ErrorAction Stop
        Write-Host "Successfully removed temporary directory: $target_dir"
    } catch {
        Write-Warning "Failed to remove temporary directory: $target_dir. Error: $($_.Exception.Message)"
    }

} else {
    Write-Host "Installation failed. Skipping file cleanup."
}

Stop-Transcript
