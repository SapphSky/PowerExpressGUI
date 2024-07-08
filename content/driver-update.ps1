$DebugMode = $false;
$MaxAttempts = 5;
$ProgressTitle = "PowerExpressGUI - Driver Updates";

for ($i = 1; $i -le $MaxAttempts; $i++) {
    if (-Not (Get-PackageProvider -Name Nuget)) {
        Write-Host 'Installing NuGet Package Provider...';
        Install-PackageProvider -Name NuGet -Force;
    }
    if (-Not (Get-PSRepository -Name PSGallery)) {
        Write-Host 'Trusting PSGallery Repository...';
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
    }
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
