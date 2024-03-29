# License: https://github.com/simonkalmiclaesson/CrossShell/blob/main/license.md (licence.md)
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

  [string]$devmodekey
)
#write-host "[$(get-date)]: Core: Started and loaded params..." -f yellow
if ($interpret) {
  . "$psscriptroot\..\readers\readFile" -file $interpret | iex
  exit
}

# NoRunLoop
$script:shell_opt_norunloop = $norunloop

# Network check
function script:Test-Network { if (Get-NetAdapter | Where Status -eq "Up") {return $true} else {return $false}}
$script:Shell_NetworkAvaliable = Test-Network
function script:INeedNetwork {
  if ($script:Shell_NetworkAvaliable -eq $false) {
    write-host "This command needs network access to work!" -f red
    exit
  }
}
#write-host "[$(get-date)]: Core: Checked network" -f yellow
#devmode
if ($devmodekey) {
  $cl = Get-Location
  $devmodecheck_devtools_validator = "$psscriptroot\..\packages\cmdlet\crosshell_devtools\internal_devkey_validator.ps1"
  if (test-path "$devmodecheck_devtools_validator") {
    . "$devmodecheck_devtools_validator" -localkey "$devmodekey"
    function script:verify_Devmode {
      $cl = Get-Location
      $res = . "$devmodecheck_devtools_validator" -verify
      set-location $cl
      return $res
    }
  } else {
    function script:verify_Devmode {
      return $false
    }
  }
  Set-Location $cl
} else {
  function script:verify_Devmode {
    return $false
  }
}
#write-host "[$(get-date)]: Core: Checked Devmode" -f yellow
#Version control
$script:crosshell_versionID = "0.0.6_dev-A1"
$script:crosshell_versionChannel = "Alpha"

$script:shell_opt_multiline = $false

$script:shell_param_printcomments = $printcomments
$script:shell_param_noexit = $noexit
[string]$script:shell_param_scriptfile = [string]$scriptfile
$old_windowtitle = $host.ui.rawui.windowtitle
$script:shell_opt_windowtitle_current = $host.ui.rawui.windowtitle
$script:shell_opt_windowtitle_original = $old_windowtitle
$script:shell_opt_windowtitle_last = $host.ui.rawui.windowtitle
if ($script:old_path) {} else {$script:old_path = $pwd}
$script:default_prefix = '{dir:"{dir}\"}> '
# Prefixes made by: Simon Kalmi Claesson
#  $script:default_prefix = '{f.darkgray}{dir:"{dir}:\ "}{f.magenta}{user}{f.darkgray}@{f.darkcyan}{hostname}{f.darkgray}\> {r}'
#  $script:default_prefix = '{f.magenta}{user}{f.darkgray}@{f.darkcyan}{hostname}{f.darkgray}{f.darkgray}{dir:"  {dir}\"}> {r}'
#  $script:default_prefix = '{u.000A}{f.darkcyan}{u.e0b6}{f.white}{b.darkcyan} {dir:"{dir}\ "}{r}{f.darkcyan}{u.e0b0} {f.black}{b.magenta}{u.e0b0} {f.white}{bold}{user}@{hostname} {r}{f.magenta}{u.e0b0}{boldoff}{r} '
$script:prefix_dir = $true
$script:prefix_enabled = $true
$script:prefix = $script:default_prefix
$script:prefixcolor = "darkgray"
$script:prefixdircolor = "darkgray"
$tmpcp = Get-Location
$script:basedir = "$psscriptroot\.."
Set-Location $script:basedir
$script:basedir = Get-Location
Set-Location $tmpcp
$script:coredir = "$psscriptroot"
$script:shell_suppress_menu_cls = $false
$script:crosshell_autoclearmode = $autoclearmode
if ($supressCls) {
  $script:shell_suppress_menu_cls = $true
}
if ($script:startdir) {} else {$script:startdir = $pwd}
if ($sdir) {$startdir = $sdir}

