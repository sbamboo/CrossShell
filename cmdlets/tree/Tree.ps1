#Load
. $psscriptroot\.assets\Show-Tree.ps1
. $psscriptroot\.assets\Tree_legacyFormat.ps1
. $psscriptroot\.assets\Tree_Char2_Addon.ps1


$c = "Show-Tree $args"
iex($c)