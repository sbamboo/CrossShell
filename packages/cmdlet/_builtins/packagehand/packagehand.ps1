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

  [alias("s")]
  [string]$search
)

# Get repo
$repo_raw = gc "C:\Users\simonkalmi.claesson\Documents\Github\packagehand_repository\repo.json"
$repo_data = ConvertFrom-Json "$repo_raw"

#get os
if ($IsWindows) {
  $os = "win"
} elseif ($IsLinux) {
  $os = "lnx"
} elseif ($IsMacOs) {
  $os = "mac"
}

#function to create package meta
function Create-PackageMeta {
  [pscustomobject]$packagemeta = @{}
  $packagemeta += @{"Description"=$script:package_description}
  $packagemeta += @{"versionTag"=$script:package_versiontag}
  $packagemeta += @{"type"=$script:package_type}
  $packagemeta += @{"source"=$script:package_source}
  $packagemeta += @{"sourceType"=$script:package_sourceType}
  $packagemeta += @{"format"=$script:package_format}
  $packagemeta += @{"target"=$script:package_target}
  $packagemeta += @{"version"=$script:package_version}
  ConvertTo-Json $packagemeta | out-file "$package_name.meta"
}

# check package
$exi = $false
foreach ($pack in $repo_data.packagehand_repo) {
  $s = "$pack"
  $tag = ($s -split "=")[0]
  if ($tag -eq "@{$package") {
    $exi = $true
  }
}
if (!$list -and !$search -and !$get -and !$all) {
  if ($exi -eq $false) { write-host "Package $package not found in repo." -f red; exit}
}

# handle repo data
  # Version
  $script:package_versiontag = "latest"
  if ($lts) {
    $script:package_versiontag = "LTS"
  } elseif ($latest) {
    $script:package_versiontag = "latest"
  }

  # check avaliability
  if (!$list -and !$search -and !$get -and !$all) {
    if ($repo_data.packagehand_repo."$package" -like "*$script:package_versiontag*") {} else {
      write-host "No $script:package_versiontag version is avialible for $package. Continuing with any avaliable version." -f darkgray
      if ($package_versiontag -eq "latest") {    if ($repo_data.packagehand_repo."$package" -like "*LTS*") {$package_versiontag = "LTS"} else {foreach ($vtag in $repo_data.packagehand_repo."$package") {$package_versiontag = "$vtag" -replace '@|{|}|=',""}}
      } elseif ($package_versiontag -eq "LTS") { if ($repo_data.packagehand_repo."$package" -like "*latest*") {$package_versiontag = "latest"} else {foreach ($vtag in $repo_data.packagehand_repo."$package") {$package_versiontag = "$vtag" -replace '@|{|}|=',""}}}
      $script:package_versiontag = $package_versiontag
    }
  }

  # set selctedpackage data
  $script:package_name = "$package"
  $script:repo_selectedPackage = $repo_data.packagehand_repo."$package"."$script:package_versiontag"
  $script:package_type = $repo_selectedPackage.type
  $script:package_source = $repo_selectedPackage.source."$os"
  $script:package_sourceType = $repo_selectedPackage.sourcetype
  $script:package_format = $repo_selectedPackage.format
  $script:package_target = $repo_selectedPackage.target
  $script:package_version = $repo_selectedPackage.version
  $script:package_description = $repo_selectedPackage.description

  #set final
  $script:package_final = "$script:basedir\packages\$package_type\"

# set current dir
$curdir = gl

