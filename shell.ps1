# License: https://github.com/simonkalmiclaesson/CrossShell/blob/main/license.md (licence.md)

param(
  [alias("startdir")]
  $sdir,

  [alias("f")]
  [alias("interpreter")]
  $interpret,

  [alias("c")]
  [alias("command")]
  $pipedcommand
)

if ($interpret) {
  . "$psscriptroot\readers\readFile" -file $interpret | iex
  exit
}

$old_windowtitle = $host.ui.rawui.windowtitle
if ($script:old_path) {} else {$script:old_path = $pwd}
$script:default_prefix = "> "
$script:prefix_enabled = $true
$script:prefixcolor = "darkgray"
$script:prefixdircolor = "darkgray"
$script:prefix_dir = $true
$script:basedir = $psscriptroot
if ($script:startdir) {} else {$script:startdir = $pwd}
if ($sdir) {$startdir = $sdir}

function script:write-message{
  #Usage:   write-message <text-array> <foregroundcolor-array> <backgroundcolor-array>
  #         if <text-array> has more then one item, the function will write them both to one line but with diffrent color options if the color array have more then one item.
  #         obs text.1 gets colored by fcolor.1 and fcolor.2, while text.2 is colored by corresponding places in color arrays.
  #         if no colors are given it will use the $host.ui.rawui colors (may inpact colors on older pwsh versions)
  #
  param([array]$text,[alias("fc")][array]$foregroundcolor,[alias("bc")][array]$backgroundcolor)
  #Single mode
  if ($array.length -eq 1) {
    [string]$string = "$text"
    [string]$fcolor = "$foregroundcolor"
    [string]$bcolor = "$backgroundcolor"
    if ($fcolor -eq "") {$fcolor = $host.ui.rawui.foregroundcolor}
    if ($bcolor -eq "") {$bcolor = $host.ui.rawui.backgroundcolor}
    write-host "$string" -f $fcolor -b $bcolor
  #MultiMode
  } else {
    [int]$counter = 0
    foreach ($t in $text) {
      [string]$string = "$t"
      if ($foregroundcolor.length -gt 1) {
        [string]$fcolor = $foregroundcolor[$counter]
      } else { 
        [string]$fcolor = $foregroundcolor 
      }
      if ($backgroundcolor.length -gt 1) {
        [string]$bcolor = $backgroundcolor[$counter]
      } else {
        [string]$bcolor = $backgroundcolor
      }
      if ($fcolor -eq "") {$fcolor = $host.ui.rawui.foregroundcolor}
      if ($bcolor -eq "") {$bcolor = $host.ui.rawui.backgroundcolor}
      $counter++
      if ($counter -lt $text.length) {
        write-host -nonewline "$string" -f $fcolor -b $bcolor
      } else {
        write-host "$string" -f $fcolor -b $bcolor
      }
    }
  }
}

