#http://social.technet.microsoft.com/Forums/en-US/winserverpowershell/thread/71509e2a-ee6d-457b-83ca-dd23f8243470/
netstat -an |
    ForEach-Object {
       $i = $_ | Select-Object -Property Protocol , Source , Destination , Mode
       $null, $i.Protocol, $i.Source, $i.Destination, $i.Mode =
               ($_ -split '\s{2,}')
       if ($i.Protocol.length -eq 3) { $i }
    }