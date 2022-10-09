<#
  .SYNOPSIS
  Cmdlet for getting information from crosshell webinfo (webi)
#>
param([string]$id,[string]$nid,[alias("o")][switch]$open)

#id
if ($id) {
    [string]$id_linkbase = "https://simonkalmiclaesson.github.io/"
    $id_link1 = "crosshell_web/idsystem/id_handler.html"
    $url = "$id_linkbase" + "$id_link1" + "?id=$id&giveurl"
    if ($open) {
      start "$url"
    } else {
      $c = "urllocation_" + "$id" + " = "
      $newlink = (((iwr "$url").content -split "$c")[1] -split "`n")[0] -replace '"',''
      $url = "$id_linkbase" + "$newlink"
      [string]$content = (iwr "$url").content
      $matches = [regex]::matches($content,'<h1>.*</h1>|<p>.*</p>|<i>.*</i>|<br>').value
      foreach ($m in $matches) {
        [string]$s = "$m"
        $s = $s.replace("<i>","$($psstyle.Italic)")
        $s = $s.replace("</i>","$($psstyle.ItalicOff)")
        $s = $s.replace("<b>","$($psstyle.Bold)")
        $s = $s.replace("</b>","$($psstyle.BoldOff)")
        $s = $s.replace("<h1>","$($psstyle.Bold)Article: ")
        $s = $s.replace("</h1>","$($psstyle.BoldOff)")
        $s = $s.replace("<p>","")
        $s = $s.replace("</p>","")
        $s = $s.replace("<br>","")
        write-output "$s"
      }
    }
}

#nid
if ($nid) {
  [string]$nid_linkbase = "https://simonkalmiclaesson.github.io/"
  $nid_link1 = "crosshell_web/idsystem/id_handler.html"
  $url = "$nid_linkbase" + "$nid_link1" + "?id=$nid&giveurl"
  if ($open) {
    start "$url"
  } else {
    $c = "urllocation_" + "$nid" + " = "
    $newlink = (((iwr "$url").content -split "$c")[1] -split "`n")[0] -replace '"',''
    $url = "$nid_linkbase" + "$newlink"
    [string]$content = (iwr "$url").content
    $matches = [regex]::matches($content,'<h1>.*</h1>|<p>.*</p>|<i>.*</i>|<br>').value
    foreach ($m in $matches) {
      [string]$s = "$m"
      $s = $s.replace("<i>","$($psstyle.Italic)")
      $s = $s.replace("</i>","$($psstyle.ItalicOff)")
      $s = $s.replace("<b>","$($psstyle.Bold)")
      $s = $s.replace("</b>","$($psstyle.BoldOff)")
      $s = $s.replace("<h1>","$($psstyle.Bold)Article: ")
      $s = $s.replace("</h1>","$($psstyle.BoldOff)")
      $s = $s.replace("<p>","")
      $s = $s.replace("</p>","")
      $s = $s.replace("<br>","")
      write-output "$s"
    }
  }
}