write-host "Parsing... `n" -f darkyellow

if (get-module PSExcel) {} else {Install-module PSExcel}
import-module psexcel -force

if ($file) {} else {$script:mathplan_file = "$psscriptroot\Planering M1 2022_nov-dec.xlsx"}
$script:mathplan_file = "$psscriptroot\Planering M1 2022_nov-dec2.xlsx"

$data = import-xlsx $script:mathplan_file

#print
$json = ConvertTo-Json $data
$json = $json -replace "null",'"§null§"'
$json | out-file "migi_preparsed.json"