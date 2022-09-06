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
}

function CheckAndRun-input {
  param([string]$in)
  $inc = ""
  if ($script:debug_commandparts -eq $true) {write-host -nonewline "recived.alinput: " -f darkgray; write-host "$in" -b darkblue}
  $ch = " | "
  $ch2 = ' & '
  [array]$splitString = $in
  if ($in -like "*$ch*") {[array]$splitString = $in -split " \| "} else {[array]$splitString = $in -split "\|"}
  foreach ($commando in $splitString) {
    [array]$stringA = $commando -split " "
    [string]$command = $stringA[0]
    [string]$params = $stringA[1..$stringA.length]
    if ($script:debug_commandparts -eq $true) {write-host -nonewline "recived.command: " -f darkgray; write-host -nonewline "$command" -f green; write-host " $params" -f red}
    foreach ($cmdlet in $script:pathables) {
      [array]$cmdletData = $cmdlet -split " § "
      [string]$cmdletPath = $cmdletData[1]
      [string]$cmdlet = $cmdletData[0]
      if ($command -eq $cmdlet) {
        $in = $in -replace "$command",". $cmdletPath"
      }
    }
  }

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