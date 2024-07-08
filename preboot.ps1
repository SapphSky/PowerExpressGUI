$ProgressTitle = "PowerExpressGUI Bootstrapper";
$SetupPath = "C:\PowerExpressGUI";
$AutorunUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/content/driver-update.ps1";
$AutorunFile = "$SetupPath\autorun.ps1";
$TaskName = "PowerExpressGUI";
$TimeFormat = "yyyy-MM-dd'T'HH:mm:ss"

Write-Progress -Activity $ProgressTitle -Status "Registering ScheduledTask";

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction `
    -Execute "powershell" `
    -Argument "-WindowStyle Maximized -ExecutionPolicy Bypass -File C:\PowerExpressGUI\autorun.ps1"

$Trigger = New-ScheduledTaskTrigger `
    -Once `
    -At ([DateTime]::Now.AddMinutes(1)) `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration (New-TimeSpan -Hours 1)

$Principal = New-ScheduledTaskPrincipal `
    -User "NT AUTHORITY\SYSTEM" `
    -RunLevel Highest

$Settings = New-ScheduledTaskSettingsSet `
    -Compatability Win8 `
    -MultipleInstances IgnoreNew `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName $TaskName `
    -Description "Runs a PowerShell script that automatically downloads and installs all driver updates through PSWindowsUpdate on startup. This task will automatically remove itself after 1 day." `
    -Action $Action `
    -Principal $Principal `
    -Settings $Settings `
    -Trigger $Trigger

$Task = Get-ScheduledTask -TaskName $TaskName

if ($Task) {
    $Task.Author = $TaskName;
    $Task.Triggers[0].StartBoundary = [DateTime]::Now.ToString($TimeFormat)
    $Task.Triggers[0].EndBoundary = [DateTime]::Now.AddDays(1).ToString($TimeFormat)
    $Task.Settings.AllowHardTerminate = $true
    $Task.Settings.DeleteExpiredTaskAfter = 'PT0S'
    $Task.Settings.ExecutionTimeLimit = 'PT1H'
    $Task.Settings.volatile = $false
    $Task | Set-ScheduledTask

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
