$Url = "https://github.com/SapphSky/PowerExpressGUI/raw/main/driver-update.ps1";
$FilePath = "C:\PowerExpressGUI\autorun.ps1";

# Download the script
Write-Progress -Activity "Bootstrapping PowerExpressGUI" -Status "Downloading script";
Invoke-RestMethod $Url -OutFile $FilePath;
Write-Progress -Activity "Bootstrapping PowerExpressGUI" -Status "Registering Scheduled Task";

# $schtasksCommand = 'schtasks /create /sc ONLOGON /tn "powerexpressgui\Install Drivers" /tr powershell.exe /ru System /mo ONLOGON /z /rl HIGHEST /delay 0000:10'

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction -Execute $FilePath;
$Trigger = New-ScheduledTaskTrigger -AtLogon;
$Settings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter (New-TimeSpan -Days 1);
Register-ScheduledTask -TaskName "PowerExpressGUI" -Description "From SapphSky/PowerExpressGUI" -Action $Action -Trigger $Trigger -Settings $Settings -RunLevel Highest;

Write-Progress -Activity "Bootstrapping PowerExpressGUI" -Completed;
Start-Sleep -Seconds 1;
