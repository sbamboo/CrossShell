<#
  .SYNOPSIS
  Cmdlet to view information about a host.
#>

# prep
    #pathables
    foreach ($p in $pathables) {
        $name = ($p -split " § ")[0]
        [string]$parsed_pathables += "$name;"
    }
    [string]$parsed_pathables = $parsed_pathables.trimend(';')
    #packages
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
    foreach ($p in $match_Packs) {
        if ($p -ne "") {
            $p = split-path $p -Leaf
            [string]$installedPackages += "$p;"
        }
    }
    [string]$installedPackages = $installedPackages.trimend(';')
    #devmode
    $shellinfdevmode = verify_Devmode

# Info block
$info = @"
Name:            Crosshell
VersionID:       $script:crosshell_versionID
Devmode:         $shellinfdevmode

AllowMultiLine:  $script:shell_opt_multiline
BaseDir:         "$script:basedir"
OldPath:         "$script:old_path"

StartDir:        "$script:startdir"
PrintComments:   $script:shell_param_printcomments
NoExit:          $script:shell_param_noexit
ScriptFile:      "$script:shell_param_scriptfile"
SuppressMenuCls: $script:shell_suppress_menu_cls
AutoClearMode:   $script:crosshell_autoclearmode

Host_VerMajor:   $script:inthostVersionMajor
Host_Hostname:   $script:inthostName
HostnameID:      $script:hostNameID
HostId:          $script:hostID

WindowTitle:     $script:shell_opt_windowtitle_current
hostWindowTitle: $old_windowtitle
OriginalTitle:   $script:shell_opt_windowtitle_original
LastTitle:       $script:shell_opt_windowtitle_last

CurrentDir:      "$script:current_directory"

DefaultPrefix:   $script:default_prefix
CurrentPrefix:   $script:prefix
PrefixEnabled:   $script:prefix_enabled
ShowDirectory:   $script:prefix_dir
RenderedPrefix:  "$(ReplacePSStyleFormating($prefix))"
PrefixColor:     $script:prefixcolor
PrefixDirColor:  $script:prefixdircolor

Pathables:       "$parsed_pathables"

InstalledPackages: "$installedPackages"

"@

return $info