$MaxAttempts = 5;

for ($i = 1; $i -le $MaxAttempts; $i++) {
    if (-Not (Get-PackageProvider -Name Nuget)) {
        Install-PackageProvider -Name NuGet -Force;
    }
    if (-Not (Get-PSRepository -Name PSGallery)) {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
    }
    if (-Not (Get-Module -Name PSWindowsUpdate)) {
        Install-Module -Name PSWindowsUpdate -Force;
        Start-Sleep -Seconds 1;
        Import-Module -Name PSWindowsUpdate -Force;
    }
    else {
        Write-Host 'Checking for driver updates...';
        Install-WindowsUpdate -AcceptAll -UpdateType Driver;
        Write-Host 'Driver updates completed. Computer will now automatically restart (if necessary)';
        break;
    }
    $i++;
}
