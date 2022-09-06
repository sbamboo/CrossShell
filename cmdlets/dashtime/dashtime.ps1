<#
  .SYNOPSIS
  Shows time and date.
#>
param([switch]$d,[switch]$t,[switch]$p)
$dashtimeDate = Get-Date
if ($d) {
  Write-Host "$dashtimeDate"
} else {
  $dashtimeDate = $dashtimeDate.ToShortTimeString()
  Write-Host $dashtimeDate
}
if ($t) {Start-Sleep -s 2}
if ($p) {pause}