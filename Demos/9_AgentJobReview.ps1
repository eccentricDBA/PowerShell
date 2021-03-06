#Need to review it's not picking up the disabled schedule.
#=====================================================
$smtpServer = 'mail.example.local'
$emailFrom = 'monitoring@example.com'
$emailTo = 'dba.pager@example.com'
$subject = 'SQL Agent Review'
#=====================================================

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$html = '<html><head><title>SQL Agent Review</title></head>'
$html = $html + '<style>
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
$html = $html + '<body><table>'
$html = $html + '<tr><th>Instance Name</th><th>Job Category</th><th>Job Name</th><th>IsEnabled</th><th>CurrentRunStatus</th><th>CurrentRunStep</th><th>LastRunOutcome</th><th>LastRunDate</th><th>NextRunDate</th><th>EventLogLevel</th></tr>'

[xml]$SQLInstances = Get-Content "C:\Presentations\SQLSaturday\204\Demos\configs\ServerList.xml" 
ForEach($SQLInstance in $SQLInstances.ServerList.Server)
{ 
#===== Server List Start
	$ServerName = $SQLInstance.Name
	'Checking ' + $ServerName + '...'
	$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ServerName  

	if ($srv.Edition -notlike 'Express*')
	{
        'Server Edition: ' + $srv.Edition
		#==== Start Job Review
		$jobs = $srv.JobServer.Jobs |`
             Where-Object {$_.IsEnabled -eq $FALSE `
                            -or (!$_.CurrentRunStatus -eq $FALSE -and $_.CurrentRunStatus.ToString() -ne 'Idle') `
                            -or ($_.IsEnabled -eq $TRUE -and $_.NextRunScheduleID -eq 0)}  `
             | Select Category, Name, IsEnabled, CurrentRunStatus,CurrentRunStep,LastRunOutcome, LastRunDate, NextRunDate, EventLogLevel `
             | 		Sort Category, Name 

		ForEach($job in $jobs)
		{
            'Job Name:' + $job.name
            'Job Category: ' + $job.Category
			if($job.name -and $job.Category -ne 'Report Server' -and $job.Category -ne 'Manual Process')
			{
			#=======================Start
		    
			$html = $html + '<tr>'
			$html = $html +  '<td>' 
			$html = $html + $srv.Name + '(' + $ServerName + ')'
			$html = $html + '</td>' 
			$html = $html +  '<td>' 
			$html = $html + $job.Category
			$html = $html + '</td>' 
			$html = $html +  '<td>' 
			$html = $html + $job.Name
			$html = $html + '</td>' 
			if ($job.IsEnabled -eq $FALSE) 
			{ 
				$html = $html +  '<td bgcolor="#FF0000">False</td>'
			} 
			else
			{
				$html = $html +  '<td>True</td>'
			}
			if (!$job.CurrentRunStatus -or $job.CurrentRunStatus.ToString() -ne 'Idle') 
			{ 
				$html = $html +  '<td bgcolor="#FF0000">'
			} 
			else
			{
				$html = $html +  '<td>'
			}
			$html = $html + $job.CurrentRunStatus
			$html = $html + '</td>'
			$html = $html +  '<td>'
			$html = $html + $job.CurrentRunStep
			$html = $html + '</td>'
			if ($job.LastRunOutcome -ne 'Succeeded') 
			{ 
				$html = $html +  '<td bgcolor="#FF0000">'
			} 
			else
			{
				$html = $html +  '<td>'
			}
			$html = $html + $job.LastRunOutcome
			$html = $html + '</td>'
			$html = $html +  '<td>'
			$html = $html + $job.LastRunDate
			$html = $html + '</td>'
			if ($job.NextRunDate -eq '01/01/0001 00:00:00') 
			{ 
				$html = $html +  '<td bgcolor="#FF0000">'
			} 
			else
			{
				$html = $html +  '<td>'
			}
			$html = $html + $job.NextRunDate
			$html = $html + '</td>'
			if ($job.EventLogLevel -ne 'OnFailure') 
			{ 
				$html = $html +  '<td bgcolor="#FF0000">'
			} 
			else
			{
				$html = $html +  '<td>'
			}
			$html = $html + $job.EventLogLevel
			$html = $html + '</td>'
			$html = $html + '</tr>'
			#=======================End
			}    
		# End Job Loop
        }
	#==== End Job Review
	}
#===== Server List End
}

$html = $html + '</table>'
$html = $html + '</body></html>'

if ($smtpServer -ne 'mail.example.local')
{
    $email = New-Object System.Net.Mail.MailMessage 
    $email.From = $emailFrom
    $email.To.Add($emailTo)
    $email.Subject = $subject
    $email.IsBodyHtml =$True
    $email.Body = $html
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)
    $smtp.Send($email)
}
else
{
    # create the file
    $filename = $env:temp + '\SQLAlertReview.html'
    $html | Out-File -Force -encoding ASCII $filename
    .$filename
}