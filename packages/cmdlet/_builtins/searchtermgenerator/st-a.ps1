<#
  .SYNOPSIS
  Alias to: SearchTerm -anywere
#>
param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("t","searchterm","st")]
    [string]$term,
    [alias("strict","x","ex")]
    [switch]$exact,
    [alias("s")]
    [switch]$start,
    [alias("e")]
    [switch]$end
)
. "$psscriptroot\SearchTerm.ps1" -a @PSBoundParameters