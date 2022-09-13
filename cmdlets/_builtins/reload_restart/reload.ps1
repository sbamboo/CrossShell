<#
  .SYNOPSIS
  Reloads the shell.
#>
param([alias("f")][switch]$full)

if ($full) {
  cd $psscriptroot
  cd ..\..\..
  .\shell.ps1 -sdir $script:current_directory
} else {
  load-cmdlets
}