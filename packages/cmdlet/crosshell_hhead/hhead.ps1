<#
  .SYNOPSIS
  Shows the console header.
#>
param([switch]$nocls)
if ($nocls) {
    write-header -nocls $true
} else {
    write-header
}