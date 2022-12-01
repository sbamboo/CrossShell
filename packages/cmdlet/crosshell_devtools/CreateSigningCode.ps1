<#
  .SYNOPSIS
  Developmentcommand to create a signing code to enable devmode in a different crosshell session.
#>

param([alias("c","clip")][switch]$clipboard,[alias("o")][switch]$output)

<#Devmode head #> $devmode = verify_Devmode; if ($devmode -ne $true) { write-host "This is a development command! Run crosshell in devmode to use this command." -f red; exit }

# Dectrypt and reencrypt devmode key.
$currentcode = convertto-securestring "$(. "$psscriptroot\internal_devkey_validator.ps1" -decrypt "$script:shell_devmode")_$(Get-Random)" -asplaintext -force | convertfrom-securestring
if ($clipboard) {
    Set-Clipboard -value "$currentcode"
    if ($output) {
      echo $currentcode
      $currentcode = $null
    }
} else {
  echo $currentcode
  $currentcode = $null
}
