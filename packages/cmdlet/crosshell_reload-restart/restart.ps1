<#
  .SYNOPSIS
  Restarts the shell.
#>
param([switch]$nocls,[switch]$noheader)
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