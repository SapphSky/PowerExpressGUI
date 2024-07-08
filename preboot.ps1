$ProgressTitle = "PowerExpressGUI Bootstrapper";
$TaskName = "PowerExpressGUI";
$TaskDesc = "Runs a PowerShell script that automatically launches PowerExpressGUI on login.";
$SourceUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/content/driver-update.ps1";

Write-Progress -Activity $ProgressTitle -Status "Registering ScheduledTask";

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction `
    -Execute "powershell" `
    -Argument "-ExecutionPolicy Bypass -Command 'irm $SourceUrl | iex'"

$Trigger = New-ScheduledTaskTrigger `
    -AtLogon

$Principal = New-ScheduledTaskPrincipal `
    -GroupId "Administrators" `
    -RunLevel Highest

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -StartWhenAvailable `
    -DontStopIfGoingOnBatteries;

Register-ScheduledTask `
    -TaskName $TaskName `
    -Description $TaskDesc `
    -Action $Action `
    -Principal $Principal `
    -Settings $Settings `
    -Trigger $Trigger `
    -Force;

$Task = Get-ScheduledTask -TaskName $TaskName;

if ($Task) {
    Write-Progress -Activity $ProgressTitle -Status "Completed!";
    Start-Sleep -Seconds 1;
}
else {
    Write-Progress -Activity $ProgressTitle -Status "Error: Failed to register task.";
    Start-Process "powershell" -Verb RunAs -Wait -ArgumentList "-NoExit -Command 'echo PowerExpressGUI ran into an error. Use this terminal to debug, or close and continue the installation like normal.'";
}
