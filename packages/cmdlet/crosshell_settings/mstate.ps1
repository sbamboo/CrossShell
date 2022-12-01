<#
  .SYNOPSIS
  Management command for setting and reseting states.
#>
param([switch]$remove,[string]$name,[switch]$all)

#remove state
if ($remove) {
  write-host -nonewline "'" -f darkyellow
  write-host -nonewline "mstate -remove" -f yellow 
  write-host -nonewline "' will remove saved states, are you sure you want to continue? [Y/N] " -f darkYellow
  $c = read-host
  if ($c -ne "y") {exit}
  $cl = gl
  $dir = "$script:basedir\assets\states"
  if (test-path "$dir") {
    cd $dir
    if ($name) {
      if (test-path "$name") {
        rmdir "$name" -Force -Recurse
      }
    } elseif ($all) {
      $exi = ls $dir
      foreach ($e in $exi) {
        if ($e.mode -eq "d----") {
          rmdir "$e" -Force -Recurse
        }
      }
    }
  }
  cd $cl
}