<#
  .SYNOPSIS
  Cmdlet for saving and loading the pwsh screen buffer.
#>
param([switch]$save,[switch]$load)
  if ($save) {
    $w = $host.ui.rawui.buffersize.width
    $h = $host.ui.rawui.buffersize.height
    $Source = New-Object System.Management.Automation.Host.Rectangle 0, 0, $w, $h
    $script:ScreenBuffer = $host.UI.RawUI.GetBufferContents($Source)
  } elseif ($load) {
    $w = $host.ui.rawui.buffersize.width
    $h = $host.ui.rawui.buffersize.height
    $Source = New-Object System.Management.Automation.Host.Rectangle 0, 0, $w, $h
    $host.UI.RawUI.SetBufferContents((New-Object System.Management.Automation.Host.Coordinates $Source.Left, $Source.Top), $script:ScreenBuffer)
    $c = 'echo "`e[' + ($h-4) + 'B"'
    iex($c)
  }