# Install
if ($install) {
  # Check if installed
  if (!$force) {
    if (test-path "$package_final\$package_name") {
      Write-host -nonewline "Package $package_name is already installed. Proceed anyway?  " -f darkyellow
      $confirm = read-host "[Y/N] "
      if ($confirm -ne "y") {
        write-host "Operation canceled!" -f darkgray
        exit
      }
    }
  }

  # cmdlet
  if ($package_type -eq "cmdlet") {
    # install local
    if ($package_sourceType -eq "local") {
      if ($script:package_target -eq "global" -or $script:package_target -eq $os) {
        cd "$package_final"
        if (test-path "$package") {} else {mkdir $package_name | out-null}
        if ($script:package_format -eq "zip") {
          copy "$psscriptroot\$package_source" "$package_final\$package_name\$package_name.zip"
          cd "$package_final\$package_name"
          Expand-Archive "$package_name.zip" "$package_final\$package_name"-force
          del "$package_name.zip"
        } elseif ($script:package_format -eq "exe_standalone") {
          copy "$psscriptroot\$package_source" "$package_final\$package_name\$package_name.exe"
        }
        if (test-path "installscript.ps1") {. .\installscript.ps1}
        Create-PackageMeta
      } else {
        write-host "Error: Package $package_name is $script:package_target only. While host is $os." -f red
        exit
      }
    }
    # install web
    if ($package_sourceType -eq "web") {
      if ($script:package_target -eq "global" -or $script:package_target -eq $os) {
        cd "$package_final"
        if (test-path "$package") {} else {mkdir $package_name | out-null}
        if ($script:package_format -eq "zip") {
          iwr -uri "$package_source" -outfile "$package_final\$package_name\$package_name.zip"
          cd "$package_final\$package_name"
          Expand-Archive "$package_name.zip" "$package_final\$package_name"-force
          del "$package_name.zip"
        } elseif ($script:package_format -eq "exe_standalone") {
          iwr -uri "$package_source" -outfile "$package_final\$package_name\$package_name.exe"
        }
        if (test-path "installscript.ps1") {. .\installscript.ps1}
        Create-PackageMeta
      } else {
        write-host "Error: Package $package_name is $script:package_target only. While host is $os." -f red
        exit
      }
    }
  }

  #confirm
  if (test-path "$package_final\$package_name") {
    write-host "Installed package: $package_name" -f darkgreen
  } else {
    write-host "Installation of package: $script:package_name failed... Please try again." -f Red
  }
}

# Uninstall
if ($uninstall) {
  # Force
  if (!$force) {
    $text = "Are you sure you want to uninstall " + "$package_name" + "?  "
    Write-host -nonewline $text -f darkyellow
    $confirm = read-host "[Y/N] "
    if ($confirm -ne "y") {
      write-host "Operation canceled!" -f darkgray
      exit
    }
  }
  # Check if installed
  if (test-path "$package_final\$package_name") {} else {
    Write-host "Error: Package $package_name not found!" -f red
    exit
  }

  # cmdlet
  if ($package_type -eq "cmdlet") {
    remove-item "$package_final\$package_name" -force -recurse -confirm:$false
  } 

  #confirm
  if (test-path "$package_final\$package_name") {
    write-host "Uninstallation of package: $script:package_name failed... Please try again or manualy remove the folder at $script:package_final" -f Red
  } else {
    write-host "Uninstalled package: $script:package_name" -f darkred
  }
}

# Update
if ($update) {
  if ($all) {
    # Get installed packages
    [array]$match_Packs = ""
    $items = ls "$script:basedir\packages\" -recurse -exclude "_builtins"
    $items = $items | Where "mode" -eq "d----"
    foreach ($item in $items) {
      $t = $item -split "\\|\/"
      $all = $true
      $to = ("$item" -split "packages")[1] -split "\\|\/"
      foreach ($f in $to) {
        [string]$fi = $f
        if ($fi[0] -eq ".") {$all = $false}
      }
      if ($all -eq $true) {
        $t = $t[0..-2]
        if ($t[-1] -ne "packages") {
          $match_Packs += $item
        }
      }
    }
    $match_Packs = $match_Packs | sort -property name

    #create list of packages having a meta file
    foreach ($pack in $match_Packs) {
      if ($pack -ne "") {
        $name = ("$pack" -split '\\|\/')[-1]
        [string]$dir = "$pack"
        [string]$pa = "$dir" + "\" + "$name" + ".meta"
        if (test-path $pa) {
          [array]$localPackages += "$dir"
        }
      }
    }

    #Update packages
    foreach ($pack in $localPackages) {
      [string]$name = ($pack -split "\\|\/")[-1]
      [string]$pa = "$pack" + "\" + "$name" + ".meta"
      $metaraw = gc $pa
      $meta = ConvertFrom-Json "$metaraw" 
      $localversion = $meta.version
      #get packages details
      if ($lts) {
        $onlineversion = $repo_data.packagehand_repo."$name".LTS.version
      } else {
        $onlineversion = $repo_data.packagehand_repo."$name".latest.version
      }
      #download version
      if ($localversion -ne $onlineversion) {
        [string]$command = "packagehand -install $name -force"
        if ($lts) {$command += " -lts"}
        CheckAndRun-input "$command"
      }
    }

    
  } else {
    write-host "Packagehand is in development, currently to update the best way is to just run -install over the current install" -f gray
  }
}

