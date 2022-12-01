<#
  .SYNOPSIS
  cmdlet to generate a random key
#>

<#Devmode head #> $devmode = verify_Devmode; if ($devmode -ne $true) { write-host "This is a development command! Run crosshell in devmode to use this command." -f red; exit }

$cl = get-location
Set-Location "$script:basedir\assets"

# Create prep key file
  #sets
  [string]$endfile = "randkey.key"
  [string]$prefile = "$endfile" + ".pre"
  #Clear
  if (test-path "$prefile") { remove-item "$prefile" }
  #Randoms
  get-random -count 500 | out-file $prefile -append
  #uuid
  $i = 0; while ($i -lt 20) {
    ([guid]::NewGuid()).guid | out-file $prefile -append
    $i++
  }
  #Randomize
  $content = get-content $prefile
  $i = 0; while ($i -lt 20) {
    $content = $content | get-random -shuffle
    $i++
  }
  $content | out-file $prefile
  #remove newlines
  $content = get-content $prefile
  foreach ($_ in $content) {
    [string]$contentS += "$_"
  }
  $contentS | out-file $prefile

# Get file hash
  $hash = Get-FileHash "$prefile"
  remove-item $prefile -force
  $hash.hash | out-file $endfile

write-host "Created key in $endfile."

set-location $cl