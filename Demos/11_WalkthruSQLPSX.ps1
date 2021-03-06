#Import the SQLPSX Module for SQLServer
Import-Module SQLServer

$Server = "SQL2008R2"
#List Databases
Get-SqlDatabase $Server | select Name, Status, Size, SpaceAvailable, RecoveryModel, CreateDate, LastBackupDate, LastLogBackupDate

#List Database Users
Get-SqlDatabase $Server | Get-SqlUser | select Name, Login, CreateDate

