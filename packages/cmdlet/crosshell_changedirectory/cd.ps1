<#
  .SYNOPSIS
  Alias to: Change-Directory
#>
param([Parameter(ValueFromPipeline=$true)][string]$dir)
cd $psscriptroot
. .\Change-Directory.ps1 -dir "$dir"