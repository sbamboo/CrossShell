<#
  .SYNOPSIS
  Alias to: packagehand
#>

param(
  [alias("a")]
  [alias("add")]
  [switch]$install,
  
  [alias("r")]
  [alias("remove")]
  [switch]$uninstall,
  
  [alias("u")]
  [switch]$update,

  [alias("l")]
  [switch]$list,

  [alias("g")]
  [switch]$get,

  [alias("p")]
  [Parameter(ValueFromPipeline=$true)]
  [string]$package,

  [alias("v")]
  [string]$version,

  #VersionTags
  [switch]$latest,
  [switch]$lts,

  #misc
  [switch]$force,
  [switch]$meta,
  [switch]$all,
  [alias("ar","reload")]
  [switch]$autoreload,
<<<<<<< Updated upstream:packages/cmdlet/crosshell_packagehand/ph.ps1
=======
  [switch]$showiwrprogress,
>>>>>>> Stashed changes:packages/cmdlet/_builtins/packagehand/ph.ps1

  [alias("s")]
  [string]$search
)


. "$psscriptroot\packagehand.ps1" @PSBoundParameters