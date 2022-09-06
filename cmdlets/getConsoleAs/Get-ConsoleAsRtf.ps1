<#
  .SYNOPSIS
  The script captures console screen buffer up to the current cursor position and returns it in RTF format.
#>
param($file)
if ($file) {
  cd .\.internal\Get-ConsoleAsRtf.ps1 | out-file "$file" -encoding ascii
}