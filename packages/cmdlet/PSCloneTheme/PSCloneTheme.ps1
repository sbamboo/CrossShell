checkandrun-input "prefix -set 'CS {dir}> '"
checkandrun-input "title -set 'Crosshell 0.0.2 DEV'"
cls
write-host "Crosshell $script:crosshell_versionID"
write-host ""
write-host "  " -NoNewline
Write-Host " You are running a development version of crosshell. " -b gray -f darkred
write-host "  " -NoNewline
Write-Host " PSCloneTheme Loaded!                                " -b gray -f darkGreen
write-host "  " -NoNewline
Write-Host " Welcomme write 'help' for help.                     " -b gray -f darkGreen
write-host ""
Set-Variable "CSVersion" -value $script:crosshell_versionID -scope Script