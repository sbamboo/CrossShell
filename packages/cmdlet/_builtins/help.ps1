<#
  .SYNOPSIS
  Shows this help menu.
#>

# Params
param(
  [alias("o")]
  [switch]$online,

  [alias("s")]
  [switch]$spaced,
  
  [alias("n","num","numeral","numerals","numbers","shownumbers")]
  [switch]$shownumerals,
  
  [alias("m")]
  [switch]$more,

  [Parameter(ValueFromPipeline=$true)]
  [alias("se","search")]
  [string]$searchterm
)

# Code
if ($online) {$help_mappedCmdlets_getonline = $true} else {$help_mappedCmdlets_getonline = $false}

if ($searchterm) {
  $script:pathables_backup = $script:pathables
  $script:pathables = $script:pathables | Where-Object -FilterScript { $_ -like "$searchterm" }
}

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

write-host ""
if ($searchterm) {write-host -nonewline "      Command matches:" -f darkgreen} else {write-host -nonewline "     Commands in shell:" -f darkgreen}
$l = $script:pathables.length; write-host " $l command(s)" -f darkgray
write-host "==========================================" -f darkgreen
$counter = 0
foreach ($c in $script:pathables) {
  $counter++
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
    if ($more) {
      $showMoreContet = $true
      $content = ""
      $content = (((((((get-help $cmdletPath | out-string) -split 'SYNTAX')[1] -split "ALIASES")[0] -split "DESCRIPTION")[0] -split "\[\<CommonParameters\>\]")[0] -split "\n")[1] + '[<CommonParameters>]').trimstart(" ")
        [array]$contentA = $content -split " "
        [string]$params = $contentA[1.. $contentA.length]
        $params = $params
      $desc = (get-help $cmdletPath).SYNOPSIS
    } else {
      $showMoreContet = $false
      $desc = (get-help $cmdletPath).SYNOPSIS
    }
  }
  [int]$a = $longest - $name.length + 1
  $line = " "*$a
  $line += "$desc"
  if ($shownumerals) {
    $counterS = ""
    [int]$cl = "$counter".length
    [string]$pls = $script:pathables.length
    [int]$pl = $pls.length
    [int]$cpd = $pl - $cl
    if ($cl -lt $pl) {[string]$counterS = " "*$cpd; [string]$counterS += "$counter"} else {$counterS = $counter}
    write-host -nonewline "$counterS    " -f darkgray
  }
  #name
  write-host -nonewline "$name" -f darkblue
  #desc
  if ($more) {$col = "darkgreen"} else {$col = "darkgray"}
  if ($line -like "*Alias to: *") {
    [array]$lineA = $line -split ": "
    $line1 = $lineA[0] + ": "
    $line2 = $lineA[1]
    write-host -nonewline "$line1" -f $col
    write-host "$line2" -f gray
  } else {
    write-host "$line" -f $col
  }
  #params
  if ($more) {$s = "   " + "$params".trimstart(" "); write-host $s -f darkgray}
  if ($spaced) {write-host ""}
}
write-host ""
write-host "(Use 'get-help <command>' for more info about that command, including the 'help' command.)" -f darkgreen
write-host ""

if ($searchterm) {$script:pathables = $script:pathables_backup}