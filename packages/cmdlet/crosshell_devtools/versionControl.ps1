<#
  .SYNOPSIS
  version-control-devtool
#>
param([switch]$generateLastver)

<#Devmode head #> $devmode = verify_Devmode; if ($devmode -ne $true) { write-host "This is a development command! Run crosshell in devmode to use this command." -f red; exit }

# Generate LastVer tag
if ($generateLastver) {
    $date = get-date -format d
    $date += "_"
    $date += (get-date).ToShortTimeString()
    $date | out-file "$script:basedir\lastver.mt"
}