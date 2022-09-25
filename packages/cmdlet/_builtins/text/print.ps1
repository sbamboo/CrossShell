<#
  .SYNOPSIS
  Advanced text writer supporting colors and more.
#>
param([Parameter(ValueFromPipeline=$true)][string]$text,[switch]$nonewline,[alias("f")][string]$foregroundcolor,[alias("b")][string]$backgroundcolor)
$c = "write-host $text"
if ($nonewline) {$c += " -nonewline"}
if ($foregroundcolor) {$c += " -f $foregroundcolor"}
if ($backgroundcolor) {$c += " -b $backgroundcolor"}
$c | iex