# Download the Task Scheduler XML file
$TaskXmlUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/task.xml";
$TaskXmlFile = "C:\PowerExpressGUI\task.xml";
Invoke-RestMethod $TaskXmlUrl -OutFile $TaskXmlFile;

# Download the autorun script
$AutorunUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/driver-update.ps1";
$AutorunFile = "C:\PowerExpressGUI\autorun.ps1";
Invoke-RestMethod -Uri $AutorunUrl -OutFile $AutorunFile;

if (Test-Path $TaskXmlFile && Test-Path $AutorunFile) {
    Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Registering Scheduled Task";
    schtasks.exe /Create /XML $TaskXmlFile /tn "PowerExpressGUI - Auto Install Drivers";
}

Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Completed";
Start-Sleep -Seconds 1;

# Disabled code, please ignore
# Register-ScheduledTask -TaskName "PowerExpressGUI" -Xml $ScheduledTaskXML;
# schtasks /create /sc ONLOGON /tn "powerexpressgui\Install Drivers" /tr "powershell.exe -NoLogo -NoExit -File $FilePath" /ru System /mo ONLOGON /z /rl HIGHEST /delay 0000:10;
# Creates a Scheduled Task to run our script at startup
# $Action = New-ScheduledTaskAction -Execute $FilePath;
# $Trigger = New-ScheduledTaskTrigger -AtLogon;
# $Settings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter (New-TimeSpan -Days 1);
# Register-ScheduledTask -TaskName "PowerExpressGUI" -Description "From SapphSky/PowerExpressGUI" -Action $Action -Trigger $Trigger -Settings $Settings -RunLevel Highest;
