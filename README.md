# PowerExpressGUI

A PowerShell script used to quickly deploy and assess a device after Windows installation

## Features

- User interface
- No ISO modifications required

## Usage

Attach one of the `autounattend.xml` files to the root of your Windows install USB.

If you are using [Ventoy](https://github.com/Ventoy/Ventoy), make sure to assign it in the Auto Install section of the VentoyPlugon for Windows.

`irm https://github.com/SapphSky/PowerExpressGUI/raw/main/main.ps1 | iex`
Once the installation has finished and rebooted, you will be connected to the Wi-Fi network automatically, and will begin to run the powershell script from this repo.
