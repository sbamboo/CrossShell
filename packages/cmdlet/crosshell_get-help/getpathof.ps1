<#
  .SYNOPSIS
  Gets the internal path of a command.
#>
param([string]$name)
foreach ($cmdlet in $script:pathables) {
  [string]$namei = ($cmdlet -split "§")[0]
  $namei = $namei.trim(" ")
  if ("$namei" -eq "$name") {
    write-host "Internal path of command '$name' is: " -NoNewline
    write-host ($cmdlet -split "§")[1] -f DarkYellow
  }
}