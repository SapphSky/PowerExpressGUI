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
        -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -Argument "$AutorunFile";

    $Trigger = New-ScheduledTaskTrigger `
        -AtStartup;

    $Principal = New-ScheduledTaskPrincipal `
        -UserId "NT AUTHORITY\SYSTEM" `
        -LogonType ServiceAccount;
    
    Register-ScheduledTask `
        -TaskName "PowerExpressGUI" `
        -Description "From SapphSky/PowerExpressGUI" `
        -Action $Action `
        -Trigger $Trigger `
        -Principal $Principal;
}

Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Completed";
Start-Sleep -Seconds 1;
$Task = Get-ScheduledTask -TaskName "PowerExpressGUI";
$TaskInfo = Get-ScheduledTaskInfo -InputObject $Task;
$TaskInfo;
Start-Process "powershell" -Verb RunAs -Wait;
