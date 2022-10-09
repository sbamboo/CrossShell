<#
  .SYNOPSIS
  Developmentcommand to restart crosshell.
#>
param([switch]$nocls,[switch]$noheader)

<#Devmode head #> $devmode = verify_Devmode; if ($devmode -ne $true) { write-host "This is a development command! Run crosshell in devmode to use this command." -f red; exit }

$devmodekey = . "$psscriptroot\internal_devkey_validator.ps1" -decrypt "$script:shell_devmode"
write-host "$devmodekey"
pause
if ($noheader) {
    if ($nocls) {
      . "$script:basedir\shell.ps1" -sdir $script:current_directory -supressCls -noheader -devmodekey "$devmodekey"
    } else {
        . "$script:basedir\shell.ps1" -sdir $script:current_directory -noheader -devmodekey "$devmodekey"
    }
} else {
    if ($nocls) {
        . "$script:basedir\shell.ps1" -sdir $script:current_directory -supressCls  -devmodekey "$devmodekey"
    } else {
        . "$script:basedir\shell.ps1" -sdir $script:current_directory -devmodekey "$devmodekey"
    }
}