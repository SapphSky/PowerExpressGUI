$Executable = "powershell.exe";
$Url = "https://github.com/SapphSky/PowerExpressGUI/raw/main/driver-update.ps1";
$ArgumentList = """-Command 'irm $Url | iex'""";
$Command = """Start-Process $Executable -Verb RunAs -WindowStyle Normal -ArgumentList $ArgumentList""";
$Argument = "-Command $Command";

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction -Execute $Execute -Argument $Argument;
$Trigger = New-ScheduledTaskTrigger -AtStartup;
$Settings = New-ScheduledTaskSettingsSet -AsJob -DeleteExpiredTaskAfter (New-TimeSpan -Days 1) -DontStopIfGoingOnBatteries $true -ExecutionTimeLimit (New-TimeSpan -Hours 8) -Priority 3 -StartWhenAvailable $true;

Register-ScheduledTask AutoUpdateDrivers -Action $Action -Trigger $Trigger -Settings $Settings -RunLevel Highest;
