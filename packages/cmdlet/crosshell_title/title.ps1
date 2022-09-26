<#
  .SYNOPSIS
  Command for changing and reseting the console title.
#>

param([Alias("s")][string]$set,[Alias("g")][switch]$get,[Alias("r")][switch]$reset,[switch]$SetHost)

function titleSave {
    param([switch]$remove,[string]$set)
    if ($remove) {
        if (test-path "$script:basedir\assets\title.state") { rm "$script:basedir\assets\title.state" }
    }
    if ($set) {
        $set | out-file "$script:basedir\assets\title.state"
    }
}

# Get
if ($get) {
    return $script:shell_opt_windowtitle_current
}

#Set
if ($set -ne "") {
    $script:shell_opt_windowtitle_last = $script:shell_opt_windowtitle_current
    $script:shell_opt_windowtitle_current = $set
    titleSave -set "$set"
}

#Reset
if ($reset) {
    $script:shell_opt_windowtitle_last = $script:shell_opt_windowtitle_current
    $script:shell_opt_windowtitle_current = $script:shell_opt_windowtitle_normal
    titleSave -remove
}

#SetHost
if ($SetHost) {
    $script:shell_opt_windowtitle_last = $script:shell_opt_windowtitle_current
    $script:shell_opt_windowtitle_current = $script:shell_opt_windowtitle_original
    titleSave -remove
}