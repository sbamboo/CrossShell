<#
  .SYNOPSIS
  Tool for enabling or disabling debug options in the shell.
#>
param([string]$enable,[string]$disable,[switch]$list)


if ($enable) {
  if ($enable -eq "commandparts") {
    saveState "debug_commandparts" $true debug
  }
  if ($enable -eq "commandparts_final") {
    saveState "debug_commandparts_final" $true debug
  }
  if ($enable -eq "versioncheck") {
    saveState "debug_versioncheck" $true debug
  }
}

if ($disable) {
  if ($disable -eq "commandparts") {
    saveState "debug_commandparts" $false debug
  }
  if ($disable -eq "commandparts_final") {
    saveState "debug_commandparts_final" $false debug
  }
  if ($disable -eq "versioncheck") {
    saveState "debug_versioncheck" $false debug
  }
}

if ($list) {
    write-host "Debug states:" -f green
    write-host "-  commandparts" -f darkyellow
    write-host "-  commandparts_final" -f darkyellow
    write-host "-  versioncheck" -f darkyellow
}
