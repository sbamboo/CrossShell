<#
  .SYNOPSIS
  Used to change things related to the message central.
#>

param([string]$disable,[string]$enable)

if ($disable) {
    if ($disable -eq "vscodenotice") {
        $script:msgcentral_vscodenotice = $false
    }
}
if ($enable) {
    if ($disable -eq "vscodenotice") {
        $script:msgcentral_vscodenotice = $true
    }
}