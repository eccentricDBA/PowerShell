# Load the SQL Server Management Objects
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

#Connect to SQL Server and Create Server Object
$SQLInstance = "SQL2008R2"
$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $SQLInstance  

#Connect and Show Connection String
($srv.ConnectionContext.ConnectionString)

#Enum the Connection Context
($srv.ConnectionContext)

#Quick List from the Server Object
Write-Host "Quick Inventory"
Write-Host "Edition: "$srv.Edition
Write-Host "Product Level: "$srv.ProductLevel
Write-Host "Version: "$srv.Version
Write-Host "Engine Edition: "$srv.EngineEdition
Write-Host "Login Mode: "$srv.LoginMode
Write-Host "Service Account: "$srv.ServiceAccount
Write-Host "Audit Level: "$srv.AuditLevel
Write-Host "Default File: "$srv.DefaultFile
Write-Host "Default Log: "$srv.DefaultLog
Write-Host "Backup Directory: "$srv.BackupDirectory
Write-Host "Error Log Path: "$srv.ErrorLogPath

#List Server Object Properties
$srv | Get-Member

#List SQLAgent Jobs
$srv.JobServer.Jobs | select Category, Name, IsEnabled, CurrentRunStatus,CurrentRunStep,LastRunOutcome, LastRunDate, NextRunScheduleID, NextRunDate, EventLogLevel | Out-GridView

#Retrieve a List of Filtered Jobs
$srv.JobServer.Jobs |`
    Select Category, Name, IsEnabled, CurrentRunStatus,CurrentRunStep,LastRunOutcome, LastRunDate, NextRunScheduleID, NextRunDate, EventLogLevel |`
    Where-Object {$_.IsEnabled -eq $FALSE `
                    -or (!$_.CurrentRunStatus -eq $FALSE -and $_.CurrentRunStatus.ToString() -ne 'Idle') `
                    -or ($_.IsEnabled -eq $TRUE -and $_.NextRunScheduleID -eq 0)}  |`
    Sort Category, Name | Format-Table

#List Database
foreach($Database in $srv.Databases){
    Write-Host "Name: "$Database.Name
    Write-Host "Status: "$Database.Status
    Write-Host "Size: "$Database.Size
    Write-Host "Space Available: "$Database.SpaceAvailable
    Write-Host "Recovery Model: "$Database.RecoveryModel
    Write-Host "Create Date: "$Database.CreateDate
    Write-Host "Last Backup Date: "$Database.LastBackupDate
    if ( $Database.RecoveryModel -eq 'Full'){
        Write-Host "Last Log Backup Date: "$Database.LastLogBackupDate
    }
    Write-Host
}

#Show Database Object
$srv.Databases | Get-Member

#Disconnect and dispose the server object.
$srv.ConnectionContext.Disconnect();
