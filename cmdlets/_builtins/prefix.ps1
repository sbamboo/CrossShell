<#
  .SYNOPSIS
  Cmdlet for changing and toggling the shell prefix.
#>
param([Parameter(ValueFromPipeline=$true)][string]$p,[alias("r")][switch]$reset,[alias("s")][switch]$set,[alias("t")][switch]$toggle,[alias("c")][switch]$setcolor,[alias("sc")][string]$setprefixcolor,[alias("d")][switch]$dir,[string]$setdircolor)
if ($reset) {
  $script:prefix = $script:default_prefix
}

if ($set) {
  $script:prefix = $p
}

if ($toggle) {
  $script:prefix_enabled = ! $script:prefix_enabled
  if ($prefix_enabled -eq $true) {if ($p) {$script:prefix = $p} else {$script:prefix = $script:default_prefix}} else {$script:prefix = ""}
}

if ($setprefixcolor) {
  $script:prefixcolor = $setprefixcolor
}

if ($setcolor) {
  write-host -nonewline "Prefix color: " -f darkgray
  $script:prefixcolor = read-host
  write-host -nonewline "Dir color: " -f darkgray
  $script:prefixdircolor = read-host
}

if ($dir) {
  $script:prefix_dir = ! $script:prefix_dir
}

if ($setdircolor) {
  $script:prefixdircolor = $setdircolor
}