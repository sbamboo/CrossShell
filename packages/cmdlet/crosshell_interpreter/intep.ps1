<#
  .SYNOPSIS
  Interpriter for python, nodejs, pwsh, cmd and bash.
#>
param(
  [Alias("c")]
  [string]$icommand,

  [Alias("f")]
  [string]$file,

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
  . "$script:basedir\readers\readFile" -file $file -reader $reader| iex
} else {
  if ($icommand) {
    $c = . "$script:basedir\readers\readFile" -cmd "$icommand" -reader $reader
    iex($c)
    if ($c -like "*tmp.nodecommand.js*") {
      if (test-path "$script:basedir\readers\tmp.nodecommand.js") {
        remove-item "$script:basedir\readers\tmp.nodecommand.js"
      }
    }
  } else {
    if ($reader) {} else {write-host -nonewline "Readertype: "; $reader = read-host}
    cls
    write-host "         Write-command bellow:" -f gray
    write-host "=========================================" -f darkgreen
    write-host "cmds: Exit: '-exit', SetReader: '-reader'" -f darkgray
    $loop = $true
    while ($loop) {
      $icommand = read-host
      if ($icommand -eq "-exit") {exit} elseif ($icommand -eq "-reader") {write-host -nonewline "Readertype: "; $reader = read-host} else {. "$script:basedir\readers\readFile" -cmd $icommand -reader $reader | iex}
    }
  }
}
cd $curdir