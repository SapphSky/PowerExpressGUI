$Url = "https://github.com/SapphSky/PowerExpressGUI/raw/main/driver-update.ps1";
$FilePath = "C:\PowerExpressGUI\autorun.ps1";

# Download the script
Invoke-RestMethod $Url -OutFile $FilePath;

if (Test-Path -Path $FilePath) {
    Write-Host "Download completed.";
}
else {
    Write-Host "Error: $FilePath not found.";
}
Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Registering Scheduled Task";

# Creates a Scheduled Task to run our script at startup
# $Action = New-ScheduledTaskAction -Execute $FilePath;
# $Trigger = New-ScheduledTaskTrigger -AtLogon;
# $Settings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter (New-TimeSpan -Days 1);
# Register-ScheduledTask -TaskName "PowerExpressGUI" -Description "From SapphSky/PowerExpressGUI" -Action $Action -Trigger $Trigger -Settings $Settings -RunLevel Highest;
schtasks /create /sc ONLOGON /tn "powerexpressgui\Install Drivers" /tr "powershell.exe -NoLogo -NoExit -File $FilePath" /ru System /mo ONLOGON /z /rl HIGHEST /delay 0000:10;

Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Completed";
Start-Sleep -Seconds 1;
