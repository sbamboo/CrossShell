<#
  .SYNOPSIS
  Command for running included third-party games.
#>

param([alias("name")][string]$game,[switch]$list)

if ($list) {
  $files = get-childitem "$psscriptroot\.games\" -recurse
  foreach ($file in $files) {
    if ($file.mode -eq "-a---") {
      if ((split-path $file -extension) -eq ".ps1") {
        write-host $file.name -f darkyellow
      }
    }
  }
}

if ($game) {
  $files = get-childitem "$psscriptroot\.games\" -recurse
  foreach ($file in $files) {
    if ($file.mode -eq "-a---") {
      if ((split-path $file -extension) -eq ".ps1") {
        if ((split-path $file -leafbase) -eq "$game") {
          $oldexecpol = get-executionpolicy
          Set-executionpolicy bypass
          $p = "$file"
          $name = $file.name
          $curpath = gl
          $pa = $p.replace($(split-path $p -leaf),"")
          cd $pa
          $data = gc .\$name
          if ($data[0] -eq "#requires -version 2" -or $data[0] -eq "#requires -version 5.1") {
            start powershell $pa$name
          } else {
            start pwsh $pa$name
          }
          cd $curpath
          $script:gobackcommand = "Set-executionpolicy $oldexecpol"
          break
        }
      }
    }
  }
}