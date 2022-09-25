<#
  .SYNOPSIS
  Lists avaliable cmdlets.
#>
param([alias("num")]$count)
if ($count) {
  $l = $script:pathables.length
  write-host "$l command(s)" -f darkgray
} else {
  $l = $script:pathables.length
  write-host "$l command(s)" -f darkgray
  foreach ($cmdlet in $script:pathables) {
    [array]$cmdletA = $cmdlet -split "§"
    write-host $cmdletA[0] -f yellow
  }
}