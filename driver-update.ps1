function CheckForUpdates {
    Write-Host 'Checking for driver updates...';
    Install-WindowsUpdate -AcceptAll -UpdateType Driver -Verbose -AutoReboot;
    Write-Host 'Driver updates completed.';
}

if (Get-Module -Name PSWindowsUpdate) {
    CheckForUpdates;
}
else {
    Write-Progress -Activity "Installing PSWindowsUpdate..." -CurrentOperation "Installing NuGet Package Provider";
    Install-PackageProvider -Name NuGet -Force | Out-Null;
    Write-Progress -Activity "Installing PSWindowsUpdate..." -CurrentOperation "Setting Installation Policy...";
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
    Write-Progress -Activity "Installing PSWindowsUpdate..." -CurrentOperation "Installing Module";
    Install-Module -Name PSWindowsUpdate -Force;
    Write-Progress -Activity "Installing PSWindowsUpdate..." -Completed

    if (!Get-Module -Name PSWindowsUpdate) {
        Write-Error 'Error: Could not get PSWindowsUpdate module.';
        return;
    }

    if (Import-Module -Name PSWindowsUpdate -Force) {
        Write-Host 'Extraction Successful.';
        CheckForUpdates;
    }
}
