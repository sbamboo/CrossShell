# This is a file existing solely for compatability reasons and should not be confused with the file in the "core" folder.

param(
  [alias("startdir")]
  $sdir,

  [alias("i")]
  [alias("interpreter")]
  $interpret,

  [alias("f")]
  [alias("script")]
  [alias("scmd")]
  [alias("file")]
  $scriptfile,

  [alias("c")]
  [alias("command")]
  $pipedcommand,

  [alias("nexit")]
  [switch]$noexit,

  [switch]$printcomments,

  [switch]$supressCls,

  [switch]$noheader,

  [switch]$autoclearmode,

  [switch]$norunloop,

  [string]$devmodekey,

  [switch]$pmi
)

if ($pmi) {
  $pmi = $null
  .\core\core.ps1 @PSBoundParameters
} else {
  pwsh $psscriptroot\core\core.ps1 @PSBoundParameters
}