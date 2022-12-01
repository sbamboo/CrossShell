<#
  .SYNOPSIS
  Restarts the shell.
#>
param([switch]$nocls,[switch]$noheader,[string]$devmodekey)
if ($devmodekey -eq "") {
  if ($noheader) {
    if ($nocls) {
      . "$psscriptroot\reload.ps1" -full -nocls -noheader
    } else {
      . "$psscriptroot\reload.ps1" -full -noheader
    }
  } else {
    if ($nocls) {
      . "$psscriptroot\reload.ps1" -full -nocls
    } else {
      . "$psscriptroot\reload.ps1" -full
    }
  }
} else {
  if ($noheader) {
    if ($nocls) {
      . "$psscriptroot\reload.ps1" -full -nocls -noheader -devmodekey "$devmodekey"
    } else {
      . "$psscriptroot\reload.ps1" -full -noheader -devmodekey "$devmodekey"
    }
  } else {
    if ($nocls) {
      . "$psscriptroot\reload.ps1" -full -nocls -devmodekey "$devmodekey"
    } else {
      . "$psscriptroot\reload.ps1" -full -devmodekey "$devmodekey"
    }
  }
}