Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$NetworkSSID = '2ARTech'
$NetworkPassword = 'qwertyui'

$Title = 'PowerExpressGUI'
$Author = 'Joel Fargas (github.com/sapphsky)'
$CurrentVersion = '1.0.0'

[xml]$XAML = @'
<Window x:Class="MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:local="clr-namespace:WpfApp2"
        Title="PowerExpressGUI"
        Height="450"
        Width="800"
        Topmost="True"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        WindowState="Maximized"
        ResizeMode="NoResize">
    <Grid>
        <Label Content="PowerExpressGUI"
               HorizontalAlignment="Center"
               Margin="0,10,0,0"
               VerticalAlignment="Top"
               FontSize="36"
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
        <CheckBox Content="Automatically perform all steps"
                  HorizontalAlignment="Right"
                  Margin="0,0,10,10"
                  VerticalAlignment="Bottom"
                  IsChecked="False"/>
        <Label Content="Version 1.0.0 | Made with PowerShell"
               VerticalAlignment="Bottom"
               FontSize="10"
               HorizontalAlignment="Left"/>
        <TabControl BorderBrush="#00ACACAC"
                    Background="Transparent"
                    Margin="10,10,10,30">
            <TabItem Header="Home">
                <Grid>
                  <Button x:Name="InstallDriverUpdateButton" Margin="10, 20, 10, 0" Height="20" Content="Install Driver Updates" />
                  <Button x:Name="GenerateBatteryReportButton" Margin="10, 40, 10, 0" Height="20" Content="Generate Battery Report" />
                  <Button x:Name="GenerateEnrollmentReportButton" Margin="10, 60, 10, 0" Height="20" Content="Generate Enrollment Report" />
                  <Button x:Name="GetActivationStatusButton" Margin="10, 80, 10, 0" Height="20" Content="Check Activation Status" />
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
'@
$XAML.Window.RemoveAttribute('x:Class')
$XAML.Window.RemoveAttribute('mc:Ignorable')
$XAMLReader = New-Object System.Xml.XmlNodeReader $XAML
$MainWindow = [Windows.Markup.XamlReader]::Load($XAMLReader)

$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $MainWindow.FindName($_.Name) }

# XAML objects
$DriverUpdateButton = $MainWindow.Window.FindName("InstallDriverUpdateButton")
$DriverUpdateButton.Add_Click({ InstallPSWindowsUpdate })

$BatteryReportButton = $MainWindow.Window.FindName("GenerateBatteryReportButton")
$BatteryReportButton.Add_Click({ GenerateBatteryReport })

$EnrollmentReportButton = $MainWindow.Window.FindName("GenerateEnrollmentReportButton")
$EnrollmentReportButton.Add_Click({ GetEnrollmentStatus })

$ActivationStatusButton = $MainWindow.Window.FindName("CheckActivationStatusButton")
$ActivationStatusButton.Add_Click({ GetActivationStatus })

function RunInPwsh($Command) {
  Start-Process powershell -Wait -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -NoExit -NonInteractive -NoLogo -Command $Command"
}

# Connect to network
function ConnectToWifi {
  Write-Host 'Connecting to 2ARTech network...';
  netsh wlan connect ssid=$NetworkSSID name='Test' key=$NetworkPassword
  # exit;
}

# Clear network settings
function ResetNetwork {
  ipconfig /release
  ipconfig /flushdns
  ipconfig /renew
  netsh int ip reset
  netsh winsock reset
  Write-Host 'Network stack reset.';
  # exit;
}

# Install PSWindowsUpdate module and check for driver updates
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
    Install-Module -Name 'PSWindowsUpdate' -Force;
    Start-Sleep -Seconds 2;

    if (Get-Module -Name 'PSWindowsUpdate' -ListAvailable) {
      Perform;
    }
    else {
      Write-Host 'Unable to find PSWindowsUpdate module. Aborting.';
    }
  }
}

# Generate battery report
function GenerateBatteryReport {
  Write-Host 'Generating battery report...';
  powercfg /batteryreport /output 'C:\battery-report.html';

  if (Test-Path -Path 'C:\battery-report.html') {
    Write-Host 'Battery report created at C:\battery-report.html';
    # exit;
  }
  else {
    Write-Host 'Error: Battery report failed to generate.';
    # exit;
  }
}

# Check if the device is enrolled in MDM
function GetEnrollmentStatus {
  Write-Host 'Checking enrollment status...';
  dsregcmd /status | Out-File -FilePath 'C:\enrollment-status.txt';

  # $EnrollmentStatus = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty PartOfDomain;
  # "PartOfDomain: $EnrollmentStatus" | Out-File -Append -FilePath 'C:\enrollment-status.txt'; 

  if (Test-Path -Path 'C:\enrollment-status.txt') {
    Write-Host 'Battery report created at C:\enrollment-status.txt';
    # exit;
  }
  else {
    Write-Host 'Error: Battery report failed to generate.';
    # exit;
  }
}

function GetActivationStatus {
  irm https://get.activated.win | iex
}

# Restart and boot to firmware settings
function BootToFirmware {
  $Title = 'Boot to Firmware Settings'
  $Prompt = 'Are you sure you want to restart and boot to firmware settings?
    ExpressGUI might not show up on the next boot. Make sure you have done everything you need to do before proceeding.'
  $Choices = '&Yes', '&No'

  $Decision = $Host.UI.PromptForChoice($Title, $Prompt, $Choices, 1)
  if ($Decision -eq 0) {
    shutdown /r /fw /t 5
  }
}

RunInPwsh(GenerateBatteryReport)
RunInPwsh(GetEnrollmentStatus)

$MainWindow.ShowDialog() | Out-Null
