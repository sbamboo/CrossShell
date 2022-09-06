<#
  .SYNOPSIS
  Tool for enabling or disabling debug options in the shell.
#>
param([string]$enable,[string]$disable)

if ($enable) {
  if ($enable -eq "commandparts") {$script:debug_commandparts = $true}
}

if ($disable) {
  if ($disable -eq "commandparts") {$script:debug_commandparts = $false}
}