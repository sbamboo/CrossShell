<#
  .SYNOPSIS
  View log files.
#>

param([switch]$inputs)

function printFormatedLog {
    param([string]$log,[string]$mode)
    if ($mode -eq "auto") {
        $hback = $host.ui.rawui.backgroundcolor
        [array]$dateColor = "darkblue","$hback"
        [array]$timeColor = "darkyellow","$hback"
        [array]$cmdoColor = "darkgreen","$hback"
        [array]$boxcColor = "darkmagenta","$hback"
        [array]$cmntColor = "darkgray","$hback"
        $logcontents = gc $log
        foreach ($_ in $logcontents) {
            [array]$logcontentsA = $_ -split " "
            [string]$date = $logcontentsA[0] -replace '\[',''
            [string]$time = $logcontentsA[1] -replace '\]',''
            [string]$cmdo = $logcontentsA[4..$logcontentsA.length]
            if ($date -eq "") {$date = " >>> notags <<<"}
            if ($time -eq "") {$time = ""}
            [string]$head = $cmdo[0..4] -replace ' ',''
            if ($head -ne ". h e a d") {
                write-host -nonewline "[" -f $boxcColor[0] -b $boxcColor[1]
                write-host -nonewline "$date" -f $dateColor[0] -b $dateColor[1]
                write-host -nonewline " "
                write-host -nonewline "$time" -f $timeColor[0] -b $timeColor[1]
                write-host -nonewline "]" -f $boxcColor[0] -b $boxcColor[1]
                write-host -nonewline "   "
                if ($cmdo[0] -eq "#") {
                    write-host -nonewline "$cmdo" -f $cmntColor[0] -b $cmntColor[1]
                } elseif ($cmdo -like "*saveState >>*") {
                    write-host -nonewline "$cmdo" -f $cmntColor[0] -b $cmntColor[1]
                } else {
                    write-host -nonewline "$cmdo" -f $cmdoColor[0] -b $cmdoColor[1]
                }
                write-host ""
            }
            [array]$logcontentsA = $null
        }
    }
}

if ($inputs) {
    $log = "$psscriptroot\..\..\assets\inputs.log"
    printFormatedLog -log $log -mode "auto" 
}