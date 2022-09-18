<#
  .SYNOPSIS
  Script runner.
#>
param([string]$file)

if (test-path $file) {
    $data = gc $file
    if ($data) {
        foreach ($_ in $data) {
            [string]$cmd = $_
            [array]$cmdA = $cmd -split ';'
            foreach ($scmd in $cmdA) {
                $scmd = $scmd.TrimStart(" ")
                if ($scmd[0] -eq "#") {$scmd = "rem " + $scmd.TrimStart("#")}
                CheckAndRun-input $scmd
            }
        }
    }
}