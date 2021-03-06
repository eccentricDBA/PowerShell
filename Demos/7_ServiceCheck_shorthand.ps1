#--------------------------------------------------------------------------------------------------
# Service Check using Aliases
#--------------------------------------------------------------------------------------------------
$Server = "."

try
{
  gwmi -computer $Server -Class Win32_Service |`
  select Name, StartMode, State, Status |`
  where { $_.StartMode -eq 'Auto' -and ($_.State -ne 'Running' -or $_.Status -ne 'OK') } |`
  sort Name        
}
catch            
{
  Write-Host 'Unable to review services for ' + $Server + '.'
}
#--------------------------------------------------------------------------------------------------

