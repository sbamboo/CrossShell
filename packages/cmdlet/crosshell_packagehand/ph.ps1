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

  [string]$repo,

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
  [switch]$showiwrprogress,
  [switch]$shownonmetas,
  [alias("grepo","rr","rrepo")]
  [switch]$reloadrepo,
  [alias("o")]
  [switch]$overlap,

  [alias("s")]
  [string]$search
)
. "$psscriptroot\packagehand.ps1" @PSBoundParameters