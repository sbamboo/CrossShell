<#
  .SYNOPSIS
  Cmdlet for creating empty file.
#>
param($file)
"" | out-file -file $file