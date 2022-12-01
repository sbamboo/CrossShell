<#
  .SYNOPSIS
  INTERNAL USE ONLY
#>

param($localkey,[string]$decrypt,[switch]$verify)

if ($decrypt) {
    $dec = "$decrypt" | convertto-securestring | convertfrom-securestring -asplaintext
    return $dec
    exit
}

if ($verify) {
    $currentkey = "$script:shell_devmode" | convertto-securestring | convertfrom-securestring -asplaintext
    $devmodekey_uri = "https://raw.githubusercontent.com/simonkalmiclaesson/CrossShell/main/assets/devmode.key"
    [string]$online_devmodekey = (Invoke-WebRequest "$devmodekey_uri").content
    $online_devmodekey = ($online_devmodekey -split "`r")[0]
    $cl = get-location
    Set-Location "$psscriptroot"
    $currentkey | out-file "devmodekey_local.tmp"
    $local_devmodekey = (Get-FileHash "devmodekey_local.tmp").hash
    remove-item "devmodekey_local.tmp"
    if ("$local_devmodekey" -eq "$online_devmodekey") {
        return "$true"
    } else {
        return $false
    }
    Set-Location $cl
}

$script:shell_devmode = $false
if ($localkey -ne "") {
  $devmodekey_uri = "https://raw.githubusercontent.com/simonkalmiclaesson/CrossShell/main/assets/devmode.key"
  [string]$online_devmodekey = (Invoke-WebRequest "$devmodekey_uri").content
  $online_devmodekey = ($online_devmodekey -split "`r")[0]
  $cl = get-location
  Set-Location "$psscriptroot"
  $localkey | out-file "devmodekey_local.tmp"
  $local_devmodekey = (Get-FileHash "devmodekey_local.tmp").hash
  remove-item "devmodekey_local.tmp"
  if ("$local_devmodekey" -eq "$online_devmodekey") {
    $localkeyenc = convertto-securestring "$localkey" -asplaintext -force | convertfrom-securestring
    $script:shell_devmode = $localkeyenc
  }
}
Set-Location $cl