# Host Id and name setter
$inthostVersionMajor = (get-host).version.major
$inthostName = (get-host).name
if ($inthostVersionMajor -eq "7") {
  $script:hostNameID = "Powershell 7"
  $script:hostID = "pwsh.7"
} elseif ($inthostVersionMajor -eq "5") {
  $script:hostNameID = "Powershell 5 -Legacy"
  $script:hostID = "pwsh.5l"
} elseif ($inthostName -eq "Visual Studio Code Host") {
  $script:hostNameID = "Visual Studio Code Host"
  $script:hostID = "vscodehost"
} elseif ($inthostVersionMajor -eq "6") {
  $script:hostNameID = "Powershell 6 -Legacy"
  $script:hostID = "pwsh.6l"
} else {
  $script:hostNameID = "Unknown host (powershell)"
  $script:hostID = "unknown"
}

if (test-path "$psscriptroot\..\assets") {} else {
  mkdir "$psscriptroot\..\assets"
}
#write-host "[$(get-date)]: Core: Enviroment variables and version variables has been set." -f yellow

# Function to import/install modules
function script:installImportModule {
  param([string]$moduleName)
  # check if installed
  if ((get-module -ListAvailable) -like "$moduleName") { 
      # Check if imported
      if ((Get-InstalledModule) -like "$moduleName") {} else {
          import-module "$moduleName"
      }
  } else {
      #install
      Install-Module -name "$moduleName"
  }
}

# Function to log a command
function script:logCommand {
  param([string]$command,[switch]$doFormat)
  if ($doFormat) {
    [string]$datetag = "[" + $(get-date -format g) + "]  "
    [string]$commandS = "$datetag $command"
    $commandS | out-file -file "$psscriptroot\..\assets\inputs.log" -append
  } else {
    $command | out-file -file "$psscriptroot\..\assets\inputs.log" -append
  }
}

# Function to autoLoadStates
function script:LoadStatesFromAssets {
  $cp = gl
  $di = "$basedir\assets\states\"
  if (test-path "$di") {
      cd $di
      $files = ls -recurse
      foreach ($statefile in $files) {
          if ($statefile.mode -eq "-a---") {
              $name = ($statefile.name | split-path -leafbase)
              $value = gc "$statefile"
              Set-variable -name "$name" -value $value -scope Script
              #write-host "$name $value $((Get-Variable $name).value)"
          }
      }
  }
  cd $cp
}
LoadStatesFromAssets

