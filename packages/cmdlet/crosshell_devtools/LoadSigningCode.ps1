<#
  .SYNOPSIS
  Command to load a signing code from the CreateSigningCode cmdlet, to sign the session as devmode.
#>

param($signingCode)
$key = "$((("$(. "$psscriptroot\internal_devkey_validator.ps1" -decrypt "$signingCode")".split('_'))[0]))"
write-host "Trying to sign session... (Might not work)" -f DarkYellow
CheckAndRun-input "reload -full -devmodekey '$key' -nocls -nohead"
