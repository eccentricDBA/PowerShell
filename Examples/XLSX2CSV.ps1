$xls = "example.xlsx"
$csv = "example.csv"

if(Test-Path $csv){Remove-Item $csv}

$excel = new-object -ComObject "Excel.Application"
$excel.DisplayAlerts=$True
$excel.Visible =$True
$wb = $excel.Workbooks.Open($xls)
#Select the correct tab
$ws = $wb.Sheets.Item(2)
$ws.Activate()
$wb.SaveAs($csv, 6)# 6 -> csv
$wb.Close($True)
$excel.Quit()
[void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
