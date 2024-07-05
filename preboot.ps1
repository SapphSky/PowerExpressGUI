# $Executable = "powershell.exe";
# $Url = "https://github.com/SapphSky/PowerExpressGUI/raw/main/driver-update.ps1";
# $Argument = "-Command 'irm $Url | iex'";

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command 'irm https://github.com/SapphSky/PowerExpressGUI/raw/main/driver-update.ps1 | iex";
$Trigger = New-ScheduledTaskTrigger -AtLogon  -RandomDelay (New-TimeSpan -Minutes 1) -User "defaultuser0";
$Principal = New-ScheduledTaskPrincipal -UserId "$($env:USERDOMAIN)\defaultuser0" -LogonType ServiceAccount
$Settings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter (New-TimeSpan -Days 1);

Register-ScheduledTask -TaskName "PowerExpressGUI" -TaskPath "\PowerExpressGUI" -Description "From SapphSky/PowerExpressGUI" -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Force;

