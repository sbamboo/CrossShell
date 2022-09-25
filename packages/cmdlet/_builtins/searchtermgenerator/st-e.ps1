<#
  .SYNOPSIS
  Alias to: SearchTerm -end
#>
param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("t","searchterm","st")]
    [string]$term,
    [alias("strict","x","ex")]
    [switch]$exact,
    [alias("s")]
    [switch]$start,
    [alias("a","any","match")]
    [switch]$anywere
)
. "$psscriptroot\SearchTerm.ps1" -e @PSBoundParameters