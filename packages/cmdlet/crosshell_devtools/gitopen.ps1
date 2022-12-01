<#
  .SYNOPSIS
  Opens crosshell in github desktop if setup.
#>

<#Devmode head #> $devmode = verify_Devmode; if ($devmode -ne $true) { write-host "This is a development command! Run crosshell in devmode to use this command." -f red; exit }

github $script:basedir