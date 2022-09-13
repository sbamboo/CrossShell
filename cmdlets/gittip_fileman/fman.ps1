<#
  .SYNOPSIS
  Alias to: Fileman
#>

Param(
    #in param
    [Parameter(ValueFromPipeline=$true)]
    [Alias("n")]
    [Alias("in")]
    [string]$inp,
    
    #base params
    [Alias("p")]
    [string]$path,
    [Alias("m")]
    [string]$mode,

    #cli usage params
    [Alias("re")]
    [switch]$remove,
    [Alias("cp")]
    [switch]$copy,
    [Alias("mi")]
    [switch]$makeitem,
    [Alias("md")]
    [switch]$makeDir,
    [Alias("st")]
    [switch]$startItem,
    [Alias("ed")]
    [switch]$editItem,
    [Alias("rn")]
    [switch]$rename,
    [Alias("zi")]
    [Alias("compress")]
    [switch]$zip,
    [Alias("uz")]
    [Alias("extract")]
    [switch]$unzip,
    [Alias("xp")]
    [switch]$explorer,

    [Alias("opt")]
    [switch]$options,
    [Alias("hlp")]
    [switch]$help,
    [Alias("lice")]
    [switch]$license,
    [Alias("i")]
    [Alias("inf")]
    [switch]$info

)

. "$PSScriptRoot\.fileman\Fileman.ps1" @PSBoundParameters