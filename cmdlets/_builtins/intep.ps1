<#
  .SYNOPSIS
  Interpriter for python, nodejs, pwsh, cmd and bash.
#>
param(
  [Alias("f")]
  [string]$file,

  [Alias("c")]
  [string]$icommand,

  [switch]$pwsh,
  [switch]$python,
  [switch]$bash,
  [switch]$cmd,
  [switch]$node
)

$curdir = get-location
if ($pwsh) {$reader = "pwsh"
} elseif ($python) {$reader = "python"
} elseif ($bash) {$reader = "bash"
} elseif ($cmd) {$reader = "cmd"
} elseif ($node) {$reader = "node"
}
if ($file) {
  . "$psscriptroot\..\..\readers\readFile" -file $file -reader $reader| iex
} else {
  if ($icommand) {
    . "$psscriptroot\..\..\readers\readFile" -cmd "$icommand" -reader $reader | iex
  } else {
    if ($reader) {} else {write-host -nonewline "Readertype: "; $reader = read-host}
    cls
    write-host "         Write-command bellow:" -f gray
    write-host "=========================================" -f darkgreen
    write-host "cmds: Exit: '-exit', SetReader: '-reader'" -f darkgray
    $loop = $true
    while ($loop) {
      $icommand = read-host
      if ($icommand -eq "-exit") {exit} elseif ($icommand -eq "-reader") {write-host -nonewline "Readertype: "; $reader = read-host} else {. "$psscriptroot\..\..\readers\readFile" -cmd $icommand -reader $reader | iex}
    }
  }
}
cd $curdir