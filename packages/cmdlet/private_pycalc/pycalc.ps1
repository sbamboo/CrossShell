<#
  .SYNOPSIS
  Simple calculator by Simon Kalmi Claesson for a school project.
#>
param($debug)
if ($debug) {
    1 | out-file -file "$psscriptroot\debug.state"
}
CheckAndRun-input "intep -file '$psscriptroot\SchoolProjectCalculator_Prev_2022-09-27.py' -python"
if (test-path "$psscriptroot\debug.state") {del "$psscriptroot\debug.state"}