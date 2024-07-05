function CheckForUpdates {
    Write-Host 'Checking for driver updates...';
    Install-WindowsUpdate -AcceptAll -UpdateType Driver -Verbose -AutoReboot;
    Write-Host 'Driver updates completed.';
}

if (Get-Module -Name PSWindowsUpdate) {
    CheckForUpdates;
}
else {
    Write-Host 'Installing PSWindowsUpdate...';
    Install-PackageProvider -Name NuGet -Force | Out-Null;
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
    Install-Module -Name PSWindowsUpdate -Force;

    if (!Get-Module -Name PSWindowsUpdate) {
        Write-Error 'Error: Could not get PSWindowsUpdate module.';
        return;
    }
    
    if (Import-Module -Name PSWindowsUpdate -Force) {
        Write-Host 'Extraction Successful.';
        CheckForUpdates;
    }
}
