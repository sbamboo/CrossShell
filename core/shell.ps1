#write-host "[$(get-date)]: Shell: Started" -f yellow
#Shell
if ($pipedcommand) { load-cmdlets; if ($script:shell_opt_multiline) {splitCommandAndRun $pipedcommand} else {CheckAndRun-input $pipedcommand}; $host.ui.rawui.windowtitle = $old_windowtitle; cd $old_path; if ($noexit) {pause} else {exit}}
if ($scriptfile) {[string]$cc = "script " + '"' + $scriptfile + '"'; load-cmdlets; CheckAndRun-input $cc; $host.ui.rawui.windowtitle = $old_windowtitle; cd $old_path; if ($noexit) {pause} else {exit}}
#window title
  $script:shell_opt_windowtitle_normal = "Crosshell $script:crosshell_versionID"
  $script:shell_opt_windowtitle_current = $script:shell_opt_windowtitle_normal
  #load saved title
  if (test-path "$script:basedir\assets\title.state") { $script:shell_opt_windowtitle_current = gc "$script:basedir\assets\title.state"}
#write-host "[$(get-date)]: Shell: Checked pipedcommand and set window property variables" -f yellow
#loop
$loop = $true
if ($script:hostID -ne "pwsh.5l") {load-cmdlets}
#write-host "[$(get-date)]: Shell: Loaded cmdlets" -f yellow
cd $startdir
if ($noheader) {if ($script:shell_suppress_menu_cls -ne $true) {cls}} else {write-header($script:shell_suppress_menu_cls)}
if ($script:shell_opt_norunloop -ne $true) {
  while ($loop) {
    # Check network 
    $script:Shell_NetworkAvaliable = Test-Network
    #write-host "[$(get-date)]: Shell: Network test" -f yellow
    #autoclearmode
    if ($script:crosshell_autoclearmode -eq $true) {
      cls
      if ($noheader) {if ($script:shell_suppress_menu_cls -ne $true) {cls}} else {write-header($script:shell_suppress_menu_cls)}
    }
    #windowtitle
    $host.ui.rawui.windowtitle = $script:shell_opt_windowtitle_current
    forceExit -check
    #write-host "[$(get-date)]: Shell: Title clearing and forceexit checked." -f yellow
    $script:current_directory = $pwd
    if ($script:gobackcommand) {iex($script:gobackcommand); $script:gobackcommand = $null}
    $command = $null
    #if ($script:prefix_dir -eq $true -and $script:prefix_enabled -eq $true) {writeDirPrefix($pwd)}
    write-host -nonewline $(ReplacePSStyleFormating($prefix)) -f $script:prefixcolor
    $command = read-host
    if ($command -eq "exit") {
      $host.ui.rawui.windowtitle = $old_windowtitle
      cd $old_path
      forceExit -set
      exit
    }
    if ($command -ne "") {
      logCommand -command $command -doFormat
      if ($script:shell_opt_multiline) {splitCommandAndRun $command} else {CheckAndRun-input $command}
    }
  }
}