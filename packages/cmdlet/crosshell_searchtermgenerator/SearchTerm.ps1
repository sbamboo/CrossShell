<#
  .SYNOPSIS
  Search term generator.
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
    [switch]$end,
    [alias("a","any","match")]
    [switch]$anywere
)

if ($exact) {
    $outterm = "$term"
} elseif ($start) {
    $outterm = "$term*"
} elseif ($end) {
    $outterm = "*$term"
} elseif ($anywere) {
    $outterm = "*$term*"
} else {
    write-host "No term mode given, use: -exact, -start, -end, -anywere" -f red
    return
}

return $outterm