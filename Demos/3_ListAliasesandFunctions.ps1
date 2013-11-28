#Aliases
Get-Command | Where-Object {$_.CommandType -eq 'Alias'} | Sort-Object Name

#Functions
Get-Command | Where-Object {$_.CommandType -eq 'Function'} | Sort-Object Name