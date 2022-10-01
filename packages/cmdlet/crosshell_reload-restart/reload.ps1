<#
  .SYNOPSIS
  Reloads the shell.
#>
param([alias("f")][switch]$full,[switch]$nocls,[switch]$noheader)

if ($full) {
  cd $script:basedir
  if ($noheader) {
    if ($nocls) {
      .\shell.ps1 -sdir $script:current_directory -supressCls -noheader
    } else {
      .\shell.ps1 -sdir $script:current_directory -noheader
    }
  } else {
    if ($nocls) {
      .\shell.ps1 -sdir $script:current_directory -supressCls 
    } else {
      .\shell.ps1 -sdir $script:current_directory
    }
  }
} else {
  $cl = gl
  load-cmdlets
  cd $cl
}