<#
  .SYNOPSIS
  Cmdlet for changing and toggling the shell prefix.
#>
param([Parameter(ValueFromPipeline=$true)][string]$p,[alias("r")][switch]$reset,[alias("s")][switch]$set,[alias("t")][switch]$toggle,[alias("c")][switch]$setcolor,[alias("sc")][string]$setprefixcolor,[alias("d")][switch]$dir,[string]$setdircolor,[switch]$get)
if ($reset) {
  saveState "prefix" $script:default_prefix prefix
}

if ($set) {
  saveState "prefix" "$p" prefix
}

if ($get) {
  return $script:prefix
}

if ($toggle) {
  if ($script:prefix_enabled -eq $true) {$newval = $false}
  if ($script:prefix_enabled -eq $false) {$newval = $true}
  saveState "prefix_enabled" $newval prefix
  if ($script:prefix_enabled -eq $true) {
    if ($p) {
      saveState "prefix" $p prefix
    } else {
      saveState "prefix" $script:default_prefix prefix
    }
  } else {
    saveState "prefix" "" prefix
  }
}

if ($setprefixcolor) {
  saveState "prefixcolor" $setprefixcolor prefix
}

if ($setcolor) {
  write-host -nonewline "Prefix color: " -f darkgray
  $script:prefixcolor = read-host
  saveState "prefixcolor" $script:prefixcolor prefix
  write-host -nonewline "Dir color: " -f darkgray
  $script:prefixdircolor = read-host
  saveState "prefixdircolor" $script:prefixdircolor prefix
}

if ($dir) {
  if ($script:prefix_dir -eq $true) {$newval = $false}
  if ($script:prefix_dir -eq $false) {$newval = $true}
  saveState "prefix_dir" $newval prefix
}

if ($setdircolor) {
  saveState "prefixdircolor" $setdircolor prefix
}