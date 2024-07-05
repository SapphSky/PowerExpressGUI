$Url = "https://github.com/SapphSky/PowerExpressGUI/raw/main/driver-update.ps1";
$FilePath = "C:\PowerExpressGUI\autorun.ps1";

# Download the script
Invoke-RestMethod $Url -OutFile $FilePath;

if (Test-Path -Path $FilePath) {
    Write-Host "Download completed.";
}
else {
    Write-Host "Error: $FilePath not found.";
}
Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Registering Scheduled Task";

# Creates a Scheduled Task to run our script at startup
# $Action = New-ScheduledTaskAction -Execute $FilePath;
# $Trigger = New-ScheduledTaskTrigger -AtLogon;
# $Settings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter (New-TimeSpan -Days 1);
# Register-ScheduledTask -TaskName "PowerExpressGUI" -Description "From SapphSky/PowerExpressGUI" -Action $Action -Trigger $Trigger -Settings $Settings -RunLevel Highest;
schtasks /create /sc ONLOGON /tn "powerexpressgui\Install Drivers" /tr "powershell.exe -NoLogo -NoExit -File $FilePath" /ru System /mo ONLOGON /z /rl HIGHEST /delay 0000:10;

Write-Progress -Activity "PowerExpressGUI Bootstrapper" -Status "Completed";
Start-Sleep -Seconds 1;

[xml]$Task = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2024-07-05T08:01:34.0942607</Date>
    <Author>BUILTIN\Administrators</Author>
    <Description>SapphSky/PowerExpressGUI</Description>
    <URI>\PowerExpressGUI</URI>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
      <Enabled>true</Enabled>
      <Delay>PT10S</Delay>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-21-1181867840-1005673334-3825115896-1000</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
    <RestartOnFailure>
      <Interval>PT5M</Interval>
      <Count>3</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>"powershell.exe"</Command>
      <Argument>"-File C:\PowerExpressGUI\autorun.ps1"</Argument>
    </Exec>
  </Actions>
</Task>
'@