# Function to savestates
function script:saveState($variable,$value,$folder,$reset) {
  $cp = gl
  cd $basedir\assets
  if (test-path "states") {} else {
    mkdir states | out-null
  }
  cd states
  if (test-path "$folder") {} else {
    mkdir $folder | out-null
  }
  cd $folder
  if ($reset -eq $true) {
    $value = $false
    del "$variable.state"
  } else {
    set-variable -name $variable -value "$value" -scope Script
    $state = (get-variable -name $variable -scope Script).value
    $state | out-file "$variable.state"
  }
  logCommand -command "[saveState >> Set $variable to $value]" -doFormat
  cd $cp
}
#write-host "[$(get-date)]: Core: Defined some functions." -f yellow
# Function to check latest version
function check-latestversion{
  $script:verctrl_lastver_online = curl -s 'https://raw.githubusercontent.com/simonkalmiclaesson/CrossShell/main/lastver.mt'
  $script:verctrl_lastver_current = gc "$basedir\lastver.mt"
  if ($script:verctrl_lastver_online -ne "") {
    if ($script:verctrl_lastver_current -ne $script:verctrl_lastver_online) {
      $script:verctrl_lastver_matching = $false
    } else {
      $script:verctrl_lastver_matching = $true
    }
  } else {
    $script:verctrl_lastver_matching = "Nan (no-internet)"
  }
  if ($script:debug_versioncheck -eq $true) {
    if ($script:shell_suppress_menu_cls -eq $true) {} else {cls}
    write-host -nonewline "lastver.online: " -f darkgray; write-host -nonewline "$script:verctrl_lastver_online`n" -f green
    write-host -nonewline "lastver.current: " -f darkgray; write-host -nonewline "$script:verctrl_lastver_current`n" -f green
    write-host -nonewline "lastver.matching: " -f darkgray; write-host -nonewline "$script:verctrl_lastver_matching`n" -f green
    $script:shell_suppress_menu_cls = $true
  }
}
check-latestversion
#write-host "[$(get-date)]: Core: Checked for updates" -f yellow
#Function to replace psstyle formatting with placeholders
function script:ReplacePSStyleFormating($p) {
  [string]$s = $p

  # prep parse
  $s = $s.replace("{\n}","{u.000A}")

  # Directory parse
  if ($s -like "*{dir:*") {
    #fix check
    $pat = '{dir:"{dir}"}'
    $pat2 = '{dir:"{dir}␀"}'
    if ($s -like "*$pat*") {
      $s = $s.replace("$pat","$pat2")
    }
    # match for dir element
    [regex]$pattern = '{dir:([^]]+)"}'
    $match = ""
    $pattern.Matches($s) | foreach { $match = $_.value }
    $matchraw = $match
    $matchContent = (($match.TrimStart('\{')).TrimStart('dir:"')).TrimEnd('"}')
    #remove placehold char
    $s = $s.replace("␀","")
    $matchraw = $matchraw.replace("␀","")
    $matchContent = $matchContent.replace("␀","")
    #handle dir element
    if ($script:prefix_dir -eq $true -and $script:prefix_enabled -eq $true) {
      $s = $s.replace("$matchraw","$matchContent")
      $s = $s.replace("{dir}",$script:current_directory)
    } else {
      $s = $s.replace("$matchraw","")
    }
  } elseif ($s -like "*{dir}*") {
    if ($script:prefix_dir -eq $true -and $script:prefix_enabled -eq $true) {
      $s = $s.replace("{dir}",$script:current_directory)
    } else {
      $s = $s.replace("{dir}","")
    }
  }

  #Command parse
  [regex]$pattern = '\[([^]]+)\]'
  $matches = $null
  $pattern.Matches($s) | foreach { [array]$matches += "$_" }
  foreach ($m in $matches) {
    $n = $m.trimstart("[")
    $n = $n.trimend("\]")
    # control match
    $prefixparse_old_erroractionpreference = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    $np = $n.replace('$',"")
    $isVar = get-variable "$np"
    $isCmd = get-command "$n"
    if ("$isVar" -eq "" -and "$isCmd" -eq "") {} else {
      $n = iex($n)
      $s = $s.replace($m,$n) 
    }
    $ErrorActionPreference = $prefixparse_old_erroractionpreference
  }

  #Special key parse
  $s = $s.replace("{user}","$($env:username)")
  $s = $s.replace("{hostname}","$(hostname)")

  #ansi key parse
  $matches = $null
  [regex]$pattern = '\{\\([^}]+)\\\}'
  $pattern.Matches($s) | foreach { [array]$matches += "$_" }
  foreach ($m in $matches) {
    $n = $m.trimstart("\{\\")
    $n = $n.trimend("\\\}")
    $s = $s.replace("$m","`e[$n")
  }

  #General key parse
  $s = $s.replace("{reset}","$($psstyle.reset)")
  $s = $s.replace("{blinkoff}","$($psstyle.BlinkOff)")
  $s = $s.replace("{blink}","$($psstyle.Blink)")
  $s = $s.replace("{boldoff}","$($psstyle.BoldOff)")
  $s = $s.replace("{bold}","$($psstyle.Bold)")
  $s = $s.replace("{hiddenoff}","$($psstyle.HiddenOff)")
  $s = $s.replace("{hidden}","$($psstyle.Hidden)")
  $s = $s.replace("{reverseoff}","$($psstyle.ReverseOff)")
  $s = $s.replace("{reverse}","$($psstyle.Reverse)")
  $s = $s.replace("{italicoff}","$($psstyle.ItalicOff)")
  $s = $s.replace("{italic}","$($psstyle.Italic)")
  $s = $s.replace("{underlineoff}","$($psstyle.UnderlineOff)")
  $s = $s.replace("{underline}","$($psstyle.Underline)")
  $s = $s.replace("{strikethroughoff}","$($psstyle.StrikethroughOff)")
  $s = $s.replace("{strikethrough}","$($psstyle.Strikethrough)")

  $s = $s.replace("{outputrendering}","$($psstyle.OutputRendering)")
  $s = $s.replace("{formataccent}","$($psstyle.Formatting.FormatAccent)")
  $s = $s.replace("{tableheader}","$($psstyle.Formatting.TableHeader)")
  $s = $s.replace("{erroraccent}","$($psstyle.Formatting.ErrorAccent)")
  $s = $s.replace("{error}","$($psstyle.Formatting.Error)")
  $s = $s.replace("{warning}","$($psstyle.Formatting.Warning)")
  $s = $s.replace("{verbose}","$($psstyle.Formatting.Verbose)")
  $s = $s.replace("{debug}","$($psstyle.Formatting.Debug)")
  $s = $s.replace("{p.style}","$($psstyle.Progress.Style)")
  $s = $s.replace("{p.maxwidth}","$($psstyle.Progress.MaxWidth)")
  $s = $s.replace("{p.view}","$($psstyle.Progress.View)")
  $s = $s.replace("{fi.directory}","$($psstyle.FileInfo.Directory)")
  $s = $s.replace("{fi.symboliclink}","$($psstyle.FileInfo.SymbolicLink)")
  $s = $s.replace("{fi.executable}","$($psstyle.FileInfo.Executable)")
  $s = $s.replace("{fi.extension}","$($psstyle.FileInfo.Extension)")

  #unicode key parse
  $matches = $null
  [regex]$pattern = '\{u.([^}]+)\}'
  $pattern.Matches($s) | foreach { [array]$matches += "$_" }
  foreach ($m in $matches) {
    $n = $m.trimstart("\{u.")
    $n = $n.trimend("\}")
    $r = "[char]::ConvertFromUtf32(0x$n)"
    $r = iex($r)
    $s = $s.replace("$m","$r")
  }

  $s = $s.replace("{f.black}","$($psstyle.Foreground.Black)")
  $s = $s.replace("{f.darkgray}","$($psstyle.Foreground.BrightBlack)")
  $s = $s.replace("{f.gray}","$($psstyle.Foreground.White)")
  $s = $s.replace("{f.white}","$($psstyle.Foreground.BrightWhite)")
  $s = $s.replace("{f.darkred}","$($psstyle.Foreground.Red)")
  $s = $s.replace("{f.red}","$($psstyle.Foreground.BrightRed)")
  $s = $s.replace("{f.darkmagenta}","$($psstyle.Foreground.Magenta)")
  $s = $s.replace("{f.magenta}","$($psstyle.Foreground.BrightMagenta)")
  $s = $s.replace("{f.darkblue}","$($psstyle.Foreground.Blue)")
  $s = $s.replace("{f.blue}","$($psstyle.Foreground.BrightBlue)")
  $s = $s.replace("{f.darkcyan}","$($psstyle.Foreground.Cyan)")
  $s = $s.replace("{f.cyan}","$($psstyle.Foreground.BrightCyan)")
  $s = $s.replace("{f.darkgreen}","$($psstyle.Foreground.Green)")
  $s = $s.replace("{f.green}","$($psstyle.Foreground.BrightGreen)")
  $s = $s.replace("{f.darkyellow}","$($psstyle.Foreground.Yellow)")
  $s = $s.replace("{f.yellow}","$($psstyle.Foreground.BrightYellow)")

  $s = $s.replace("{b.black}","$($psstyle.Background.Black)")
  $s = $s.replace("{b.darkgray}","$($psstyle.Background.BrightBlack)")
  $s = $s.replace("{b.gray}","$($psstyle.Background.White)")
  $s = $s.replace("{b.white}","$($psstyle.Background.BrightWhite)")
  $s = $s.replace("{b.darkred}","$($psstyle.Background.Red)")
  $s = $s.replace("{b.red}","$($psstyle.Background.BrightRed)")
  $s = $s.replace("{b.darkmagenta}","$($psstyle.Background.Magenta)")
  $s = $s.replace("{b.magenta}","$($psstyle.Background.BrightMagenta)")
  $s = $s.replace("{b.darkblue}","$($psstyle.Background.Blue)")
  $s = $s.replace("{b.blue}","$($psstyle.Background.BrightBlue)")
  $s = $s.replace("{b.darkcyan}","$($psstyle.Background.Cyan)")
  $s = $s.replace("{b.cyan}","$($psstyle.Background.BrightCyan)")
  $s = $s.replace("{b.darkgreen}","$($psstyle.Background.Green)")
  $s = $s.replace("{b.green}","$($psstyle.Background.BrightGreen)")
  $s = $s.replace("{b.darkyellow}","$($psstyle.Background.Yellow)")
  $s = $s.replace("{b.yellow}","$($psstyle.Background.BrightYellow)")
  $s = $s.replace("{r}","$($psstyle.reset)")
  return $s
}

