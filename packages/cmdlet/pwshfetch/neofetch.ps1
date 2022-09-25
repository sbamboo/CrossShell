<#
  .SYNOPSIS
  Alias to: pwshfetch
#>
param(
    [string][alias('i')]$image,
    [switch][alias('g')]$genconf,
    [string][alias('c')]$configpath,
    [switch][alias('n')]$noimage,
    [switch][alias('l')]$switchlogo,
    [switch][alias('b')]$blink,
    [switch][alias('s')]$stripansi,
    [switch][alias('a')]$all,
    [switch][alias('h')]$help,
    [ValidateSet("text", "bar", "textbar", "bartext")][string]$cpustyle = "text",
    [ValidateSet("text", "bar", "textbar", "bartext")][string]$memorystyle = "text",
    [ValidateSet("text", "bar", "textbar", "bartext")][string]$diskstyle = "text",
    [ValidateSet("text", "bar", "textbar", "bartext")][string]$batterystyle = "text",
    [array]$showdisks = @($env:SystemDrive),
    [array]$showpkgs = @("scoop", "choco")
)


. $psscriptroot\pwshfetch.ps1 @PSBoundParameters