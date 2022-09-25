<#
  .SYNOPSIS
  Comments out a line
#>
$string = "$args"
if ($script:shell_param_scriptfile) {if ($script:shell_param_printcomments -ne $true) {exit} else {$string = "# $string"}}
[string]$string = "`e[90m$string`e[0m"
return $string