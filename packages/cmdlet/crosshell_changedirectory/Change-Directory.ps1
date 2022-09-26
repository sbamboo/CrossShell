<#
  .SYNOPSIS
  Changes your direcotory, moves to dir.
#>
param([Parameter(ValueFromPipeline=$true)][string]$dir)
cd $script:current_directory
cd $dir