# Function to write a formatted message
function script:write-message{
  #Usage:   write-message <text-array> <foregroundcolor-array> <backgroundcolor-array>
  #         if <text-array> has more then one item, the function will write them both to one line but with diffrent color options if the color array have more then one item.
  #         obs text.1 gets colored by fcolor.1 and fcolor.2, while text.2 is colored by corresponding places in color arrays.
  #         if no colors are given it will use the $host.ui.rawui colors (may inpact colors on older pwsh versions)
  #
  param([array]$text,[alias("fc")][array]$foregroundcolor,[alias("bc")][array]$backgroundcolor)
  #Single mode
  if ($array.length -eq 1) {
    [string]$string = "$text"
    [string]$fcolor = "$foregroundcolor"
    [string]$bcolor = "$backgroundcolor"
    if ($fcolor -eq "") {$fcolor = $host.ui.rawui.foregroundcolor}
    if ($bcolor -eq "") {$bcolor = $host.ui.rawui.backgroundcolor}
    write-host "$string" -f $fcolor -b $bcolor
  #MultiMode
  } else {
    [int]$counter = 0
    foreach ($t in $text) {
      [string]$string = "$t"
      if ($foregroundcolor.length -gt 1) {
        [string]$fcolor = $foregroundcolor[$counter]
      } else { 
        [string]$fcolor = $foregroundcolor 
      }
      if ($backgroundcolor.length -gt 1) {
        [string]$bcolor = $backgroundcolor[$counter]
      } else {
        [string]$bcolor = $backgroundcolor
      }
      if ($fcolor -eq "") {$fcolor = $host.ui.rawui.foregroundcolor}
      if ($bcolor -eq "") {$bcolor = $host.ui.rawui.backgroundcolor}
      $counter++
      if ($counter -lt $text.length) {
        write-host -nonewline "$string" -f $fcolor -b $bcolor
      } else {
        write-host "$string" -f $fcolor -b $bcolor
      }
    }
  }
}

