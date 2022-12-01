<#
  .SYNOPSIS
  Cmdlet for extracting options/settings from the current session to a valid format.
#>

param($file,[switch]$format)

# Format function
function Format {
    param([pscustomobject]$data)
    $amount = ($extractedSettings.psobject.properties.length).length
    $c = 0
    foreach ($o in $data.psobject.properties) {
      $c++
      $name = (($o.name).split('.'))[1]
      $type = (($o.name).split('.'))[0]
      $info = $o.Value
      if ($c -eq $amount) {
        [string]$sb += "$($type), $($name): $($info)"
      } else {
        [string]$sb += "$($type), $($name): $($info),`n"
      }
    }
    return $sb
}

# Get data
  # Prep
  $extractedSettings = [pscustomobject]@{}
  # States
  if (test-path "$basedir\assets\states") {
    $items = get-childitem "$basedir\assets\states" -Recurse
    $items = $items | where Name -like "*.state"
  }
  foreach ($stateFile in $items) {
    # Get state
    $state = get-content $stateFile
    $name = "$stateFile" | split-path -leaf
    $name = $name.replace('.state',"")
    Add-Member -InputObject $extractedSettings -NotePropertyName "state.$name" -NotePropertyValue "$state"
  }
  # Title
  if (test-path "$basedir\assets\title.state") {
    $titleData = get-content "$basedir\assets\title.state"
    $titleData = ($titleData.split("`n"))[0]
    Add-Member -InputObject $extractedSettings -NotePropertyName "state.title" -NotePropertyValue "$titleData"
  }

# To a file
if ($file) {
  Format($extractedSettings) | Out-File "$file"
  echo "`e[32mPrinted settings to $file`e[0m"
} else {
    # To console
    if ($format) {
      return  Format($extractedSettings)
    } else {
      return $extractedSettings
    }
}   