<#
  .SYNOPSIS
  Used to get information about a command.
#>
param([Parameter(ValueFromPipeline=$true)][string]$command,[alias("p")][switch]$passthru)
if ($command) {
  foreach ($c in $script:pathables) {
    $cn = ($c -split " § ")[0]
    $cp = ($c -split " § ")[1]
    if ($cn -eq $command) {


      #passthru
      if ($passthru) {
        get-help $cp

      #Normal
      } else {
       #name
        $name = "$cn" + ":"
       #description
        if ("$(split-path $cp -Extension)" -eq ".py") {
          $descriptionConfig = "$(($cp -replace ($(split-path $cp -leaf))).trimend('/'))$($cn)_desc.cfg"
          if (test-path "$descriptionConfig") {
            $desc = get-content $descriptionConfig
          }
        } else {
          $desc = (get-help $cp).synopsis
        }
       #params
        $preparam_old_ErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"
        $content = (((((((get-help $cp | out-string) -split 'SYNTAX')[1] -split "ALIASES")[0] -split "DESCRIPTION")[0] -split "\[\<CommonParameters\>\]")[0] -split "\n")[1] + '[<CommonParameters>]').trimstart(" ")
        $ErrorActionPreference = $preparam_old_ErrorActionPreference
        [array]$contentA = $content -split " "
        [string]$params = $contentA[1.. $contentA.length]
        $params = $params
        if ("$(split-path $cp -Extension)" -eq ".py") {    
          $argumentsConfig = "$(($cp -replace ($(split-path $cp -leaf))).trimend('/'))$($cn)_argu.cfg"
          if (test-path $argumentsConfig) {
            $params_r = get-content $argumentsConfig
            foreach ($l in $params_r) {
              [string]$params_lr += "[-$l] "
            }
            $params = $params_lr
          }
        }

       write-host ""
       write-host -nonewline "$name" -f blue
       write-host "  $desc" -f darkgreen
       write-host "$params" -f darkyellow
       write-host "For more info about CommonParameters write 'webi commonparameters'" -f darkgray
       write-host ""
      }

    }
  }
}