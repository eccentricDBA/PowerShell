function Run-SQLQuery ($SqlServer, $SqlDatabase, $SqlQuery)
{
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server =" + $SqlServer + "; Database =" + $SqlDatabase + "; Integrated Security = True"
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $SqlQuery
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close()
    $DataSet.Tables[0]
}

#Check for execute acess to xp_regread
Run-SQLQuery -SqlServer "SQL2008R2" -SqlDatabase "master" `
-SqlQuery "exec sp_helprotect @username='public'" `
| Where-Object {$_.Action -eq 'Execute' -and $_.Owner -eq 'sys' -and $_.Object -eq 'xp_regread'}