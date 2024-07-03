$Uri = 'https://psg-prod-eastus.azureedge.net/packages/pswindowsupdate.2.2.0.3.nupkg';
$OutFile = 'C:\' + $(Split-Path -Path $Uri -Leaf) + '.zip';
$DestinationPath = 'C:\Program Files\WindowsPowerShell\Modules\pswindowsupdate';

function CheckForUpdates {
    Write-Host 'Checking for driver updates...';
    Install-WindowsUpdate -AcceptAll -UpdateType Driver -Verbose -AutoReboot;
    Write-Host 'Driver updates completed.';
}

# if (Import-Module -Name $DestinationPath -Force) {
if (Get-Module -Name PSWindowsUpdate) {
    CheckForUpdates;
}
else {
    Install-PackageProvider -Name NuGet -Force;
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted;
    # Write-Host 'Downloading PSWindowsUpdate module...';
    # Invoke-RestMethod -Uri $Uri -OutFile $OutFile -TimeoutSec 30;
    # Expand-Archive -LiteralPath $OutFile -DestinationPath $DestinationPath;

    # Write-Host 'Cleaning up files...';
    # Remove-Item $OutFile
    # Remove-Item -Path """$DestinationPath\_rels""" -Recurse;
    # Remove-Item -Path """$DestinationPath\package""" -Recurse;
    # Remove-Item -Path """$DestinationPath\[Content-Types].xml""";
    # Remove-Item -Path """$DestinationPath\*.nuspec""";
    # Start-Sleep -Seconds 1;
    Install-Module -Name PSWindowsUpdate -Force;

    if (Import-Module -Name $DestinationPath -Force) {
        Write-Host 'Extraction Successful.';
        CheckForUpdates;
    }
}
