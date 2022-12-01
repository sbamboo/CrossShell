<#
  .SYNOPSIS
  Lists avaliable cmdlets.
#>
param([alias("num")][switch]$count)
$l = $script:pathables.length
write-host "$l command(s)" -f darkgray
if (!$count) {
  foreach ($cmdlet in $script:pathables) {
    [array]$cmdletA = $cmdlet -split "§"
    write-host $cmdletA[0] -f yellow
  }
}