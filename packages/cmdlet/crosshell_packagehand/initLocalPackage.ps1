<#
  .SYNOPSIS
  Loads a local module.
#>

param([string]$packagepath)

$script:initpackageloader_original_pathables = $script:pathables
[array]$script:initpackageloader_hasloader += "$packagepath"

function initpackageloader_load-cmdlets {
    param([string]$packagepath)
    cd "$packagepath"
    $files = get-childitem -recurse
    echo "$files"
    foreach ($file in $files) {
      $fileext = $file | split-path -extension
      $filename = $file | split-path -leafbase
      $filepath = "$file"
      $pathableFile = $false
      if ($fileext -eq ".ps1") {$pathableFile = $true}
      if ($fileext -eq ".bat") {$pathableFile = $true}
      if ($fileext -eq ".exe") {$pathableFile = $true}
      if ($fileext -eq ".pwsh") {$pathableFile = $true}
      if ($fileext -eq ".py") {$pathableFile = $true}
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
    if (test-path mapped_cmdlets.list) {
        $mapped_cmdlets = gc mapped_cmdlets.list
        foreach ($mcmdlet in $mapped_cmdlets) {
            [string]$newline = "$mcmdlet § $mcmdlet"
            [array]$script:pathables += "$newline"
        }
    }
    $script:pathables = $script:pathables | sort
  }

# run
$exi = $False
foreach ($p in $script:pathables) {
    [string]$s = $p
    [string]$name = split-path $packagepath -leaf
    if ("$s" -like "*$name*") {
        $exi = $True
    }
}


if ($exi -eq $false) {
    write-host "Adding package '$packagepath'" -f green
    initpackageloader_load-cmdlets "$packagepath"
    $script:initpackageloader_new_pathables = $script:pathables
} else {
    write-host "Package is already loaded ($packagepath)" -f red
}