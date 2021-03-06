#--------------------------------------------------------------------------------------------------
# Service Check
#--------------------------------------------------------------------------------------------------
$Server = "SQL2012"

try
{
  Get-WmiObject -computer $Server -Class Win32_Service `
  | Where-Object { $_.StartMode -eq 'Auto' `
                    -and ($_.State -ne 'Running' -or $_.Status -ne 'OK') }`
  | Select Name, StartMode, State, Status | Sort Name        
}
catch            
{
  Write-Host 'Unable to review services for ' + $Server + '.'
}
#--------------------------------------------------------------------------------------------------

