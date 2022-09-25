<#
  .SYNOPSIS
  Package handler for Crosshell.
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

  [alias("p")]
  [Parameter(ValueFromPipeline=$true)]
  [string]$package,

  [alias("v")]
  [string]$version,

  #VersionTags
  [switch]$latest,
  [switch]$lts
)


# Get repo
$repo_raw = gc ./repo.json
$repo_data = ConvertFrom-Json "$repo_raw"

#function to create package meta
function Create-PackageMeta {
  [pscustomobject]$packagemeta = @{}
  $packagemeta += @{"versionTag"=$script:package_versiontag}
  $packagemeta += $script:repo_selectedPackage
  ConvertTo-Json $packagemeta | out-file "$package_name.meta"
}

# handle repo data
  # Version
  $script:package_versiontag = "latest"
  if ($lts) {
    $script:package_versiontag = "LTS"
  } elseif ($latest) {
    $script:package_versiontag = "latest"
  }

  # set selctedpackage data
  $script:repo_selectedPackage = $repo_data.packagehand_repo."$package"."$script:package_versiontag"
  $script:package_name = $package
  $script:package_type = $repo_selectedPackage.type
  $script:package_source = $repo_selectedPackage.source
  $script:package_sourceType = $repo_selectedPackage.sourcetype
  $script:package_format = $repo_selectedPackage.format
  $script:package_target = $repo_selectedPackage.target
  $script:package_version = $repo_selectedPackage.version

  #set final
  $script:basedir = $pwd
  $script:package_final = "$script:basedir\packages\$package_type\"

# set current dir
$curdir = gl

# Install
if ($install) {
  # cmdlet
  if ($package_type -eq "cmdlet") {
    # install local
    if ($package_sourceType -eq "local") {
      $cud = gl
      cd "$package_final"
      if (test-path "$package") {} else {mkdir $package_name}
      copy "$package_source" "$package_final\$package_name"
      pause
      cd "$package_final\$package_name"
      Expand-Archive "$package_name.zip"
      del "$package_name.zip"
      Create-PackageMeta
    }
  }
}



# go last current dir
cd $curdir