Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$NetworkSSID = '2ARTech'
$NetworkPassword = 'qwertyui'

$Title = 'PowerExpressGUI'
$Author = 'Joel Fargas (github.com/sapphsky)'
$CurrentVersion = '1.0.0'

[xml]$XAML = Get-Content "MainWindow.xaml"
$XAML.Window.RemoveAttribute('x:Class')
$XAML.Window.RemoveAttribute('mc:Ignorable')
$XAMLReader = New-Object System.Xml.XmlNodeReader $XAML
$MainWindow = [Windows.Markup.XamlReader]::Load($XAMLReader)

$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $MainWindow.FindName($_.Name) }

function RunInPwsh($Command) {
  Start-Process powershell -Wait -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -NoExit -NonInteractive -NoLogo -Command $Command"
}

# Connect to network
function ConnectToWifi {
  Write-Host 'Connecting to 2ARTech network...';
  netsh wlan connect ssid=$NetworkSSID name='Test' key=$NetworkPassword
  exit;
}

# Clear network settings
function ResetNetwork {
  ipconfig /release
  ipconfig /flushdns
  ipconfig /renew
  netsh int ip reset
  netsh winsock reset
  Write-Host 'Network stack reset.';
  exit;
}

# Install PSWindowsUpdate module and check for driver updates
function InstallPSWindowsUpdate {
  $AttemptedInstall = $false

  while ($AttemptedInstall -eq $false) {
    if (Get-Module -Name 'PSWindowsUpdate' -ListAvailable) {
      Write-Host 'Checking for driver updates...';
      Install-WindowsUpdate -AcceptAll -UpdateType Driver -Verbose;
      Write-Host 'Driver updates completed.';
      exit;
    }
    else {
      Write-Host 'Installing the PSWindowsUpdate module...';
      Install-Module -Name 'PSWindowsUpdate' -Force;
      $AttemptedInstall = $true;
    }
  }

  Write-Host 'Failed to install PSWindowsUpdate. Aborting.';
  exit;
}

# Generate battery report
function GenerateBatteryReport {
  Write-Host 'Generating battery report...';
  powercfg /batteryreport /output 'C:\battery_report.html';

  if (Test-Path -Path 'C:\battery_report.html') {
    Write-Host 'Battery report created at C:\battery_report.html';
    Start-Process 'C:\battery_report.html';
    exit;
  }
  else {
    Write-Host 'Error: Battery report failed to generate.';
    exit;
  }
}

# Check if the device is enrolled in MDM
function GetEnrollmentStatus {
  Write-Host 'Checking enrollment status...';
  dsregcmd /status | Out-File -FilePath 'C:\enrollment_status.txt';
  $EnrollmentStatus = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty PartOfDomain;
  "PartOfDomain: $EnrollmentStatus" | Out-File -Append -FilePath 'C:\enrollment_status.txt'; 
  Write-Host 'Enrollment status saved to C:\enrollment_status.txt';
  exit;
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

$MainWindow.ShowDialog() | Out-Null
