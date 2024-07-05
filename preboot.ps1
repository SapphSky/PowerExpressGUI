if (-Not (Test-Path "C:\PowerExpressGUI\")) {
    New-Item -Path "C:\" -Name "PowerExpressGUI" -ItemType "directory";
}

# Download the autorun script
$AutorunUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/driver-update.ps1";
$AutorunFile = "C:\PowerExpressGUI\autorun.ps1";
Invoke-RestMethod -Uri $AutorunUrl -OutFile $AutorunFile;

if ((Test-Path $TaskXmlFile) -and (Test-Path $AutorunFile)) {
    Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Registering Scheduled Task";

    # Creates a Scheduled Task to run our script at startup
    $Action = New-ScheduledTaskAction `
        -Execute "powershell" `
        -Argument "-File $AutorunFile";

    $Trigger = New-ScheduledTaskTrigger `
        -AtLogon;

    $Settings = New-ScheduledTaskSettingsSet `
        -DeleteExpiredTaskAfter (New-TimeSpan -Days 1);
    
    Register-ScheduledTask `
        -TaskName "PowerExpressGUI" `
        -Description "From SapphSky/PowerExpressGUI" `
        -Action $Action `
        -Trigger $Trigger `
        -Settings $Settings `
        -RunLevel Highest;
}

Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Completed";
Start-Process "taskschd" -Verb RunAs -Wait;
Start-Sleep -Seconds 1;
