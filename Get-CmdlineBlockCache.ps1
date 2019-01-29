param([string]$path)

#By @echavarro 

function Get-CmdlineBlockCache 
{ 
	$historyInfo=dbg !dumpheap -type HistoryInfo
	$mt=$historyInfo| Select-String -pattern 'Microsoft.PowerShell.Commands.HistoryInfo$'| ConvertFrom-String |% P1
	foreach($mtval in $mt)
	{
		write-Host "`n	Microsoft.PowerShell.Commands.HistoryInfo Object found: ", $mtval,"`n" 
		$add=$historyInfo|Select-String -pattern $mtval|select-string -notmatch "History"| ConvertFrom-String |% P1
		$cmdaddr=foreach ($address in $add){dbg !DumpObj /d $address|Select-String -pattern "_cmdline"|ConvertFrom-String |% P7}
		write-Host "Command lines: "
		foreach ($address in $cmdaddr){dbg !DumpObj /d $address|select-string "String:"}
	}
}
Write-Host "`n{i} This script uses the function Get-CmdlineBlockCache to extract command lines from powershell memory dumps.
	For more information go to https://www.leeholmes.com/blog/2019/01/04/extracting-activity-history-from-powershell-process-dumps/"
if ($path.length -eq 0)
{
	Write-Host "`n	",'	Usage: Get-CmdlineBlockCache.ps1 <dump file>'
}
else
{
Write-Host '
{i} If you haven''t installed WinDbg module use: Install-Module WinDbg -Scope CurrentUser'

Write-Host "{!} If you get an error or do not get any results, execute the following command before executing this script"
$ArgumentList="'-z ""$path""'"
Write-Host "	Connect-DbgSession -ArgumentList $ArgumentList"

Write-Host "{i} Executing Get-CmdlineBlockCache function on dbg session for file $path"
Get-CmdlineBlockCache
Write-Host "`n{i} Process finished."

}