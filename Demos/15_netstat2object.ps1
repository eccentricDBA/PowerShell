#http://social.technet.microsoft.com/Forums/en-US/winserverpowershell/thread/71509e2a-ee6d-457b-83ca-dd23f8243470/
$NetStat2Obj = netstat -an |
    ForEach-Object {
       $i = $_ | Select-Object -Property Protocol , Source , Destination , Mode
       $null, $i.Protocol, $i.Source, $i.Destination, $i.Mode =
               ($_ -split '\s{2,}')
       if ($i.Protocol.length -eq 3) { $i }
    } 
    
#Dislay LISTENING
$NetStat2Obj | Where-Object { $_.Mode -eq 'LISTENING'}

#Display ESTABLISHED
$NetStat2Obj | Where-Object { $_.Mode -eq 'ESTABLISHED'}

#Display UDP Connections
$NetStat2Obj | Where-Object { $_.Protocol -eq 'UDP'}
