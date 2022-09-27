<#
  .SYNOPSIS
  Powershell command passthru.
#>
param([alias("c")][string]$command,[alias("l")][switch]$legacy)

if ($command) {
    if ($legacy) {
        powershell -command $command
    } else {
        pwsh -command $command
    }
} else {
    write-host "Error: No command given, the 'pwsh' command is only a command passthru and wont run the shell." -f red
}