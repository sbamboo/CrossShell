<#
  .SYNOPSIS
  Script runner.
#>
param([string]$file)

$filemode_extended = $false

if (test-path $file) {
    $data = gc $file
    if ($data -like "*# crosshell.exprMulti:true*") {$filemode_extended = $true}
    if ($data) {
        foreach ($_ in $data) {
            [string]$cmd = $_
            [array]$cmdA = $cmd -split ';'
            foreach ($scmd in $cmdA) {
                $scmd = $scmd.TrimStart(" ")
                if ($scmd[0] -eq "#") {$scmd = "rem " + $scmd.TrimStart("#")}
                #Regular script running
                if ($filemode_extended -ne $true) {
                    CheckAndRun-input $scmd
                #ExtendedFilemode
                } elseif ($filemode_extended -eq $true) {
                    $fallbackout = CheckAndRun-input $scmd -returnFormated -noerror
                    if ($fallbackout -like "*#!!invalidExec*") {
                        $fallbackout = $fallbackout -replace " #!!invalidExec",""
                        [array]$fallbackoutA = $fallbackout -split " "
                        $old_ErrorActionPreference = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue'
                        $out = get-command $fallbackoutA[0]
                        $ErrorActionPreference = $old_ErrorActionPreference
                        if ($out) {
                            iex($scmd)
                        } else {
                            $errString = 'No cmdlet in "' + $scmd + '" found!'
                            write-host $errString -f red
                        }
                    }
                }
            }
        }
    }
}