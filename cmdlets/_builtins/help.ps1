<#
  .SYNOPSIS
  Shows this help menu.
#>
param([alias("o")][switch]$online,[alias("s")][switch]$spaced)
if ($online) {$help_mappedCmdlets_getonline = $true} else {$help_mappedCmdlets_getonline = $false}

function GetLongest {
  [int]$longest = 0
  foreach ($c in $script:pathables) {
    [array]$cmdletData = $c -split " § "
    [string]$cmdletName = $cmdletData[0]
    if ([int]$longest -lt $cmdletName.length) {[int]$longest = $cmdletName.length}
  }
  return [int]$longest
}
[int]$longest = GetLongest

write-host -nonewline "  Commands in shell:" -f darkgreen
$l = $script:pathables.length; write-host " $l command(s)" -f darkgray
write-host "======================================" -f darkgreen
foreach ($c in $script:pathables) {
  [array]$cmdletData = $c -split " § "
  [string]$cmdletPath = $cmdletData[1]
  [string]$cmdletName = $cmdletData[0]
  $name = $cmdletName
  $mapped_cmdlets = gc $psscriptroot\..\mapped_cmdlets.list
  $extension = $cmdletPath | split-path -extension
  if ($extension -ne ".ps1") {
    if ($extension -eq ".exe") {
      $desc = "(Executable)"
    } elseif ($extension -eq ".bat") {
      $desc = "(Batch file)"
    } else {
      if ($mapped_cmdlets -like "*$name*") {
        if ($help_mappedCmdlets_getonline) {
          $cmd = $name
          $remarks = (get-help $cmd).remarks
          [array]$remarksA = $remarks -split "`n"
          $link = $remarksA[$remarksA.length-1]
          $link = $link.trimstart(" ")
          $link = $link -replace "go to ",""
          $link = $link.trimend(".")
          $old_ErrorActionPreference = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue'
          $data = ""
          $data = iwr($link)
          $ErrorActionPreference = $old_ErrorActionPreference
          if ($data) {
            $desc = (((($data.content -split '<div class="summaryHolder">')[1] -split '<nav id="center-doc-outline" class="doc-outline is-hidden-desktop" data-bi-name="intopic toc" role="navigation" aria-label="On page navigation">')[0] -split '<p>')[1] -split '</p>')[0]
            $desc = $desc -replace '<strong>',''
            $desc = $desc -replace '</strong>',''
            $desc = $desc -replace "`n",''
          } else {
            $desc = "(Mapped cmdlet)"
          }
        } else {
          $desc = "(Mapped cmdlet)"
        }
      } else {
        $desc = ""
      }
    }
  } elseif ($name -eq "help") {
    $desc = "Shows this help menu."
  } else {
    $desc = (get-help $cmdletPath).synopsis
  }
  [int]$a = $longest - $name.length + 1
  $line = " "*$a
  $line += "$desc"

  write-host -nonewline "$name" -f darkblue
  if ($line -like "*Alias to: *") {
    [array]$lineA = $line -split ": "
    $line1 = $lineA[0] + ": "
    $line2 = $lineA[1]
    write-host -nonewline "$line1" -f darkgray
    write-host "$line2" -f gray
  } else {
    write-host "$line" -f darkgray
  }
  if ($spaced) {write-host ""}
}
write-host ""