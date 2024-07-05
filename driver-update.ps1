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
    Install-PackageProvider -Name NuGet -Force;
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
    Install-Module -Name PSWindowsUpdate -Force;
    Start-Sleep -Seconds 1;

    if (Import-Module PSWindowsUpdate -Force) {
        Write-Host 'Extraction Successful.';
        CheckForUpdates;
    }
}
