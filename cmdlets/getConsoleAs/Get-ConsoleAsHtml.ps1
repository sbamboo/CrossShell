<#
  .SYNOPSIS
  The script captures console screen buffer up to the current cursor position and returns it in HTML format.
#>
param($file)
if ($file) {
  cd .\.internal\Get-ConsoleAsHtml.ps1 | out-file "$file" -encoding ascii
}