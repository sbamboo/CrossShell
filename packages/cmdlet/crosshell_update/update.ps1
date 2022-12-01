<#
  .SYNOPSIS
  Cmdlet for updating the shell.
#>
param(
  [switch]$revertbackup,[alias("p","package","packages","up")][switch]$updatepackages,[alias("dep")][switch]$dependencys
)

$script:crosshell_update_switch_updatepackages = $updatepackages

$lastvermt = 'https://raw.githubusercontent.com/simonkalmiclaesson/CrossShell/main/lastver.mt'

# Try and update update cmdlet
if ($dependencys) {
  CheckAndRun-Input "packagehand -install crosshell_packagehand -force"
}
CheckAndRun-Input "packagehand -install crosshell_update -force"

#update packages
function autoUpdatepackages {
  if ($script:crosshell_update_switch_updatepackages) {
    CheckAndRun-input "packagehand -update -all"
  }
}


if ($revertbackup) {
  $cl = gl
  cd $script:basedir
  if (test-path "core.latestbackup") {
    #shell file
    del shell.ps1 -force
    copy ".\shell.latestbackup" "shell.ps1"
    autoUpdatepackages
    if (test-path "$script:basedir\oldver.mt") {
      if (test-path "$script:basedir\lastver.mt") { del "$script:basedir\lastver.mt" }
      ren "$script:basedir\oldver.mt" "lastver.mt"
    }
    #core file
    del core.ps1 -force
    copy ".\core.latestbackup" "core.ps1"
    autoUpdatepackages
    if (test-path "$script:basedir\oldver.mt") {
      if (test-path "$script:basedir\lastver.mt") { del "$script:basedir\lastver.mt" }
      ren "$script:basedir\oldver.mt" "lastver.mt"
    }
    #start
    .\core.ps1
  } else {
    write-host "No backups found! Canceling..." -f red
  }
  cd $cl
} else {

  #Update
  $cl1 = get-location
  cd "$script:coredir"
  if (test-path "core.ps1") {
    #Core file
    if (test-path "core.latestbackup") {
      if (test-path "core.oldbackup") { del "core.oldbackup" }
      ren "core.latestbackup" "core.oldbackup"
    }
    ren "core.ps1" "core.latestbackup"
    $old_ProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"
    iwr -uri "https://raw.githubusercontent.com/simonkalmiclaesson/CrossShell/main/core/core.ps1" -outfile core.ps1
    $ProgressPreference = $old_ProgressPreference
    #shell file
    if (test-path "shell.latestbackup") {
      if (test-path "shell.oldbackup") { del "shell.oldbackup" }
      ren "shell.latestbackup" "shell.oldbackup"
    }
    if (test-path "shell.ps1") {ren "shell.ps1" "shell.latestbackup"}
    $old_ProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"
    iwr -uri "https://raw.githubusercontent.com/simonkalmiclaesson/CrossShell/main/core/shell.ps1" -outfile shell.ps1
    $ProgressPreference = $old_ProgressPreference
    #continue
    if ((test-path "core.ps1") -and (test-path "shell.ps1")) {
      if (test-path "$script:basedir\oldver.mt") { del "$script:basedir\oldver.mt" }
      if (test-path "$script:basedir\lastver.mt") { ren "$script:basedir\lastver.mt" "oldver.mt"; Invoke-WebRequest -Uri "$lastvermt" -outfile "$script:basedir\lastver.mt"}
      autoUpdatepackages
      .\core.ps1
    } else {
      write-host "Update failed, reverting changes." -f red
      if (test-path "core.ps1") { del core.ps1 }
      ren "core.latestbackup" "core.ps1"
      if (test-path "shell.ps1") { del shell.ps1 }
      ren "shell.latestbackup" "shell.ps1"
      autoUpdatepackages
      .\core.ps1
    }
  }
  cd $cl1
}
