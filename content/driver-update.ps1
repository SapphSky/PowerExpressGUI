$MaxAttempts = 5;

Get-PackageProvider -Name Nuget -ForceBootstrap;
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
        Install-WindowsUpdate -AcceptAll -UpdateType Driver;
        break;
    }
    $i++;
}

# Start-Process powershell -Verb RunAs -ArgumentList "-Command (Invoke-Command -ScriptBlock {$Command})";
