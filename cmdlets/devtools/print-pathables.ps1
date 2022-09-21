<#
  .SYNOPSIS
  Prints out $script:pathables to $basedir\dev\pathables.dta
#>
param([switch]$return)

if ($return) {
    return $script:pathables 
} else {
    if (test-path "$script:basedir\dev\pathables.dta") {rm "$script:basedir\dev\pathables.dta"}
    foreach ($p in $script:pathables) {
        $p | out-file "$script:basedir\dev\pathables.dta" -append
    }
}