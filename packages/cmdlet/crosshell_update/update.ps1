<#
  .SYNOPSIS
  Cmdlet for updating the shell.
#>
param(
  [switch]$revertbackup,[alias("p","package","packages","up")][swich]$updatepackages
)

$script:crosshell_update_switch_updatepackages = $updatepackages

#update packages
function autoUpdatepackages {
  if ($script:crosshell_update_switch_updatepackages) {
    CheckAndRun-input "packagehand -update -all"
  }
}



if ($revertbackup) {
  $cl = gl
  cd $script:basedir
  if (test-path "shell.latestbackup") {
    del shell.ps1 -force
    copy ".\shell.latestbackup" "shell.ps1"
    autoUpdatepackages
    .\shell.ps1
  } else {
    write-host "No backups found! Canceling..." -f red
  }
  cd $cl
} else {

  #Update
  cd $script:basedir
  if (test-path "shell.ps1") {
    if (test-path "shell.latestbackup") {
      if (test-path "shell.oldbackup") { del "shell.oldbackup" }
      ren "shell.latestbackup" "shell.oldbackup"
    }
    ren "shell.ps1" "shell.latestbackup"
    $old_ProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"
    iwr -uri "https://raw.githubusercontent.com/simonkalmiclaesson/CrossShell/main/shell.ps1" -outfile shell.ps1
    $ProgressPreference = $old_ProgressPreference
    if (test-path "shell.ps1") {
      autoUpdatepackages
      .\shell.ps1
    } else {
      write-host "Update failed, reverting changes." -f red
      if (test-path "shell.ps1") { del shell.ps1 }
      ren "shell.latestbackup" "shell.ps1"
      autoUpdatepackages
      .\shell.ps1
    }
  }
}
