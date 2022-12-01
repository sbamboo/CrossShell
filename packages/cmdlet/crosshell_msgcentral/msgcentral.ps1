<#
  .SYNOPSIS
  Used to change things related to the message central.
#>

param([string]$disable,[string]$enable,[switch]$list)

if ($disable) {
    if ($disable -eq "vscodenotice") {
        saveState "msgcentral_vscodenotice" $false msgcentral
    }
    if ($disable -eq "notlatest") {
        saveState "msgcentral_notlatestversion" $false msgcentral
    }
    if ($disable -eq "devversion") {
        saveState "msgcentral_devversion" $false msgcentral
    }
    if ($disable -eq "nocolorhello") {
        saveState "msgcentral_nocolorhello" $false msgcentral
    }
}
if ($enable) {
    if ($enable -eq "vscodenotice") {
        saveState "msgcentral_vscodenotice" $true msgcentral
    }
    if ($enable -eq "notlatest") {
        saveState "msgcentral_notlatestversion" $true msgcentral
    }
    if ($enable -eq "devversion") {
        saveState "msgcentral_devversion" $true msgcentral
    }
    if ($enable -eq "nocolorhello") {
        saveState "msgcentral_nocolorhello" $true msgcentral
    }
}
if ($list) {
    write-host "Msgcentral states:" -f green
    write-host "-  vscodenotice" -f darkyellow
    write-host "-  notlatest" -f darkyellow
    write-host "-  devversion" -f darkyellow
    write-host "-  nocolorhello" -f darkyellow
}