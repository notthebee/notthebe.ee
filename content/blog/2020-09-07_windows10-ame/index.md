+++
title = "Windows 10 AME – Make Windows Suck Less!"
+++

{{ image(src="screenshot.png", alt="Windows 10 AME") }}

_Please refer to the official AME documentation for an up-to-date version_

[https://ameliorated.info/documentation.html](https://ameliorated.info/documentation.html)

## Downloading and verifying Windows 10 ISO

Download the Windows 10 ISO using [Fido](https://github.com/pbatard/Fido) (Windows-only) or [TechBench](https://tb.rg-adguard.net/public.php). Choose a version that is officially supported by AME Project for the most stable experience, or alternatively, try your luck with the latest version. Make sure to choose the correct UI language, **you can't change it after the installation**.

Calcualte the SHA1 sum of the ISO using [sha1sum](https://www.adaic.org/resources/add_content/standards/articles/SHA-1.html). 

**Updated 08.09.2020:** You can also use this PowerShell commmand to calculate the SHA1 sum on Windows without any third party tools (Thank you, @GezeikVan)

```
Get-FileHash -Algorithm SHA1 Windows_2004.iso
```

Use [AdGuard SHA1 catalog](https://sha1.rg-adguard.net/) to verify the ISO checksum against the MSDN image database.

{{ image(src="success.png", alt="ISO Verification") }}

## Downloading updates
Use [Windows 10 Update History](https://support.microsoft.com/en-us/help/4555932/windows-10-update-history) page to determinte the KBs of the newest Cumulative update and the SSU for your Windows version. Look up the KBs in the [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/Home.aspx) and download the update packages for your architecture.

{{ image(src="updates.png", alt="Windows 10 Update History") }}

## Creating a bootable media
Use [Rufus](https://rufus.ie) to create a bootable USB drive from the Windows 10 ISO. On Linux you can use **WoeUSB** instead. Copy the update packages and Rufus executable to the flash drive. Download a Debian-based Linux LiveUSB image, for example [Xubuntu](https://xubuntu.org) and copy it to the USB drive as well. You might also want to add drivers for your PC. 

You will also need the newest version of the Amelioration script from the [AME website](https://ameliorated.info/documentation.html)

## Installing Windows
**Disconnect from the Ethernet/Wi-Fi** and don't connect back until we run the Linux AME script. 

Install Windows as usual and make sure to answer "No" to every question about telemetry/data collection/geolocation/etc.

After the installation/setup process is complete, do the following things:

* Unpin all tiles from the Start menu
* Remove the search bar from the taskbar
* Remove task view icon from the taskbar

These settings might not be available after the "amelioration" process is finished.

## Installing updates
Open the PowerShell as Administrator and type the following commands:
```cmd
mkdir C:/SSU
mkdir C:/Cumulative
```
Go to the flash drive, open the folder with the update packages, Shift+Right click on the empty space in Explorer and click "Open PowerShell window here". 

Unpack the updates. You can tell the SSU apart from the Cumulative update by comparing the package sizes: the SSU file is much smaller than the one for the Cumulative update.

```cmd
expand -F:* name_of_the_ssu_package.msu C:\SSU
expand -F:* name_of_the_cumulative_package.msu C:\Cumulative
```

Install the SSU update first. Copy the filename of the CAB package from Explorer, since you won't be able to utilize auto-completion for the DISM command:

```cmd
dism /online /add-package /packagepath=C:\SSU\name_of_the_ssu.cab
```

Reboot after applying the SSU and install the Cumulative update:

```cmd
dism /online /add-package /packagepath=C:\Cumulative\name_of_the_cumulative.cab
```

**Reboot twice** after the Cumulative update has been installed.

Finally, launch the cleanup task to get rid of the update cache:

```cmd
dism /online /Cleanup-Image /StartComponentCleanup
```

## Running the amelioration script

Open the flash drive folder and run the AME script as Administrator. Choose `1. Run Pre-Amelioration` in the menu and wait for the process to finish

Afterwards, choose `3. User Permissions`. Reset the Administrator password and change your user privileges from "Administrator" to "Standard User".

Log out when asked to, use the Ctrl+Alt+Del menu to log out manually if necessary.

After logging back in, run PowerShell as Administrator and reset your password:

```cmd
net user username *
```

Enter the password twice. The symbols won't appear in the command line as you type.

## Creating a Linux bootable media
Copy the flash drive folder to your desktop and use [Rufus](https://rufus.ie) to wipe the Windows bootable flash drive and create a Linux USB drive. Reboot into BIOS, re-enable the Internet connection and then boot into Linux

## Running the Linux amelioration script
Mount the Windows drive. Then, navigate to [ameliorated.info](https://ameliorated.info/documentation.html) and copy the download link for the Linux AME script. 

Go to the Windows drive, open the terminal in the root folder. Type `sudo su` and then type `wget <paste the download link>`. This will give you root privileges and download the AME script to the root of the Windows drive.

As of writing this, running the script produces an error due to incompatible newline symbols:

```
bash: '\r': command not found
```

You can either use a sed script to convert the newline symbols to UNIX ones: 

```bash
sed -i 's/\r$//' filename
```

Alternatively, use `dos2unix`:

```bash
apt-get update && apt-get install dos2unix
dos2unix filename
```
Now you can run the script by typing `bash filename`.

After the script is finished with no errors, you can now reboot into Windows with the Internet connection enabled.

## Post-Amelioration
Since most of the default Windows applications, including Internet Explorer, Windows Media Player, Photos, etc. are eliminated, we need to install something to replace them.

Edit the AME script that we ran for pre-amelioration and go to the following line:

```bash
choco install -y --force --allow-empty-checksums firefox thunderbird vlc youtube-dl 7zip open-shell jpegview vcredist-all directx onlyoffice
```

Add the `-installArgs ADDLOCAL=StartMenu` after the `open-shell` text in order to opt out of "Classic Explorer" part of the OpenShell (doesn't work on the current version of Windows as of writing this).

By default, the following applications are installed:

* Firefox
* Thunderbird
* VLC
* JPEGView
* OpenShell (a Windows 7-style Start Menu replacement)
* OnlyOffice
* 7Zip
* youtube-dl
* Various Windows runtimes (.NET, C++) and DirectX

Feel free to replace or remove the applications in this list depending on your personal preferences.

After making the adjustments, run the script as Administrator and choose `2. Run Post-Amelioration`

## Hardening Windows settings
Download [Hardentools](https://securitywithoutborders.org/tools/hardentools.html) by Security Without Borders. Run the script as Administrator, reboot after the process is finished.

## Changing input language
You can remove/add a new input language using PowerShell.

```powershell
$List = Get-WinUserLanguageList
$List.add(<language-code>)
$List.remove(<language-code>)
Set-WinUserLanguageList $List
```

Replace `<language_code>` with your language code (e.g. "ru" for Russian or "de-DE" for German)

## Installing drivers
The drivers can be installed by downloading the driver package (sometimes called "SCCM") for your machine, unpacking it in a folder and executing this command in an elevated shell:

```cmd
pnputil.exe /add-driver C:\MyDrivers\*.inf /subdirs /install /reboot
```
