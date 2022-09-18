<#
  .SYNOPSIS
  Script runner.
#>
param([string]$file)

if (test-path $file) {
    $data = gc $file
    if ($data) {
        foreach ($_ in $data) {
            CheckAndRun-input $_
        }
    }
}