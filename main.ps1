Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

function Cleanup {
  # Cleanup functions. These should be ran once the use is finished with PEGUI.

  function ResetNetwork {
    ipconfig /release
    ipconfig /flushdns
    ipconfig /renew
    netsh int ip reset
    netsh winsock reset
    Write-Host 'Network stack reset.'
  }
}

function WriteComputerInfo {
  $FilePath = "C:\computer-info.txt"
  Write-Progress -Activity "Computer Info" -Status "Writing to $FilePath"
  Get-ComputerInfo | Out-File -FilePath $FilePath

  if (Test-Path -Path $FilePath) {
    Write-Host "Computer info created at $FilePath"
  }
  else {
    Write-Host "Error: Computer info failed to generate."
  }
}

function WriteBatteryReport {
  $FilePath = "C:\battery-report.html"
  Write-Progress -Activity "Battery Report" -Status "Writing to $FilePath"
  powercfg /batteryreport /output $FilePath | Out-Null

  if (Test-Path -Path $FilePath) {
    Write-Host "Battery report created at $FilePath"
  }
  else {
    Write-Host "Error: Battery report failed to generate."
  }
}

function WriteEnrollmentStatus {
  $FilePath = "C:\enrollment-status.txt"

  Write-Progress -Activity "Enrollment Status" -Status "Writing to $FilePath"
  dsregcmd /status | Out-File -FilePath $FilePath
  Start-Sleep -Seconds 1

  if (Test-Path $EnrollmentStatusFilePath) {
    Write-Host "Enrollment status created at $FilePath"
  }
  else {
    Write-Host "Error: Enrollment status failed to generate."
  }
}

function GetActivationStatus {
  Invoke-RestMethod https://get.activated.win | Invoke-Expression
}

function AutoInstallDrivers {
  Invoke-RestMethod https://github.com/SapphSky/PowerExpressGUI/raw/main/content/driver-update.ps1 | Invoke-Expression
}

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
                  <Button x:Name="OpenRetestButton" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10, 60, 0, 0" Content="Open Retest" />
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

WriteComputerInfo
WriteBatteryReport
WriteEnrollmentStatus

$XAMLReader = New-Object System.Xml.XmlNodeReader $XAML
$MainWindow = [Windows.Markup.XamlReader]::Load($XAMLReader)
$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $MainWindow.FindName($_.Name) }

$InstallDriverUpdateButton.Add_Click({ AutoInstallDrivers })
$GetActivationStatusButton.Add_Click({ GetActivationStatus })
$OpenRetestButton.Add_Click({ start msedge --no-first-run http://retest.us/laptop-no-keypad })

$MainWindow.ShowDialog() | Out-Null
