<#
  .SYNOPSIS
  Prints out $script:pathables to $basedir\dev\pathables.dta
#>
param([switch]$return)

<#Devmode head #> $devmode = verify_Devmode; if ($devmode -ne $true) { write-host "This is a development command! Run crosshell in devmode to use this command." -f red; exit }

if ($return) {
    return $script:pathables 
} else {
    if (test-path "$script:basedir\dev\pathables.dta") {rm "$script:basedir\dev\pathables.dta"}
    foreach ($p in $script:pathables) {
        $p | out-file "$script:basedir\dev\pathables.dta" -append
    }
}