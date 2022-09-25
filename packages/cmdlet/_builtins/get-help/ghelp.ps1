<#
  .SYNOPSIS
  Alias to: get-help
#>
param([Parameter(ValueFromPipeline=$true)][string]$command,[alias("p")][switch]$passthru)

. $psscriptroot\get-help.ps1 @PSBoundParameters