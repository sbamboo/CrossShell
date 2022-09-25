<#
  .SYNOPSIS
  version-control-devtool
#>
param([switch]$generateLastver)

# Generate LastVer tag
if ($generateLastver) {
    $date = get-date -format d
    $date += "_"
    $date += (get-date).ToShortTimeString()
    $date | out-file "$script:basedir\lastver.mt"
}