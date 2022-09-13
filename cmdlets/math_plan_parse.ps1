param([int]$week,[string]$file)

Install-module PSExcel
import-module psexcel -force

#$week = 37
#$file = "C:\users\$env:Username\downloads\Planering M1 HT22.xlsx"

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
    [array]$days += $object."<Column 2>"
    [array]$desc += $object."<Column 3>"
    [array]$page += $object."<Column 4>"
    [array]$upst += $object."<Column 5>"
    [array]$upec += $object."<Column 6>"
    [array]$upca += $object."<Column 7>"
    [array]$e__1 += $object."<Column 8>"
    [array]$e__2 += $object."<Column 9>"
    [array]$e__3 += $object."<Column 10>"
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

foreach ($property in $weekdata.GetEnumerator()) {
    $l = ":"
    $len = ($property.name).length
    $cl = $c - $len
    if ($len -lt $c) {$l += " "*$cl}
    write-host -NoNewline $property.name -f darkBlue
    write-host -NoNewline "$l  " -f darkBlue
    write-host $property.value -f darkgreen
}