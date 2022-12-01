<#
  .SYNOPSIS
  Load last saved working directory.
#>

param([switch]$print)

#Save
cd "$script:crosshell_directorysave_lastdir"

#Print
if ($print) {
  return "$script:crosshell_directorysave_lastdir"
}