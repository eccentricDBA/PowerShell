#http://blogs.technet.com/b/heyscriptingguy/archive/2013/03/10/weekend-scripter-playing-around-with-powershell-modules.aspx
Get-Module |`
select name, @{LABEL='cmdletCount';EXPRESSION={[int]$_.exportedcommands.count}} |`
sort cmdletcount -Descending |`
Out-GridView

