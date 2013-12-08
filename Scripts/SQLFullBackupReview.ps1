#SQLFullBackupReview.ps1
#Carlton B Ramsey (eccentricDBA@outlook.com)
#December 8th, 2013

CLS
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

# Function to turn the Duration from EnumHistory() bigint into useable time value
Function Convert-Duration {
                param ([int]$sec)                            
    #From: http://sqlblog.com/blogs/allen_white/archive/2012/02/17/handle-duration-results-from-enumhistory-in-powershell.aspx
    #Now break it down into its pieces     
    if ($sec -gt 9999) {$hh = [int][Math]::Truncate($sec/10000); $sec = $sec - ($hh*10000)}
        else {$hh = 0}            
    if ($sec -gt 99) {$mm = [int][Math]::Truncate($sec/100);$sec = $sec - ($mm*100)}
        else {$mm = 0}
    #Format and return the time value
    $dur = ("{0:D2}" -f $hh) + ':' + "{0:D2}" -f $mm + ':' + "{0:D2}" -f $sec    
    $dur
} 

Function Get-FullBackupHistory{
    param ([String]$ServerName)                               
    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ServerName 
    $jhf = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobHistoryFilter

    $30days = new-timespan -days 90

    $jobs = $srv.JobServer.Jobs | where {$_.Name -match 'full' -and $_.Name -match 'backup'}
    #$jobs | select Name, LastRunDate, LastRunOutcome, NextRunDate  | FT;

    ForEach($job in $jobs)
    {
        #Need to look how to use filter.
        $jhf.StartRunDate = (Get-Date) - $30days
        $jhf.EndRunDate = (Get-Date)
        $jobHistory = $job.EnumHistory($jhf)
        $FullBackupHistory = $jobHistory | select Server,JobName, StepName, StepID, RunStatus, RunDate, @{Name="RunDuration"; Expression = {Convert-Duration $_.RunDuration}} | where {$_.StepID -eq 0}
    }
    $FullBackupHistory
}

[xml]$SQLInstances = Get-Content c:\work\smo\config\ServerList.xml

$FullBackupHistory = @()

ForEach($SQLInstance in $SQLInstances.ServerList.Server)
{
    $FullBackupHistory += Get-FullBackupHistory $SQLInstance.Name
}   
$FullBackupHistory | Export-Csv C:\work\smo\FullBackupReview.csv –NoTypeInformation