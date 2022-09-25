<#
  .SYNOPSIS
  Cmdlet for shutting of a windows computer and more.
#>

param(
    [alias("now")][alias("s")][switch]$shutdown,
    [alias("r")][switch]$restart,
    [alias("f")][switch]$force
)


#shutdown
if ($shutdown) {
  if (!$force) {
    $r = read-host "Are you sure you want to shutdown your computer? "
    if ("$r" -eq "yes" -or "$r" -eq "y") {} else {break}
  }
  shutdown /p
}

#restart
if ($restart) {
  if (!$force) {
    $r = read-host "Are you sure you want to restart your computer? "
    if ("$r" -eq "yes" -or "$r" -eq "y") {} else {break}
  }
  shutdown /r /t 0
}