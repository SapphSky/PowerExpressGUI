Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

function ConnectToWifi {
  Write-Host 'Connecting to 2ARTech network...';
  netsh wlan connect ssid=$NetworkSSID name='Test' key=$NetworkPassword
}

function ResetNetwork {
  ipconfig /release
  ipconfig /flushdns
  ipconfig /renew
  netsh int ip reset
  netsh winsock reset
  Write-Host 'Network stack reset.';
}

function InstallPSWindowsUpdate {
  function Perform {
    Write-Host 'Checking for driver updates...';
    Install-WindowsUpdate -AcceptAll -UpdateType Driver -Verbose;
    Write-Host 'Driver updates completed.';
  }

  if (Get-Module -Name 'PSWindowsUpdate' -ListAvailable) {
    Perform;
  }
  else {
    Write-Host 'Installing the PSWindowsUpdate module...';
    Get-PackageProvider -Name Nuget | Install-PackageProvider -Force;
    Install-Module -Name 'PSWindowsUpdate' -Force;
    Start-Sleep -Seconds 1;

    if (Get-Module -Name 'PSWindowsUpdate' -ListAvailable) {
      Perform;
    }
    else {
      Write-Host 'Unable to find PSWindowsUpdate module. Aborting.';
    }
  }
}

function GetComputerInfo {
  Write-Host 'Getting Computer Info...';
  Get-ComputerInfo | Out-File -FilePath 'C:\computer-info.txt';
  Start-Sleep -Seconds 1;

  if (Test-Path -Path 'C:\computer-info.txt') {
    Write-Host 'Computer information created at C:\computer-info.txt';
  }
  else {
    Write-Host 'Error: Computer information failed to generate.';
  }
}

function GenerateBatteryReport {
  Write-Host 'Generating battery report...';
  powercfg /batteryreport /output 'C:\battery-report.html' | Out-Null;
  Start-Sleep -Seconds 1;

  if (Test-Path -Path 'C:\battery-report.html') {
    Write-Host 'Battery report created at C:\battery-report.html';
  }
  else {
    Write-Host 'Error: Battery report failed to generate.';
  }
}

function GetEnrollmentStatus {
  Write-Host 'Checking enrollment status...';
  dsregcmd /status | Out-File -FilePath 'C:\enrollment-status.txt';
  Start-Sleep -Seconds 1;

  if (Test-Path -Path 'C:\enrollment-status.txt') {
    Write-Host 'Enrollment report created at C:\enrollment-status.txt';
  }
  else {
    Write-Host 'Error: Enrollment report failed to generate.';
  }
}

function GetActivationStatus {
  Invoke-RestMethod https://get.activated.win | Invoke-Expression
}

Start-Job -ScriptBlock { GetComputerInfo }
Start-Job -ScriptBlock { GenerateBatteryReport }
Start-Job -ScriptBlock { GetEnrollmentStatus } 
Get-Job | Wait-Job

[xml]$XAML = @'
<Window x:Class="MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:local="clr-namespace:WpfApp2"
        Title="PowerExpressGUI"
        Width="800"
        Height="450"
        WindowStartupLocation="CenterScreen"
        WindowState="Maximized"
        ResizeMode="NoResize">
    <Grid>
        <Label Content="PowerExpressGUI"
               HorizontalAlignment="Center"
               Margin="0,0,0,0"
               VerticalAlignment="Top"
               FontSize="32"
               FontWeight="Bold">
            <Label.Foreground>
                <LinearGradientBrush EndPoint="0.5,1"
                                     StartPoint="0.5,0">
                    <GradientStop Color="#FFC4C4FF"/>
                    <GradientStop Color="#FFFFC4C4"
                                  Offset="1"/>
                </LinearGradientBrush>
            </Label.Foreground>
        </Label>
        <Button x:Name="ReloadButton" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0, 0, 10, 10" Content="Reload" />
        <Label Content="Version 1.0.0 | Made with PowerShell"
               VerticalAlignment="Bottom"
               FontSize="10"
               HorizontalAlignment="Left"/>
        <TabControl BorderBrush="#00ACACAC"
                    Background="Transparent"
                    Margin="10,10,10,30">
            <TabItem Header="Home">
                <Grid>
                  <Button x:Name="InstallDriverUpdateButton" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10, 10, 0, 0" Content="Install Driver Updates" />
                  <Button x:Name="GetActivationStatusButton" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10, 35, 0, 0" Content="Check Activation Status" />
                </Grid>
            </TabItem>
            <TabItem Header="Computer Info">
                <Grid>
                  <WebBrowser x:Name="ComputerInfoViewport"
                              Source="C:\computer-info.txt"/>
                </Grid>
            </TabItem>
            <TabItem Header="Battery Report">
                <Grid>
                  <WebBrowser x:Name="BatteryReportViewport"
                              Source="C:\battery-report.html"/>
                </Grid>
            </TabItem>
            <TabItem Header="Enrollment Report">
                <Grid>
                  <WebBrowser x:Name="EnrollmentStatusViewport"
                              Source="C:\enrollment-status.txt"/>
                </Grid>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
'@ -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' -replace 'x:Class="\S+"', ''

$XAMLReader = New-Object System.Xml.XmlNodeReader $XAML
$MainWindow = [Windows.Markup.XamlReader]::Load($XAMLReader)

$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $MainWindow.FindName($_.Name) }

$InstallDriverUpdateButton.Add_Click({
    Start-Process powershell -Wait -Verb RunAs -ArgumentList "-NoLogo -NoExit -Command $InstallPSWindowsUpdate";
  })
$GetActivationStatusButton.Add_Click({ GetActivationStatus })
$ReloadButton.Add_Click({
    Start-Job -ScriptBlock { Start-Process powershell -Wait -Verb RunAs -ArgumentList '-NoLogo -NoExit -Command "irm https://github.com/SapphSky/PowerExpressGUI/raw/main/main.ps1 | iex"' };
    Get-Job | Wait-Job;
    $MainWindow.Close();
  })

$MainWindow.ShowDialog() | Out-Null