# Function to load cmdlets
function script:load-cmdlets {
  $script:pathables = $null
  cd $psscriptroot\..\packages\cmdlet
  $files = get-childitem -recurse

  foreach ($file in $files) {
    $fileext = $file | split-path -extension
    $filename = $file | split-path -leafbase
    $filepath = "$file"
    $pathableFile = $false
    if ($fileext -eq ".ps1") {$pathableFile = $true}
    if ($fileext -eq ".bat") {$pathableFile = $true}
    if ($fileext -eq ".exe") {$pathableFile = $true}
    if ($fileext -eq ".pwsh") {$pathableFile = $true}
    if ($fileext -eq ".py") {$pathableFile = $true}
    #check for hidden files
    $filepathO = $filepath.replace("\",'§')
    [array]$filepathA = $filepathO -split '§'
    foreach ($f in $filepathA) {if ($f -like ".*") {$pathableFile = $false}}
    if ($file.mode -ne "-a---") {$pathableFile = $false}
    if ($pathableFile -eq $true) {
      [string]$newline = "$filename § $filepath"
      [array]$script:pathables += "$newline"
    }
  }
  $mapped_cmdlets = gc mapped_cmdlets.list
  foreach ($mcmdlet in $mapped_cmdlets) {
    [string]$newline = "$mcmdlet § $mcmdlet"
    [array]$script:pathables += "$newline"
  }
  $script:pathables = $script:pathables | sort
}

# Function to check/validate input and then run it
function script:CheckAndRun-input {
  param([string]$in,[switch]$return,[switch]$returnFormated,[switch]$noerror)
  $orginput = $in
  $inc = ""
  if ($script:debug_commandparts -eq $true) {write-host -nonewline "recived.alinput: " -f darkgray; write-host "$in" -b darkblue}
  $ch = " | "
  $ch2 = ' & '
  [array]$splitString = $in
  if ($in -like "*$ch*") {[array]$splitString = $in -split " \| "} else {[array]$splitString = $in -split "\|"}
  [array]$script:partials = $null
  foreach ($commando in $splitString) {
    [array]$stringA = $commando -split " "
    [string]$command = $stringA[0]
    [string]$params = $stringA[1..$stringA.length]
    # CommonParameters
    if ($params -eq "/?") {
      $params = "$command"
      $command = "get-help"
    } elseif ($params -eq "-?") {
      $params = "$command"
      $command = "get-help"
    } elseif ($params -eq "/help") {
      $params = "$command"
      $command = "get-help"
    } elseif ($params -eq "/h") {
      $params = "$command"
      $command = "get-help"
    } elseif ($params -eq "/search") {
      $params = "$command"
      $command = "help"
    } elseif ($params -eq "/webi") {
      $params = "$command"
      $command = "webi"
    } elseif ($params -eq "/calc") {
      $params = "$command"
      $command = "calc"
    }
    if ($script:debug_commandparts -eq $true) {write-host -nonewline "recived.command: " -f darkgray; write-host -nonewline "$command" -f green; write-host " $params" -f red}
    foreach ($cmdlet in $script:pathables) {
      [array]$cmdletData = $cmdlet -split " § "
      [string]$cmdletPath = $cmdletData[1]
      [string]$cmdlet = $cmdletData[0]
      $final_cmdletpath = ""
      if ($command -eq $cmdlet) {
        $script:final_cmdletpath = $cmdletPath
        $script:final_params = $params
        # Calculator " fix
        if ($command -eq "calc" -or $command -eq "mcalc") {
          [array]$paramsA = $params -split " "
          [string]$first_param = $paramsA[0]
          if ($first_param -notlike "*-expr*") {
            if ($first_param[0] -ne "-") {
              $paramsA[0] = '"' + $first_param + '"'
            }
          } else {
            $paramsA[0] = '"' + $first_param + '"'
          }
          $params = ""
          foreach ($p in $paramsA) {
            $params += "$p "
          }
          $params = $params.trimend(" ")
          $script:final_params = $params
        }
        # Loop fix
        if ($command -eq "if" -or $command -eq "while" -or $command -eq "eif" -or $command -eq "ewhile") {
          $params = $params -replace '\(','%openParen%'
          $params = $params -replace '\)','%closeParen%'
          $params = $params -replace '{','%openCurly%'
          $params = $params -replace '}','%closeCurly%'
          $params = $params -replace '\$','%dollarSign%'
          $script:final_params = $params
        }
      }
    }
    #$in = $in -replace "$command",". $final_cmdletPath"
    if ("$script:final_cmdletpath" -ne "") {
      if ((split-path "$script:final_cmdletpath" -extension) -eq ".py") {
        [string]$sstring = 'python "' + "$script:final_cmdletpath" + '"'+ " $script:final_params"
        $sstring = $sstring -replace '\\','/'
        [array]$script:partials += $sstring
      } else {
        [array]$script:partials += ". $script:final_cmdletpath $script:final_params"
      }
    }
  }
  if ($script:partials.length -gt "1") {
    foreach ($p in $script:partials) {
      $num = [array]::indexof($script:partials,$p)
      $t = $script:partials[$num]
      $script:partials[$num] = "$t | "
      if ($script:debug_commandparts_final) {write-host -nonewline "parsed.partial: " -f darkgray; write-host "$p" -f green}
    }
    $t2 = $script:partials[-1]
    $script:partials[-1] = "$t2" -replace " \| ",''
  }
  [string]$script:partials_string = $script:partials
  $in = $partials_string
  if ($script:debug_commandparts_final) {write-host -nonewline "parsed.input: " -f darkgray; write-host -nonewline "$in`n" -f green}

  $cmdFound = $false
  foreach ($cmdlet in $script:pathables) {
    [array]$cmdletData = $cmdlet -split " § "
    [string]$cmdlet = $cmdletData[0]
    if ($command -eq $cmdlet) {
      $cmdFound = $true
      $inc = $in
    }
  }
  if ($cmdFound -ne $true) {
    #Cmdlet not found
    if ("$command" -match '[a-zA-Z]') {
      $errString = 'Cmdlet "' + $command + '", not found!'
      if (!$noerror) {
        write-host $errString -f red
      }
      if ($returnFormated) {
        $orginput += " #!!invalidExec"
      }
    #Numeral input
    } else {
      $inc = $command
    }
  }
  if ($inc) {iex($inc)}
  if ($return -or $returnFormated) {return "$orginput"}
}

# Function to split a command and then run it 
function splitCommandAndRun {
  param($command)
  [array]$commandA = $command -split ';'
  foreach ($comm in $commandA) {
    CheckAndRun-input $commandA
  }
}

# Function to force an exit of the shell
function forceExit {
  param([switch]$check,[switch]$set,[switch]$reset)
  $curdir = get-location
  cd "$psscriptroot\..\assets"
  $old_ErrorActionPreference = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue'
  if ($check) {
    if ((test-path "forceexit.state") -eq $true) {cd $script:old_path;exit}
  }
  if ($set) {
    if ((test-path "forceexit.state") -eq $true) {} else {"1" | out-file -file "forceexit.state"}
  }
  if ($reset) {
    if ((test-path "forceexit.state") -eq $true) {rm "forceexit.state" -force}
  }
  $ErrorActionPreference = $old_ErrorActionPreference
  cd $curdir
}

# Function to write/run a profile file
function write-profile {
  param([bool]$hasmorelines)
  if (test-path "$psscriptroot\..\assets\profile.crcmd") {
    [string]$cdm = "script " + '"' + "$psscriptroot\..\assets\profile.crcmd" + '"'
    CheckAndRun-input $cdm
  } elseif (test-path "$psscriptroot\..\assets\profile.ps1") {
    . "$psscriptroot\..\assets\profile.ps1"
  } else {
    if ($script:hostID -ne "pwsh.5l") {
      write-message "OBS! No profile file, please add: ","/assets/profile.ps1" DarkYellow,Cyan
    } else {
      write-message "OBS! No profile file, please add: ","/assets/profile.ps1" Yellow,Cyan
    }
    if ($hasmorelines -ne $true) {
      write-host ""
    }
  }
}

if ($script:hasresetforceExit) {} else {forceExit -reset; $script:hasresetforceExit}

# Function to write a directory prefix
function writeDirPrefix($dirp) {
  [array]$dircolor = $script:prefixdircolor -split ','
  $dir = $dirp
  [array]$dirA = $dir -split "\\"
  [string]$c0 = $dircolor[0]
  [string]$c1 = $dircolor[1]
  if ($c1 -eq "") {$c1 = $c0}
  foreach ($f in $dirA) {
    write-host -nonewline $f -f $c0
    write-host -nonewline "\" -f $c1
  }
}

# Function to write the console header
function write-header($nocls) {
  if ($nocls -eq $true) {} else {cls}
  $hasmorelines = $false
  #Hosts
  if ($script:hostID -eq "pwsh.5l") {
    write-message "Warning! Shell started with powershell 5. This app uses and is coded in powershell 7 so please use that or newer for full functionality. Altought some things may work in powershell 5 no support is given for it. For instructions se: ","https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows" White,Cyan DarkRed
    $hasmorelines = $true
  }
  if ($script:hostID -eq "pwsh.6l") {
    write-message "Warning! Shell started with powershell 6. This app uses and is coded in powershell 7 so please update to that or newer for full functionality. Altought some things may work in powershell 6 no support is given for it. For instructions se: ","https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows" White,Cyan DarkRed
    $hasmorelines = $true
  }
  if ($script:hostID -eq "vscodehost") {
    if ($script:msgcentral_vscodenotice -ne $false) {write-message "OBS! Shell started with vscode, scaling and buffersaves may be broken. ","(To disable this message use: 'msgcentral -disable vscodenotice')" White,DarkGray Darkblue; $hasmorelines = $true}
  }
  if ($script:hostID -eq "unknown") {
    write-message "Warning! Shell started with unknown powershell version and host. Compatability and featureset is not garanteed. Please use powershell 7." White DarkYellow
    $hasmorelines = $true
  }
  #Version
  if ($script:msgcentral_nonReleaseChannel -ne "Release" -and $script:msgcentral_nonReleaseChannel -ne "Stable") {
    if ($script:crosshell_versionChannel -eq "Development") {
        write-message "You are running a development version of crosshell, bugs may occure and some features migth be missing." DarkRed
    } elseif ($script:crosshell_versionChannel -eq "Alpha") {
        write-message "You are running a alpha version of crosshell, bugs may occure and some features migth be missing." DarkYellow
    } elseif ($script:crosshell_versionChannel -eq "Beta") {
        write-message "You are running a beta version of crosshell, although these are stabler then alpha versions buggs may still occure." DarkYellow
    } elseif ($script:crosshell_versionChannel -eq "Viva") {
        write-message "You are running the current version of Crosshell-VIVA, these are generally stable but may contain bugs." DarkYellow
    } else {
        write-message "The version channel of your crosshell installation is not reconized, this may be a bug" DarkRed
    }
    $hasmorelines = $true
  }
  if ($script:Shell_NetworkAvaliable -eq $false) {
    write-message "Crosshell could't not found a valid internet connection on host. Some network specific features might not work." White DarkYellow
    $hasmorelines = $true
  } else {
    if ($script:verctrl_lastver_matching -eq $false) {
      if ($script:msgcentral_notlatestversion -ne $false) {
        #echo "`e[5;31mYou are not running the latest version, consider git cloning...`e[0m"
        echo "`e[5;31mYou are not running the latest version, to update run 'update' or to also update al packages run 'update -p'`e[0m"
        #write-message "You are not running the latest version, consider git cloning..." darkred
        $hasmorelines = $true
      }
    }
  }
  #Devmode
  $devmode = verify_Devmode
  if ($devmode) {
    write-message "Shell started in development mode. Please only use this mode if needed. (moreinfo: 'webi devmode')" DarkRed
    $hasmorelines = $true
  }
  $devmode = $null
  write-profile -hasmorelines $hasmorelines
  if ($hasmorelines -eq "$true") {write-host ""}

  # Welcomme message
  # Check guide message
  if (test-path "$script:basedir\assets\HasShownGuide.empty") {
    if ($script:msgcentral_nocolorhello) {
        write-message "Welcome, write 'help' for help. To add messages to here edit: /assets/profile.ps1" gray
    } else {
        write-message "Welcome, write 'help' for help. To add messages to here edit: /assets/profile.ps1" green
    }
  } else {
    if ($script:msgcentral_nocolorhello) {
        write-message "Welcome, for a guide on how to use crosshell write 'guide' or for command help write 'help'." gray
    } else {
        write-message "Welcome, for a guide on how to use crosshell write 'guide' or for command help write 'help'." green
    }
    "" | Out-File "$script:basedir\assets\HasShownGuide.empty"
  }
}
#write-host "[$(get-date)]: Core: Loaded the rest of the functions" -f yellow
##shell
. "$psscriptroot\shell.ps1"