$ProgressTitle = "PowerExpressGUI Bootstrapper";
$TaskName = "PowerExpressGUI";
$SetupPath = "C:\PowerExpressGUI";
$AutorunFile = "$SetupPath\autorun.ps1";
$AutorunUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/content/driver-update.ps1";

Write-Progress -Activity $ProgressTitle -Status "Registering ScheduledTask";

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction `
    -Execute "powershell" `
    -Argument "-WindowStyle Normal -ExecutionPolicy Bypass -File C:\PowerExpressGUI\autorun.ps1"

$Trigger = New-ScheduledTaskTrigger `
    -Once `
    -At ([DateTime]::Now)

$Principal = New-ScheduledTaskPrincipal `
    -GroupId "Administrators" `
    -RunLevel Highest

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -StartWhenAvailable `
    -DontStopIfGoingOnBatteries `
    -Priority 4;

Register-ScheduledTask `
    -TaskName $TaskName `
    -Description "Runs a PowerShell script that automatically downloads and installs all driver updates through PSWindowsUpdate on startup." `
    -Action $Action `
    -Principal $Principal `
    -Settings $Settings `
    -Trigger $Trigger `
    -Force;

$Task = Get-ScheduledTask -TaskName $TaskName;

if ($Task) {
    # Download the autorun script
    Write-Progress -Activity $ProgressTitle -Status "Initializing directory";
    New-Item -Path $SetupPath -ItemType Directory -Force;

    Write-Progress -Activity $ProgressTitle -Status "Downloading files";
    Invoke-RestMethod -Uri $AutorunUrl -OutFile $AutorunFile;

    Write-Progress -Activity $ProgressTitle -Status "Completed!";
    Start-Sleep -Seconds 1;
}
else {
    Write-Progress -Activity $ProgressTitle -Status "Error: Failed to register task.";
    Start-Process "powershell" -Verb RunAs -Wait -ArgumentList "-NoExit -Command 'echo Looks like PowerExpressGUI ran into an error. You can use this terminal to see what went wrong, or close and continue your installation like normal.'";
}
