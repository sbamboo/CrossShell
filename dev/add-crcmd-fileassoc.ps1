<#
  .SYNOPSIS
  Adds crcmd file to be executable.
#>

param([switch]$reset)

function crosshellfileassoc {
  param([string]$shellfile,[string]$filetype,[switch]$reset)
  if ($reset) {
    [string]$command = "assoc $filetype="
    cmd.exe /c "$command"
  } else {
    cmd.exe /c assoc $filetype=crosshellscript
    cmd.exe /c ftype crosshellscript=pwsh.exe -command "$shellfile -file %0"
  }
}

if ($reset) {
  crosshellfileassoc -reset -filetype ".crcmd"
  exit
} else {
  write-host -nonewline "Are you sure this will edit the registry! [Y/N] " -f yellow
  $yn = read-host
  if ($yn -eq "y") {
    $fa = "$script:psscriptroot\..\core\core.ps1"
    crosshellfileassoc -shellfile "$fa" -filetype ".crcmd"
  }
}