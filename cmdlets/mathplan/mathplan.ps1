<#
  .SYNOPSIS
  prints out our math plan.
#>
param([int]$week,[string]$file,[switch]$table,[string]$day)

. "$psscriptroot\.math_plan_parse\math_plan_parse.ps1" @PSBoundParameters