# List
if ($list) {
  $Longest = 0
  foreach ($pack in $repo_data.packagehand_repo) {
    if ("$pack" -ne "vTag") {
      $pack = ($pack -split "=")[0]
      $pack = $pack -replace '@|{|}|=',""
      foreach ($vtag in $repo_data.packagehand_repo."$pack") {
        $vtag = $vtag -replace '@|{|}|=',""
        $string = "$pack.$vtag"
        if ($string.Length -gt $Longest) {$Longest = $string.length}
      }
    }
  }
  foreach ($pack in $repo_data.packagehand_repo) {
    if ("$pack" -ne "vTag") {
      $pack = ($pack -split "=")[0]
      $pack = $pack -replace '@|{|}|=',""
      foreach ($vtag in $repo_data.packagehand_repo."$pack") {
        $vtag = $vtag -replace '@|{|}|=',""
        $desc = $repo_data.packagehand_repo."$pack"."$vTag".description
        if ($desc) {
          $string = "$pack.$vtag"
          $string += " "*($Longest - $string.length)
          write-host -nonewline "$string" -f blue
          write-host -nonewline "   :   "
          write-host "$desc" -f darkgray
        }
      }
    }
  }
}

# Search
if ($search) {
  [array]$match_Packs = ""
  foreach ($pack in $repo_data.packagehand_repo) {
    if ("$pack" -ne "vTag") {
      $pack = ($pack -split "=")[0]
      $pack = $pack -replace '@|{|}|=',""
      $match_Packs += $pack
    }
  }
  $packages = $match_Packs | Where-Object -FilterScript { $_ -like "$search" }

  $Longest = 0
  foreach ($pack in $packages) {
    if ("$pack" -ne "vTag") {
      $pack = ($pack -split "=")[0]
      $pack = $pack -replace '@|{|}|=',""
      foreach ($vtag in $repo_data.packagehand_repo."$pack") {
        $vtag = $vtag -replace '@|{|}|=',""
        $string = "$pack.$vtag"
        if ($string.Length -gt $Longest) {$Longest = $string.length}
      }
    }
  }
  foreach ($pack in $packages) {
    if ("$pack" -ne "vTag") {
      $pack = ($pack -split "=")[0]
      $pack = $pack -replace '@|{|}|=',""
      foreach ($vtag in $repo_data.packagehand_repo."$pack") {
        $vtag = $vtag -replace '@|{|}|=',""
        $desc = $repo_data.packagehand_repo."$pack"."$vTag".description
        if ($desc) {
          $string = "$pack.$vtag"
          $string += " "*($Longest - $string.length)
          write-host -nonewline "$string" -f blue
          write-host -nonewline "   :   "
          write-host "$desc" -f darkgray
        }
      }
    }
  }
}

# Get
if ($get) {
  [array]$match_Packs = ""
  $items = ls "$script:basedir\packages\" -recurse -exclude "_builtins"
  $items = $items | Where "mode" -eq "d----"
  foreach ($item in $items) {
    $t = $item -split "\\|\/"
    $all = $true
    $to = ("$item" -split "packages")[1] -split "\\|\/"
    foreach ($f in $to) {
      [string]$fi = $f
      if ($fi[0] -eq ".") {$all = $false}
    }
    if ($all -eq $true) {
      $t = $t[0..-2]
      if ($t[-1] -ne "packages") {
        $match_Packs += $item
      }
    }
  }

  $match_Packs = $match_Packs | sort -property name

  $Longest = 0
  foreach ($pack in $match_Packs) {
    [string]$packs = ($pack -split '\\|\/')[-1]
    if ($packs.length -gt $Longest) {
      $Longest = $packs.length
    }
  }

  foreach ($pack in $match_Packs) {
    $desc = ""
    $metad = ""
    if ($pack -ne "") {
      $name = ("$pack" -split '\\|\/')[-1]
      [string]$dir = "$pack"
      [string]$pa = "$dir" + "\" + "$name" + ".meta"
      if (test-path $pa) {
        $metaraw = get-content $pa
        $metad = ConvertFrom-Json "$metaraw"
        $desc = $metad.description
      } else {
        $metaraw = "unknown"
      }
      [string]$string = $name
      $string += " "*($longest - $string.length)
      if ($meta) {
        if ($metad) {$metad}
      } else {
        if ($metaraw -ne "unknown") {
          write-host -nonewline "$string" -f blue
          write-host -nonewline "   :   "
          write-host "$desc" -f darkgray
        } else {
          write-host -nonewline "$string" -f darkred
          write-host -nonewline "   :   "
          write-host "$desc" -f darkgray
        }
      }
    }
  }
}


# go last current dir
cd $curdir