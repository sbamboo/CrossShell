<#
  .SYNOPSIS
  Cmdlet for loging out of a windows computer.
#>

param(
    [alias("now")][alias("l")][switch]$logout,
    [alias("f")][switch]$force
)


#logout
if ($logout) {
  if (!$force) {
    $r = read-host "Are you sure you want to logout from your computer? "
    if ("$r" -eq "yes" -or "$r" -eq "y") {} else {break}
  }
  start "logoff"
}