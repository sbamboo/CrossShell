<#
  .SYNOPSIS
  Powershell command passthru.
#>
param([alias("c")][string]$command,[alias("l")][switch]$legacy)

<#Devmode head #> $devmode = verify_Devmode; if ($devmode -ne $true) { write-host "This is a development command! Run crosshell in devmode to use this command." -f red; exit }

if ($command) {
    if ($legacy) {
        powershell -command $command
    } else {
        pwsh -command $command
    }
} else {
    write-host "Error: No command given, the 'pwsh' command is only a command passthru and wont run the shell." -f red
}