<#
  .SYNOPSIS
  Reloads the shell.
#>
param([alias("f")][switch]$full,[switch]$nocls,[switch]$noheader,[string]$devmodekey)

if ($full) {
  cd $script:basedir
  if ($devmodekey -eq "") {
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
    if ($noheader) {
      if ($nocls) {
        .\shell.ps1 -sdir $script:current_directory -supressCls -noheader -devmodekey "$devmodekey"
      } else {
        .\shell.ps1 -sdir $script:current_directory -noheader -devmodekey "$devmodekey"
      }
    } else {
      if ($nocls) {
        .\shell.ps1 -sdir $script:current_directory -supressCls  -devmodekey "$devmodekey"
      } else {
        .\shell.ps1 -sdir $script:current_directory -devmodekey "$devmodekey"
      }
    }
  }
} else {
  $cl = gl
  load-cmdlets
  cd $cl
}