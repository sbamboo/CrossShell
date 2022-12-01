<#
  .SYNOPSIS
  Saves current working directory.
#>

param([switch]$print)

#Save
$script:crosshell_directorysave_lastdir = "$pwd"

#Print
if ($print) {
  return "$pwd"
}