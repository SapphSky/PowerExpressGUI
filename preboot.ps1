$DebugMode = $false;
$ProgressTitle = "PowerExpressGUI Bootstrapper";

if (-Not (Test-Path "C:\PowerExpressGUI\")) {
    Write-Progress -Activity $ProgressTitle -Status "Creating directory";
    New-Item -Path "C:\" -Name "PowerExpressGUI" -ItemType "directory";
}

# Download the autorun script
$AutorunUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/content/driver-update.ps1";
$AutorunFile = "C:\PowerExpressGUI\autorun.ps1";
Invoke-RestMethod -Uri $AutorunUrl -OutFile $AutorunFile;
Write-Progress -Activity $ProgressTitle -Status "Registering Scheduled Task";

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction -Execute "powershell" -Argument "-Verb RunAs -NoExit -File $AutorunFile";
$Trigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay (New-TimeSpan -Seconds 10);
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries $true `
    -DeleteExpiredTaskAfter (New-TimeSpan -Days 1) `
    -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
    -Priority 4 `
    -RestartCount 3 `
    -RestartInverval (New-TimeSpan -Minutes 5);

$Principal = New-ScheduledTaskPrincipal -GroupId "Administrators" -RunLevel Highest;

$TaskName = "PowerExpressGUI";
$Description = "Runs a PowerShell script that automatically downloads and installs all driver updates through PSWindowsUpdate on startup. `
This task will automatically remove itself after 1 day.";

Register-ScheduledTask -TaskName $TaskName -Description $Description `
    -Action $Action `
    -Principal $Principal `
    -Settings $Settings `
    -Trigger $Trigger `
    -Force | Out-Host;

if (Get-ScheduledTask -TaskName $TaskName) {
    Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Completed.";
}
else {
    Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Error: Failed to register task.";
    $DebugMode = $true;
}

Start-Sleep -Seconds 1;

if ($DebugMode -eq $true) {
    Start-Process "powershell" -Verb RunAs -Wait -NoExit;
}
