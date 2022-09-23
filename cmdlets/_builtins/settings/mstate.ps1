<#
  .SYNOPSIS
  Management command for setting and reseting states.
#>
param([switch]$state,[switch]$reset,[switch]$enable,[switch]$disable)

#auto sets


if ($name) {

  #reset states
  if ($reset) {
      $value = $false
  }

  #Set states
  saveState $name,$value,$folder,$reset
  
}