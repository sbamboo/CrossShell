<#
  .SYNOPSIS
  Imports scripts files.
#>

param([string]$file,[alias("c","cs","cross","csession","session","global")][switch]$crosssession,[alias("l")][switch]$local,[switch]$load,[switch]$reset,[switch]$remove,[switch]$get)

# Setup
$stackfile = "$psscriptroot\Imports\imports.stack"

# Local
if (test-path "$file") {
    . "$file"
} else {
    return "File not found."
}
exit

# CrossSession
if ($load) {
    $currentContent = get-content $stackfile
    foreach ($_ in $currentContent) {
        $l = $_
        $l = ($l.trimend(" ")).trimstart(" ")
        if (test-path "$file") {
            . "$file"
        } else {
            return "File not found."
        }
    }
} elseif ($reset) {
    write-host "Are you sure you want to reset the saved imports? [Y/N]" -f DarkYellow
    $c = read-host
    if ($c -eq "y") {
        "" | out-file 
    } else {
        return "Operation canceled."
    }
} elseif ($remove) {
    $currentContent = get-content $stackfile
    #find remove line containing substring from file powershell.
    # Source: https://stackoverflow.com/a/43223404 .
    Set-Content -Path "$file" -Value (get-content -Path "$file" | Select-String -Pattern "$file" -NotMatch)
} elseif ($get) {
    $currentContent = get-content $stackfile
    return $currentContent
} else {
    $currentContent = get-content $stackfile
    if ($currentContent -notlike "*$file*") {
        "$file" | out-file $stackfile -append
    } else {
        return "The file '$file' is already saved to import."
    }
}