if (-Not (Test-Path "C:\PowerExpressGUI\")) {
    Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Creating directory";
    New-Item -Path "C:\" -Name "PowerExpressGUI" -ItemType "directory";
}

# Download the autorun script
$AutorunUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/content/driver-update.ps1";
$AutorunFile = "C:\PowerExpressGUI\autorun.ps1";
Invoke-RestMethod -Uri $AutorunUrl -OutFile $AutorunFile;

# Download the scheduled task
# $TaskUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/content/task.xml";
# $TaskFile = "C:\PowerExpressGUI\task.xml";
# Invoke-RestMethod -Uri $TaskUrl -OutFile $TaskFile;

Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Registering Scheduled Task";

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction -Execute "powershell" -Argument "-Verb RunAs -File $AutorunFile";
$Trigger = New-ScheduledTaskTrigger -AtStartup;
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries $true `
    -DeleteExpiredTaskAfter (New-TimeSpan -Days 1) `
    -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
    -Priority 4 `
    -RestartCount 3 `
    -RestartInverval (New-TimeSpan -Minutes 5) `
    -StartWhenAvailable $true;

$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest;

Register-ScheduledTask -TaskName "PowerExpressGUI" -Description "From SapphSky/PowerExpressGUI" `
    -Action $Action -Principal $Principal -Settings $Settings -Trigger $Trigger;
# Register-ScheduledTask -TaskName "PowerExpressGUI" -Description "From SapphSky/PowerExpressGUI" -Xml (Get-Content $TaskFile) | Out-String;

Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Completed";
Start-Sleep -Seconds 1;
# Start-Process "powershell" -Verb RunAs -Wait;
