<#
  .SYNOPSIS
  Cmdlet for handling variables.
#>
param( 
  [switch]$set,
  [switch]$get,
  [switch]$rem,

  [string]$name,
  [Parameter(ValueFromPipeline=$true)]$value
)

if ($set) {
  if ($name) {if ($value) {
    set-variable -name $name -value $value -scope script
  }}
}

if ($get) {
  if ($name) {
    return (get-variable $name).value
  }
}

if ($rem) {
  if ($name) {
    set-variable -name $name -value $null -scope script
  }
}