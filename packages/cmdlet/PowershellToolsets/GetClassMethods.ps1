<#
  .SYNOPSIS
  Script to get Methods of a PowershellClass.
#>
param([string]$classname,[switch]$raw,[switch]$json)

$i = "$classname"

[array]$objs = $null
foreach ($c in (iex("[$i].GetMethods()") | select -Unique)) {
  [string]$rawd = "$($c.name): " + $c
  [array]$objs += "$rawd"
}

$stringBuild = '$hashTable = @{"Data"= @{'
foreach ($c in (iex("[$i].GetMethods()") | select -Unique)) {
    $matches = $objs | where -filterscript { ("$_".split(" "))[0].trimend(":") -eq $c.name}
    $sb = '"' + $c.name + '" = @{'
    if ("$stringBuild" -like "*$sb*") {} else {
        $count = 0
        foreach ($o in $matches) {
            [array]$ar = "$o".split(" ")
            $parent = $ar[0].trimend(":")
            $type = $ar[1]
            if ("$sb" -like "*$type*") {
                $type = "$type" + "_$count"
                $count++
            }
            $syntax = $ar[2..$ar.length]
            $sb += '"' + $type + '"="' + "$syntax" + '";'
        }
        $sb = $sb.trimend(';')
        $sb += '};'
        $stringBuild += "$sb"
    }
}
$stringBuild = $stringBuild.trimend(';')
$stringBuild += '}}'

$stringBuild = $stringBuild.Replace("`n","")

iex($stringBuild)

[pscustomobject]$ClassObject = [pscustomobject]$hashtable

$jsonraw = ConvertTo-Json $ClassObject

# Output Raw
if ($raw) {
    return $ClassObject
} elseif ($json) {
    return $jsonraw
} else {
    $line = "="*($host.UI.RawUI.BufferSize.Width - 1)
    write-host "  Methods in Math: " -f Green
    write-host "$line" -f green
    $JsonData = ConvertFrom-Json "$jsonraw"
    [string]$elem1 = $JsonData.Data
    $elem1 = "$elem1".replace("@{","")
    $elem1 = "$elem1".replace("}","")
    $elem1 = "$elem1".replace(" ","")
    [array]$elem1A = "$elem1".split("=;")
    foreach ($elem2 in $elem1A) {
      write-host "  $($elem2):" -f DarkMagenta
      [string]$elem3 = $JsonData.Data."$elem2"
      $elem3 = "$elem3".replace("@{","")
      $elem3 = "$elem3".replace("}","")
      $elem3 = "$elem3".replace(" ","")
      [array]$elem3A = "$elem3".split(";")
      foreach ($elem4 in $elem3A) {
        $elem5 = ($elem4.split("="))[0]
        $elem6 = $elem4.replace("$elem5=","")
        $elem5 = $elem5.replace("System.","")
        $elem5 = $elem5.replace("ValueTuple2","Tuple2")
        write-host "      $($elem6)     " -f DarkYellow #-NoNewline
        #write-host "($elem5)" -f DarkGray
      }
      write-host ""
    }
}