$host.ui.rawui.windowtitle = "Crosshell Startscript: Working..."
cls
write-host "Starting crosshell core..." -f yellow
cd $psscriptroot
.\core\core.ps1