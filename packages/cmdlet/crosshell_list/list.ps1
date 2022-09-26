<#
  .SYNOPSIS
  Lists items
#>
param([switch]$commands)
if ($commands) {
    return $script:pathables.length
}