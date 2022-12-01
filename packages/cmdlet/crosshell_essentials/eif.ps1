<#
  .SYNOPSIS
  While loops in crosshell.
#>

# Set in
[string]$in = $args

# params (raw)
  # extended syntax
  $param_extendedSyntax = $true

# Set rawstring function
function rawstring ($rawstring) {
    $rawstring = $rawstring -replace ('%dollarSign%','$')
    $rawstring = $rawstring -replace ('%openParen%','(')
    $rawstring = $rawstring -replace ('%closeParen%',')')
    $rawstring = $rawstring -replace ('%openCurly%','{')
    $rawstring = $rawstring -replace ('%closeCurly%','}')
    return $rawstring
}
# Set runString functions
function runstringParen ($runstring) {
  $runstring = $runstring -replace ('%dollarSign%','$')
  $runstring = $runstring -replace ('%openParen%','(')
  $runstring = $runstring -replace ('%closeParen%',')')
  # fix and run i
  [regex]$pattern1 = "\("
  [regex]$pattern2 = "\)"
  $runstring = $pattern1.replace($runstring, "", 1)
  $runstring = $pattern2.replace($runstring, "", -1)
  $runstringRet = CheckAndRun-input "$runstring" -noerror
  if ($runstringRet -ne "") {
    if ($runstringRet -eq "False") {
      $runstring = '$False'
    } elseif ($runstringRet -eq "True") {
      $runstring = '$True'
    } else {
      $runstring = $runstringRet
    }
  } else {
    $runstring = '$False'
  }
  $runstring = "(" + $runstring + ")"
  return $runstring
}
function runstringCurly ($runstring) {
  $runstring = $runstring -replace ('%dollarSign%','$')
  $runstring = $runstring -replace ('%openCurly%','{')
  $runstring = $runstring -replace ('%closeCurly%','}')
  # fix and run i
  [regex]$pattern1 = "{"
  [regex]$pattern2 = "}"
  $runstring = $pattern1.replace($runstring, "", 1)
  $runstring = $pattern2.replace($runstring, "", -1)
  $runstringRet = CheckAndRun-input "$runstring" -noerror
  if ($runstringRet -ne "") {
    if ($runstringRet -eq "False") {
      $runstring = '$False'
    } elseif ($runstringRet -eq "True") {
      $runstring = '$True'
    } else {
      $runstring = $runstringRet
    }
  } else {
    $errString = 'Cmdlet "' + $command + '", not found!'
    write-host $errString -f red
    $runstring = '$False'
  }
  $runstring = "{" + $runstring + "}"
  return $runstring
}
function removePlaceholders ($rawstring) {
  $rawstring = $rawstring -replace ('\/','|')
  $rawstring = $rawstring -replace ('%dollarSign%','')
  $rawstring = $rawstring -replace ('%openParen%','')
  $rawstring = $rawstring -replace ('%closeParen%','')
  $rawstring = $rawstring -replace ('%openCurly%','')
  $rawstring = $rawstring -replace ('%closeCurly%','')
  return $rawstring
}
$rawstring = rawstring($in)

# Split elems
$elemA = ($in | select-string -pattern "%openParen%.*%closeParen%").matches.value
$elemB = ($in | select-string -pattern "%openCurly%.*%closeCurly%").matches.value

# ExtendedSyntax
if ($param_extendedSyntax -ne $true) {
  $elemA = runStringParen($elemA)
  # Run
  $c = "if $elemA " + '{CheckAndRun-Input "' + "$(removePlaceholders($elemB))" + '"}'
  $stringBuild = rawstring("$c")
} else {
  # Run
  $stringBuild = rawstring("if $elemA $elemB")
}
iex("$stringBuild")