<#
  .SYNOPSIS
  Starts an app.
#>
param([Parameter(ValueFromPipeline = $true)]$a)

$c = "start $a"
if ($c -notlike "*;*") {iex($c)}