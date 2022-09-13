param([int]$week,[string]$file)

if (get-module PSExcel) {} else {Install-module PSExcel}
import-module psexcel -force

$week = 37
$file = "C:\users\$env:Username\downloads\Planering M1 HT22.xlsx"

function indexof {param([array]$array,[string]$term); $c = 0; foreach ($i in $array) {if ($i -eq "$term") {return $c}; $c++}}

$data = import-xlsx $file
cls

$index = indexof $data."TE1 Matematik 1c" $week

[array]$tmp = $null

$tmp += $data[$index + 0]
$tmp += $data[$index + 1]
$tmp += $data[$index + 2]
$tmp += $data[$index + 3]
$tmp += $data[$index + 4]

$script:weekdatavis = $tmp | format-table
$weekdataup = $tmp

$days = $null
$desc = $null
$page = $null
$upst = $null
$upec = $null
$upca = $null
$e__1 = $null
$e__2 = $null
$e__3 = $null

foreach ($object in $weekdataup) {
    if ($object."<Column 2>") {[array]$days += $object."<Column 2>"} else {[array]$days += "§null§"}
    if ($object."<Column 3>") {[array]$desc += $object."<Column 3>"} else {[array]$desc += "§null§"}
    if ($object."<Column 4>") {[array]$page += $object."<Column 4>"} else {[array]$page += "§null§"}
    if ($object."<Column 5>") {[array]$upst += $object."<Column 5>"} else {[array]$upst += "§null§"}
    if ($object."<Column 6>") {[array]$upec += $object."<Column 6>"} else {[array]$upec += "§null§"}
    if ($object."<Column 7>") {[array]$upca += $object."<Column 7>"} else {[array]$upca += "§null§"}
    if ($object."<Column 8>") {[array]$e__1 += $object."<Column 8>"} else {[array]$e__1 += "§null§"}
    if ($object."<Column 9>") {[array]$e__2 += $object."<Column 9>"} else {[array]$e__2 += "§null§"}
    if ($object."<Column 10>") {[array]$e__3 += $object."<Column 10>"} else {[array]$e__3 += "§null§"}
}

[PSCustomObject]$script:weekdata = @{
    "week" = $week
    "days" = $days
    "lession_desc" = $desc
    "book_page" = $page
    "upg_st" = $upst
    "upg_ec" = $upec
    "upg_ca" = $upca
    "ex_1" = $e__1
    "ex_2" = $e__2
    "ex_3" = $e__3
}

[int]$c = "lession_desc:".length

# foreach ($property in $weekdata.GetEnumerator()) {
#     $l = ":"
#     $len = ($property.name).length
#     $cl = $c - $len
#     if ($len -lt $c) {$l += " "*$cl}
#     write-host -NoNewline $property.name -f darkBlue
#     write-host -NoNewline "$l  " -f darkBlue
#     write-host $property.value -f darkgreen
# }

$upg_stArray = $null
foreach ($upgst in $weekdata.upg_st) {
  $upg_stArray += $upgst
}

function GetLongest {
  param([array]$array)
  [int]$longest = 0
  foreach ($c in $array) {
    if ([int]$longest -lt $c.length) {[int]$longest = $c.length}
  }
  return [int]$longest
}
[int]$longestUPG = GetLongest($upg_stArray)



foreach ($day in $weekdata.days) {
  [int]$i = [array]::IndexOf($weekdata.days,$day)
  write-host -nonewline $weekdata.week -f darkgreen
  write-host -nonewline ": " -f darkgreen
  write-host "$day" -f blue
  write-host "================" -f green
  write-host $weekdata.lession_desc[$i]
  write-host $weekdata.book_page[$i]
  write-host $weekdata.upg_st[$i]
  write-host $weekdata.upg_ec[$i]
  write-host $weekdata.upg_ca[$i]
  write-host $weekdata.ex_1[$i]
  write-host $weekdata.ex_2[$i]
  write-host $weekdata.ex_3[$i]
  write-host ""
}

