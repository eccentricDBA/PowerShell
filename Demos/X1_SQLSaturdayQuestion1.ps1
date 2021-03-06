#Scripts for eccentircDBA blog post Collecting System Information with PowerShell, 

#http://msdn.microsoft.com/en-us/library/windows/desktop/aa394239%28v=vs.85%29.aspx
cls
#Show Total Memory and Free Memory
$strComputer = "."
Get-WmiObject -computername $strComputer `
              -namespace "root\CIMV2" `
              -class "Win32_OperatingSystem" |`
Select-Object @{Name="Total Memory(MB)";Expression={"{0:N1}" -f($_.TotalVisibleMemorySize/1kb)}} `
              ,@{Name="Free Memory(MB)";Expression={"{0:N1}" -f($_.FreePhysicalMemory/1kb)}} 

#http://technet.microsoft.com/en-us/library/hh849685.aspx
cls
#Show CPU Utilization
$strComputer = "."
$ProcessorTimeStats = Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 5 |`
Select-Object -ExpandProperty countersamples |`
Select-Object -ExpandProperty cookedvalue |`
Measure-Object -Average
$ProcessorTimeStats.Average

<#
    http://msdn.microsoft.com/en-us/library/windows/desktop/aa394173%28v=vs.85%29.aspx
    DriveType: Numeric value that corresponds to the type of disk drive this logical disk represents.
    Value	Meaning
    0       Unknown
    1       No Root Directory
    2       Removable Disk
    3       Local Disk
    4       Network Drive
    5       Compact Disc
    6       RAM Disk
#>
cls
$strComputer = "."
#Show Mapped Drive
get-wmiobject -computername $strComputer `
              -namespace "root\CIMV2" `
              -class "Win32_LogicalDisk" `
              -filter "DriveType = 4" |`
Select-Object @{Name="Drive Letter:";Expression={"{0:N1}" -f($_.DeviceID)}}`
              ,@{Name="Network Path:";Expression={"{0:N1}" -f($_.ProviderName)}}

cls
$strComputer = "."
#Show Drive Size and Free Sapce
get-wmiobject -computername $strComputer `
              -namespace "root\CIMV2" `
              -class "Win32_LogicalDisk" `
              -filter "DriveType = 3" |`
Select-Object @{Name="Drive Letter:";Expression={"{0:N1}" -f($_.DeviceID)}} `
              ,@{Name="size(GB)";Expression={"{0:N1}" -f($_.size/1gb)}}`
              ,@{Name="freespace GB)";Expression={"{0:N1}" -f($_.freespace/1gb)}}
