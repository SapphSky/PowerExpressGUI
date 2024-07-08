$CommandBlock = {
    $MaxAttempts = 5;

    Write-Host 'Getting Package Provider'
    Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null;
    Write-Host 'Setting Repository'
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        if (-Not (Get-Module -Name PSWindowsUpdate)) {
            Write-Host 'Installing PSWindowsUpdate Module...';
            Install-Module -Name PSWindowsUpdate -Force;
            Start-Sleep -Seconds 1;
            Write-Host 'Importing module...';
            Import-Module -Name PSWindowsUpdate -Force;
        }
        else {
            Write-Host "Checking for updates...";
            Install-WindowsUpdate -AcceptAll -UpdateType Driver -AutoReboot;
            break;
        }
        $i++;
    }
}

Start-Process powershell -Verb RunAs -Wait -ArgumentList "-WindowStyle Normal -Command $CommandBlock"