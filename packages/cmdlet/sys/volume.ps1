<#
  .SYNOPSIS
  Cmdlet for changing windows volume.
#>
param($fi)
#Syntax Fix
$fi = $fi -Replace '\u002B','up'
$fi = $fi -Replace '-','down'
$fi = $fi -Replace 'x','mute'
$fi = $fi -Replace 'o','mute'
$fi = $fi -Replace '0','mute'

#Code
if ($fi -like '*mute*') {
  $obj = new-object -com wscript.shell
  $obj.SendKeys([char]173)
}
if ($fi -like '*up*') {
  $obj = New-Object -com wscript.shell
  $obj.SendKeys([char]175)
}
if ($fi -like '*down*') {
  $obj = New-Object -com wscript.shell
  $obj.SendKeys([char]174)
}