#Power of the pipeline
Get-Command | Where-Object {$_.CommandType -eq 'Cmdlet' -and $_.Name -like 'Get-*'} | Sort-Object Name
