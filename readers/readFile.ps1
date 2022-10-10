param($file,$cmd,$reader,[switch]$test)

$pwshpath = "pwsh"

#read config
$configRaw = get-content "$psscriptroot\installs.config"

if ($test) {
  .\readFile.ps1 ".\.tests\test.bat" | iex
  .\readFile.ps1 ".\.tests\test.js" | iex
  .\readFile.ps1 ".\.tests\test.ps1" | iex
  .\readFile.ps1 ".\.tests\test.py" | iex
  .\readFile.ps1 ".\.tests\test.sh" | iex
} else {
  if ($file) {
    $fileext = split-path $file -extension
    if ($fileext -eq ".py") {$readerp = "$psscriptroot\python\python.exe"}
    if ($fileext -eq ".sh") {$readerp = "$psscriptroot\gitbash_extracted_bash\usr\bin\bash.exe"}
    if ($fileext -eq ".bat") {$readerp = "cmd.exe /c "}
    if ($fileext -eq ".js") {$readerp = "$psscriptroot\nodejs\node.exe"}
    if ($fileext -eq ".ps1") {$readerp = "$pwshpath"}
    if ($fileext -eq ".pwsh") {$readerp = "$pwshpath"}
    if ($reader) {$readerp = $reader}
    [string]$cmdo = "$readerp $file"
    return $cmdo
  } elseif ($cmd) {
    if ($reader -ne "node") {
      if ($reader -eq "python") {$readerp = "$psscriptroot\python\python.exe -c"}
      if ($reader -eq "bash") {$readerp = "$psscriptroot\gitbash_extracted_bash\usr\bin\bash.exe"}
      if ($reader -eq "cmd") {$readerp = "cmd.exe /c"}
      if ($reader -eq "pwsh") {$readerp = "$pwshpath -c"}
      if ($reader -eq "python") {[string]$cmdo = "$readerp " + '"' + "$cmd" + '"'} else {[string]$cmdo = "$readerp $cmd"}
      #write-host "$cmdo"
      return $cmdo
    } else {
      $f = "$psscriptroot\tmp.nodecommand.js"
      if ($reader -eq "node") {$readerp = "$psscriptroot\nodejs\node.exe"}
      $cmd | out-file $f
      [string]$cmdo = "$readerp $f"
      return $cmdo
    }
  }
}