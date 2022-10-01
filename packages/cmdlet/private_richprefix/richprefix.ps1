<#
  .SYNOPSIS
  Cmdlet for handling rich prefix. (Needs a nerdfont installed)
#>

param([alias("l")][string]$load,[alias("r")][switch]$reset)

$richprefix = $script:prefix

if ($load) {
  #richprefix by Simon Kalmi Claesson
  if ($load -eq "1") {$richprefix = '{u.000A}{f.darkcyan}{u.e0b6}{f.white}{b.darkcyan} {dir:"{dir}\ "}{r}{f.darkcyan}{u.e0b0} {f.black}{b.magenta}{u.e0b0} {f.white}{bold}{user}@{hostname} {r}{f.magenta}{u.e0b0}{boldoff}{r} '}
  if ($load -eq "2") {$richprefix = '{u.000A}{dir:"{f.darkcyan}{u.e0b6}{f.white}{b.darkcyan} {dir}\ {r}{f.darkcyan}{u.e0b0} "}{f.black}{b.magenta}{u.e0b0} {f.white}{bold}{user}@{hostname} {r}{f.magenta}{u.e0b0}{boldoff}{r} '}
  if ($load -eq "3") {$richprefix = '{f.magenta}{user}{f.darkgray}@{f.blue}{hostname}{f.darkgray}{f.darkgray}{dir:": {dir}\"}> {r}'}

  #load
  CheckAndRun-input "prefix -set '$richprefix'"
}

if ($reset) {
    CheckAndRun-input "prefix -reset"
}