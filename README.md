> ### Project at risk of failure
>
> This project is still in development. Unfortunately because Windows Task Scheduler does not work as intended in the current ISO versions of Windows 10 22H2 and Windows 11 23H2, I am unable to find a workaround to launching post-install. If you have a solution or would like to contribute, it would be greatly appreciated. More information regarding the problem will be described below.

# PowerExpressGUI

A PowerShell script created to help quickly diagnose and set up a Windows computer with driver updates and diagnostics ready to view after installation.

## Features

No ISO modifications required. Just create an `autounattend.xml` with
You can generate one using [this site](https://schneegans.de/windows/unattend-generator/) (schneegans.de) or use this [preset I made](https://schneegans.de/windows/unattend-generator/view/?LanguageMode=Interactive&ProcessorArchitecture=x86&ProcessorArchitecture=amd64&BypassRequirementsCheck=true&BypassNetworkCheck=true&ComputerNameMode=Random&TimeZoneMode=Implicit&PartitionMode=Interactive&WindowsEditionMode=Unattended&WindowsEdition=pro&UserAccountMode=Interactive&PasswordExpirationMode=Unlimited&LockoutMode=Default&WifiMode=Unattended&WifiName=2ARTech&WifiNonBroadcast=true&WifiAuthentication=WPA2PSK&WifiPassword=qwertyui&ExpressSettings=Interactive&SystemScript0=Invoke-RequestMethod+https%3A%2F%2Fgithub.com%2FSapphSky%2FPowerExpressGUI%2Fraw%2Fmain%2Fpreboot.ps1+%7C+Invoke-Expression&SystemScriptType0=Ps1&WdacMode=Skip) (Recommended)

**Be sure to configure the Wi-Fi settings in the XML file so that the script has access to the internet when running after installation.**

## Usage

Attach one of the `autounattend.xml` files to the root of your Windows install USB.

If you are using [Ventoy](https://github.com/Ventoy/Ventoy), make sure to assign it in the Auto Install section of the VentoyPlugon for Windows.

`irm https://github.com/SapphSky/PowerExpressGUI/raw/main/main.ps1 | iex`
Once the installation has finished and rebooted, you will be connected to the Wi-Fi network automatically, and will begin to run the powershell script from this repo.

<details>
<summary>
Issues
</summary>

- Creating the Scheduled Task works, however, the task will not for whatever reason trigger in its designated condition. See [preboot.ps1](https://github.com/SapphSky/PowerExpressGUI/blob/main/preboot.ps1)
</details>
