
$Script = "irm https://github.com/SapphSky/PowerExpressGUI/raw/main/driver-update.ps1 | iex";
$Command = "Start-Process powershell -Command { $Script }";
$ArgumentList = "-NoLogo -Command { $Command }";
$ActionArgument = "Start-Process powershell -Verb RunAs -ArgumentList '$ArgumentList'";
$action = New-ScheduledTaskAction -Execute "powershell" -Argument $ActionArgument;
$trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -Seconds 30);
$settings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter (New-TimeSpan -Days 1);

Register-ScheduledTask -Trigger $trigger -Action $action -Settings $settings -Force -RunLevel Highest;
