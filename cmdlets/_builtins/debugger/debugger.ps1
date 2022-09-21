<#
  .SYNOPSIS
  Tool for enabling or disabling debug options in the shell.
#>
param([string]$enable,[string]$disable)

if ($enable) {
  if ($enable -eq "commandparts") {$script:debug_commandparts = $true}
  if ($enable -eq "commandparts_final") {$script:debug_commandparts_final = $true}
  if ($enable -eq "versioncheck") {$script:debug_versioncheck = $true}
}

if ($disable) {
  if ($disable -eq "commandparts") {$script:debug_commandparts = $false}
  if ($disable -eq "commandparts_final") {$script:debug_commandparts_final = $false}
  if ($disable -eq "versioncheck") {$script:debug_versioncheck = $false}
}

