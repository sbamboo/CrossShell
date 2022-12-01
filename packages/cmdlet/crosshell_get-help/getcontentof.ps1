<#
  .SYNOPSIS
  Prints out the contents of a cmdlet file.
#>
param([string]$name)
foreach ($cmdlet in $script:pathables) {
  [string]$namei = ($cmdlet -split "§")[0]
  $namei = $namei.trim(" ")
  if ("$namei" -eq "$name") {
    $w = ($cmdlet -split "§")[1]
    get-content $w.trim(" ")
  }
}