CLS
$xl = New-Object -COM "Excel.Application"
$xl.Visible = $true
$wb = $xl.Workbooks.Open("example.xlsx")
$ws = $wb.Sheets.Item(1)
$rowCount = ($ws.UsedRange.Rows).count
$ColumnsCount = ($ws.UsedRange.Columns).count
$Cells = New-Object 'object[,]' $rowCount,$ColumnsCount

#Looking up a value in one column and assigning the corresponding value from another column to a variable could be done like this:
for ($i = 1; $i -le $rowCount; $i++) {
  for ($j = 1; $j -le $ColumnsCount; $j++){
    $Cells[($i-1),($j-1)] = $ws.Cells.Item($i,$j).Value2 
  }
}

#Don't forget to clean up after you're done:
$wb.Close()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl)

$Cells[237,6] | Format-Table
