<#
  .SYNOPSIS
  Cmdlet for handling rich prefix. (Needs a nerdfont installed)
#>

param([alias("l")][switch]$load,[alias("r")][switch]$reset)

#richprefix by Simon Kalmi Claesson
$richprefix = '{u.000A}{f.darkcyan}{u.e0b6}{f.white}{b.darkcyan} {dir:"{dir}\ "}{r}{f.darkcyan}{u.e0b0} {f.black}{b.magenta}{u.e0b0} {f.white}{bold}{user}@{hostname} {r}{f.magenta}{u.e0b0}{boldoff}{r} '

if ($load) {
    CheckAndRun-input "prefix -set '$richprefix'"
}

if ($reset) {
    CheckAndRun-input "prefix -reset"
}