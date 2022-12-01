<#
  .SYNOPSIS
  Alias to: SearchTerm -exact
#>
param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("t","searchterm","st")]
    [string]$term,
    [alias("s")]
    [switch]$start,
    [alias("e")]
    [switch]$end,
    [alias("a","any","match")]
    [switch]$anywere
)
. "$psscriptroot\SearchTerm.ps1" -x @PSBoundParameters