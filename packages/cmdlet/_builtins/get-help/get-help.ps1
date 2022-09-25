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
        $desc = (get-help $cp).synopsis
       #params
        $content = (((((((get-help $cp | out-string) -split 'SYNTAX')[1] -split "ALIASES")[0] -split "DESCRIPTION")[0] -split "\[\<CommonParameters\>\]")[0] -split "\n")[1] + '[<CommonParameters>]').trimstart(" ")
        [array]$contentA = $content -split " "
        [string]$params = $contentA[1.. $contentA.length]
        $params = $params

       write-host ""
       write-host -nonewline "$name" -f blue
       write-host "  $desc" -f darkgreen
       write-host "$params" -f darkyellow
       write-host ""
      }

    }
  }
}