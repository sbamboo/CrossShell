<#
  .Synopsis
#>
if (!$script:shell_Devmode) {
	$IsDevMode = $false
} elseif ($script:shell_Devmode -eq "") {
	$IsDevMode = $false
} elseif ($script:shell_Devmode -eq $false) {
	$IsDevMode = $false
} else {
	$IsDevMode = $true
}

return $IsDevMode