function script:load-cmdlets {
  $script:pathables = $null
  cd $psscriptroot\cmdlets
  $files = get-childitem -recurse

  foreach ($file in $files) {
    $fileext = $file | split-path -extension
    $filename = $file | split-path -leafbase
    $filepath = "$file"
    $pathableFile = $false
    if ($fileext -eq ".ps1") {$pathableFile = $true}
    if ($fileext -eq ".bat") {$pathableFile = $true}
    if ($fileext -eq ".exe") {$pathableFile = $true}
    if ($fileext -eq ".pwsh") {$pathableFile = $true}
    #check for hidden files
    $filepathO = $filepath.replace("\",'§')
    [array]$filepathA = $filepathO -split '§'
    foreach ($f in $filepathA) {if ($f -like ".*") {$pathableFile = $false}}
    if ($file.mode -ne "-a---") {$pathableFile = $false}
    if ($pathableFile -eq $true) {
      [string]$newline = "$filename § $filepath"
      [array]$script:pathables += "$newline"
    }
  }
  $mapped_cmdlets = gc mapped_cmdlets.list
  foreach ($mcmdlet in $mapped_cmdlets) {
    [string]$newline = "$mcmdlet § $mcmdlet"
    [array]$script:pathables += "$newline"
  }
  $script:pathables = $script:pathables | sort
}

function CheckAndRun-input {
  param([string]$in)
  $inc = ""
  if ($script:debug_commandparts -eq $true) {write-host -nonewline "recived.alinput: " -f darkgray; write-host "$in" -b darkblue}
  $ch = " | "
  $ch2 = ' & '
  [array]$splitString = $in
  if ($in -like "*$ch*") {[array]$splitString = $in -split " \| "} else {[array]$splitString = $in -split "\|"}
  [array]$script:partials = $null
  foreach ($commando in $splitString) {
    [array]$stringA = $commando -split " "
    [string]$command = $stringA[0]
    [string]$params = $stringA[1..$stringA.length]
    if ($script:debug_commandparts -eq $true) {write-host -nonewline "recived.command: " -f darkgray; write-host -nonewline "$command" -f green; write-host " $params" -f red}
    foreach ($cmdlet in $script:pathables) {
      [array]$cmdletData = $cmdlet -split " § "
      [string]$cmdletPath = $cmdletData[1]
      [string]$cmdlet = $cmdletData[0]
      $final_cmdletpath = ""
      if ($command -eq $cmdlet) {
        $script:final_cmdletpath = $cmdletPath
        $script:final_params = $params
        # Calculator " fix
        if ($command -eq "calc") {
          [array]$paramsA = $params -split " "
          [string]$first_param = $paramsA[0]
          if ($first_param -notlike "*-expr*") {
            if ($first_param[0] -ne "-") {
              $paramsA[0] = '"' + $first_param + '"'
            }
          } else {
            $paramsA[0] = '"' + $first_param + '"'
          }
          $params = ""
          foreach ($p in $paramsA) {
            $params += "$p "
          }
          $params = $params.trimend(" ")
          $script:final_params = $params
        }
      }
    }
    #$in = $in -replace "$command",". $final_cmdletPath"
    [array]$script:partials += ". $script:final_cmdletpath $script:final_params"
  }
  if ($script:partials.length -gt "1") {
    foreach ($p in $script:partials) {
      $num = [array]::indexof($script:partials,$p)
      $t = $script:partials[$num]
      $script:partials[$num] = "$t | "
      if ($script:debug_commandparts_final) {write-host -nonewline "parsed.partial: " -f darkgray; write-host "$p" -f green}
    }
    $t2 = $script:partials[-1]
    $script:partials[-1] = "$t2" -replace " \| ",''
  }
  [string]$script:partials_string = $script:partials
  $in = $partials_string
  if ($script:debug_commandparts_final) {write-host -nonewline "parsed.input: " -f darkgray; write-host -nonewline "$in`n" -f green}

  $cmdFound = $false
  foreach ($cmdlet in $script:pathables) {
    [array]$cmdletData = $cmdlet -split " § "
    [string]$cmdlet = $cmdletData[0]
    if ($command -eq $cmdlet) {
      $cmdFound = $true
      $inc = $in
    }
  }
  if ($cmdFound -ne $true) {
    $errString = 'Cmdlet "' + $command + '", not found!'
    write-host $errString -f red
  }
  if ($inc) {iex($inc)}
}

function forceExit {
  param([switch]$check,[switch]$set,[switch]$reset)
  $curdir = get-location
  cd $psscriptroot\assets
  $old_ErrorActionPreference = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue'
  if ($check) {
    if ((test-path "forceexit.state") -eq $true) {cd $script:old_path;exit}
  }
  if ($set) {
    if ((test-path "forceexit.state") -eq $true) {} else {"1" | out-file -file "forceexit.state"}
  }
  if ($reset) {
    if ((test-path "forceexit.state") -eq $true) {rm "forceexit.state" -force}
  }
  $ErrorActionPreference = $old_ErrorActionPreference
  cd $curdir
}

if ($script:hasresetforceExit) {} else {forceExit -reset; $script:hasresetforceExit}

function writeDirPrefix($dirp) {
  [array]$dircolor = $script:prefixdircolor -split ','
  $dir = $dirp
  [array]$dirA = $dir -split "\\"
  [string]$c0 = $dircolor[0]
  [string]$c1 = $dircolor[1]
  if ($c1 -eq "") {$c1 = $c0}
  foreach ($f in $dirA) {
    write-host -nonewline $f -f $c0
    write-host -nonewline "\" -f $c1
  }
}

function write-header {
  cls
  write-message "Welcome, write 'help' for help." green
}

##shell
if ($pipedcommand) {load-cmdlets; CheckAndRun-input $pipedcommand;exit}
$host.ui.rawui.windowtitle = "ShellTest 0.0.1"
$loop = $true
load-cmdlets
cd $startdir
$prefix = $script:default_prefix
write-header
while ($loop) {
  forceExit -check
  $script:current_directory = $pwd
  if ($script:gobackcommand) {iex($script:gobackcommand); $script:gobackcommand = $null}
  $command = $null
  if ($script:prefix_dir) {writeDirPrefix($pwd)}
  write-host -nonewline $prefix -f $script:prefixcolor
  $command = read-host
  if ($command -eq "exit") {
    $host.ui.rawui.windowtitle = $old_windowtitle
    cd $old_path
    forceExit -set
    exit
  }
  if ($command -ne "") {CheckAndRun-input $command}
}