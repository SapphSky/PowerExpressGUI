function CheckForUpdates {
    Write-Host 'Checking for driver updates...';
    Install-WindowsUpdate -AcceptAll -UpdateType Driver;
    Write-Host 'Driver updates completed. Computer will now automatically restart (if necessary)';
}

Import-Module -Name PSWindowsUpdate -Force;

if (Get-Module -Name PSWindowsUpdate) {
    Write-Host 'PSWindowsUpdate module installed. Skipping installation.';
    CheckForUpdates;
}
else {
    Write-Progress -Activity "Installing PSWindowsUpdate..." -CurrentOperation "Installing NuGet Package Provider";
    Install-PackageProvider -Name NuGet -Force | Out-Null;
    Write-Progress -Activity "Installing PSWindowsUpdate..." -CurrentOperation "Setting Installation Policy...";
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
    Write-Progress -Activity "Installing PSWindowsUpdate..." -CurrentOperation "Installing Module";
    Install-Module -Name PSWindowsUpdate -Force;
    Write-Progress -Activity "Installing PSWindowsUpdate..." -Completed;

    if (-Not (Get-Module -Name PSWindowsUpdate)) {
        Write-Error 'Error: Could not find PSWindowsUpdate module.';
        exit;
    }

    if (Import-Module -Name PSWindowsUpdate -Force) {
        Write-Host 'Module successfully installed.';
        CheckForUpdates;
    }
}
