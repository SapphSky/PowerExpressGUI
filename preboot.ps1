if (-Not (Test-Path "C:\PowerExpressGUI\")) {
    Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Creating directory";
    New-Item -Path "C:\" -Name "PowerExpressGUI" -ItemType "directory";
}

# Download the autorun script
$AutorunUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/content/driver-update.ps1";
$AutorunFile = "C:\PowerExpressGUI\autorun.ps1";
Invoke-RestMethod -Uri $AutorunUrl -OutFile $AutorunFile;

# $TaskUrl = "https://github.com/SapphSky/PowerExpressGUI/raw/main/content/task.xml";
# $TaskFile = "C:\PowerExpressGUI\task.xml";
# Invoke-RestMethod -Uri $TaskUrl -OutFile $TaskFile;

Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Registering Scheduled Task";

# Creates a Scheduled Task to run our script at startup
$Action = New-ScheduledTaskAction -Execute "powershell" -Argument "-Verb RunAs -File $AutorunFile";
$Trigger = New-ScheduledTaskTrigger -AtLogon;
$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest;

Register-ScheduledTask -TaskName "PowerExpressGUI" -Description "From SapphSky/PowerExpressGUI" -Action $Action -Trigger $Trigger -Principal $Principal;
# Register-ScheduledTask -TaskName "PowerExpressGUI" -Description "From SapphSky/PowerExpressGUI" -Xml (Get-Content $TaskFile);

Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Completed";
Start-Sleep -Seconds 1;
Start-Process "powershell" -Verb RunAs -Wait;
