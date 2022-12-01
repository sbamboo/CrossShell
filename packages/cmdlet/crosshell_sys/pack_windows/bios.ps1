<#
  .SYNOPSIS
  Wrapper for the shutdown command. Boots in to bios.
#>

param([switch]$force)

if (!$force) {
    $confirmed = $false
    while ($confirmed -ne $true) {
        write-host -nonewline "Are you sure you want to reboot your computer into bios? " -f darkyellow
        $c = read-host "[y/n] "
        if ($c -eq "y") {$confirmed = $true} elseif ($c -eq "n") {exit}
    }
}

cmd.exe /c "shutdown /r /fw /f /t 0"