#--------------------------------------------------------------------------------------------------
#Connection Test Exception
#http://blog.powershell.no/2011/10/23/test-connection-error-handling-gotcha-in-powershell-2-0/
#--------------------------------------------------------------------------------------------------
#$Server = "."
$Server = "SQL2012"
try
{
  $ConnTestInfo = Test-Connection -ComputerName $Server -Count 1 -ErrorAction stop
  $ServerExists = $True
}            
catch [System.Management.Automation.ActionPreferenceStopException]
{
  try
  {
    throw $_.exception
  }            
  catch [System.Net.NetworkInformation.PingException]
  {
    $ConnException ="Catched PingException"
    $ServerExists = $False
  }            
  catch
  {
    $ConnException ="General catch"
    $ServerExists = $False
  }
}
if ($ServerExists)
{
    Write-Host "Server Found"
}
else
{
    Write-Host "Unable to Connect"
    Write-Host $ConnException
}
#--------------------------------------------------------------------------------------------------
