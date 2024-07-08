$ProgressTitle = "PowerExpressGUI Bootstrapper";

Write-Progress -Activity $ProgressTitle -Status "Registering Scheduled Task";

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction -Execute "powershell" -Argument "-ExecutionPolicy Bypass -File C:\PowerExpressGUI\autorun.ps1";
$Trigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay (New-TimeSpan -Seconds 10);
$Principal = New-ScheduledTaskPrincipal -GroupId "Administrators" -RunLevel Highest;
$Settings = New-ScheduledTaskSettingsSet;
# -AllowStartIfOnBatteries $true `
# -DeleteExpiredTaskAfter (New-TimeSpan -Days 1) `
# -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
# -Priority 4 `
# -RestartCount 3 `
# -RestartInverval (New-TimeSpan -Minutes 5);

$Description = "Runs a PowerShell script that automatically downloads and installs all driver updates through PSWindowsUpdate on startup. `
This task will automatically remove itself after 1 day.";
Register-ScheduledTask -TaskName "PowerExpressGUI" -Description $Description `
    -Action $Action `
    -Principal $Principal `
    -Settings $Settings `
    -Trigger $Trigger `
    -Force;

Start-Sleep -Seconds 1;

if (Get-ScheduledTask -TaskName "PowerExpressGUI") {
    # Download the autorun script
    if (-Not (Test-Path "C:\PowerExpressGUI\")) {
        Write-Progress -Activity $ProgressTitle -Status "Creating directory";
        New-Item -Path "C:\" -Name "PowerExpressGUI" -ItemType "directory";
    }
    $AutorunUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/content/driver-update.ps1";
    $AutorunFile = "C:\PowerExpressGUI\autorun.ps1";
    Invoke-RestMethod -Uri $AutorunUrl -OutFile $AutorunFile;

    Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Completed!";
}
else {
    Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Error: Failed to register task.";
    Start-Process "powershell" -Verb RunAs -Wait -ArgumentList "-Command 'echo Looks like PowerExpressGUI ran into an error. You can use this terminal to see what went wrong, or close and continue your installation like normal.'";
}

Start-Sleep -Seconds 1;
