<#
  .SYNOPSIS
  Starts a webadress
#>
params([string]$adress)
if ("$adress" -notlike "https*") {$adress = "https://" + $adress}
if ($adress[-1] -ne "/") {$adress = $adress + "/"}
start $adress