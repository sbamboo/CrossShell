<#
  .SYNOPSIS
  Script for managing Windows Images.
#>
param(
  [switch]$winPE,

  [switch]$install,
  [switch]$createImage,
  [switch]$mount,
  [switch]$unmount,
  [switch]$bootBIOS,

  [string]$imagefile,
  [string]$mountdir
)

#WinPE
if ($winPE) {
    #Install
    if ($install) {
        $bd = "$PSScriptRoot"
        iwr -uri "https://go.microsoft.com/fwlink/?linkid=2196127" -outfile "$bd\winisoman_adksetup.exe"
        iwr -uri "https://go.microsoft.com/fwlink/?linkid=2196224" -outfile "$bd\winisoman_adkwinpesetup.exe"
        $adksetup_exi = test-path "$bd\winisoman_adksetup.exe"
        $adkwinpesetup_exi = test-path "$bd\winisoman_adkwinpesetup.exe"
        if ($adksetup_exi -ne $true -or $adkwinpesetup_exi -ne $true) {
            echo "Installation failed! Could not download installers."; exit
        }
        echo "Starting main Windows ADK installer... Run through the installation and return afterwards"
        start "$bd\winisoman_adksetup.exe"
        pause
        echo "Starting ADK-addition installer for WinPE... Run through the installation and return afterwards"
        start "$bd\winisoman_adkwinpesetup.exe"
        pause
        remove-item "$bd\winisoman_adksetup.exe"
        remove-item "$bd\winisoman_adkwinpesetup.exe"
        exit
    }

    #CreateImage
    if ($createImage) {
        echo "Starting enviroment... Follow guide on: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-usb-bootable-drive?view=windows-11"
        if (test-path "$psscriptroot\envirStart_admin.lnk") {
            start "$psscriptroot\envirStart_admin.lnk"
        } else {
            echo "Failed to start enviroment! Please manualy start 'Deployment and Imaging Tools Environment' as admin."
        }
        exit
    }

    #Mount
    if ($mount) {
        if (test-path "$imagefile") {
            echo "Mounting..."
            $command = 'Dism /Mount-Image /ImageFile:"' + "$imagefile" + '" /index:1 /MountDir:"' + "$mountdir" + '"'
            cmd.exe /c $command
        } else {
            echo "No mount file found in '$imagefile', point to a boot.wim file."
        }
        if (test-path "$mountdir") {
            echo "Mount folder found..."
        } else {
            echo "Mount folder not found please try again and verify imagefile and mountdir"
        }
        exit
    }
    #UnMount
    if ($unmount) {
        if (test-path "$mountdir") {
            echo "Mount folder found, Unmounting..."
            $command = 'Dism /Unmount-Image /MountDir:"' + "$mountdir" + '" /commit'
            cmd.exe /c $command
            $cl = get-location
            set-location $mountdir
            cmd.ex /c "dism /cleanup-wim"
            Set-Location $cl
        } else {
            echo "Mount folder not found please try again and verify mountdir"
        }
        exit
    }
    #BootBios
    if ($bootBIOS) {
        cmd.exe /c "shutdown /r /fw /f /t 0"
    }
}