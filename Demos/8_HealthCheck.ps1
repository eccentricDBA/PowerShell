#=====================================================
$smtpServer = 'mail.example.local'
$emailFrom = 'monitoring@example.com'
$emailTo = 'dba.pager@example.com'
$subject = 'Server Health Check'
#=====================================================

$Servers = Get-Content "C:\Presentations\SQLSaturday\204\Demos\configs\ServerList.txt"
$ServerExists = $False
$ConnException = ""

$EmailBody = '<html><head><title>Security Software Review</title></head>'
$EmailBody = $EmailBody + '<style>
table {
	font-family : Verdana, sans-serif;
	font-size: 11px;
	}
th {
	background-color: #6699CC;
	color: #FFFFFF;
	font-family : Verdana, sans-serif;
	font-size: 11px;
	}
td {
	font-family : Verdana, sans-serif;
	font-size: 11px;
	}
</style>'
$EmailBody = $EmailBody + '<body>'
ForEach($Server in $Servers)
{
    $ServerExists = $True
    #--------------------------------------------------------------------------------------------------
    #Connection Test Exception
    #http://blog.powershell.no/2011/10/23/test-connection-error-handling-gotcha-in-powershell-2-0/
    #--------------------------------------------------------------------------------------------------
    try
    {
        Write-Host "Testing Connection to $Server"
        $ConnTestInfo = Test-Connection -ComputerName $Server -Count 1 -ErrorAction stop
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
    #--------------------------------------------------------------------------------------------------
    
    if($ServerExists)
    {
        try
        {
            Write-Host "Checking Services for $Server"
            $Services = Get-WmiObject -computer $Server -Class Win32_Service `
            | Where-Object { $_.StartMode -eq 'Auto' -and ($_.State -ne 'Running' -or $_.Status -ne 'OK') -and !($_.Name -eq 'ShellHWDetection' -or $_.Name -eq 'sppsvc' -or $_.Name -eq 'SmcService' -or $_.Name -eq 'SysmonLog' -or $_.Name -like 'clr_optimization*')} `
            | Select Name, StartMode, State, Status | Sort Name        
        }
        catch            
        {
            $EmailBody = $EmailBody + '<h3>Unable to review services for ' + $Server + '.</h3>'
        }
        
        if ($Services.Count -gt 1)
        {
            $EmailBody = $EmailBody + '<h3>' + $Server + ' ' + $ConnTestInfo.ipv4address.ipaddressToString + ' service check:' + '</h3>'
            $EmailBody = $EmailBody + '<table>'
            $EmailBody = $EmailBody + '<tr><th>Name</th><th>StartMode</th><th>State</th><th>Status</th></tr>'
            ForEach($Service in $Services)
            {
                $EmailBody = $EmailBody + '<tr><td>' + $Service.Name + '</td><td>' + $Service.StartMode +  '</td><td>' + $Service.State + '</td><td>' + $Service.Status + '</td></tR>'
            }
            $EmailBody = $EmailBody + '</table>'
        }            
    }
    else
    {
        $EmailBody = $EmailBody + "<h3>$Server Does not Exists. $ConnException</h3>"
    }
}

if ($smtpServer -ne 'mail.example.local')
{
    #Used to Send Email
    $email = New-Object System.Net.Mail.MailMessage 
    $email.From = $emailFrom
    $email.IsBodyHtml =$True
    $email.To.Add($emailTo)
    $email.Subject = $subject
    $email.Body = $EmailBody
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)
    $smtp.Send($email)
}
else
{
    #Write the results to a temp file
    Set-Content -path "$env:temp\HealthCheck.html" -value $EmailBody
    ."$env:temp\HealthCheck.html"
}