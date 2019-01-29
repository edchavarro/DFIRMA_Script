param([string]$path)

#By @echavarro 

function Get-ScriptBlockCache 
{ 
    $nodeType = dbg !dumpheap -type ConcurrentDictionary | 
        Select-String 'ConcurrentDictionary.*Node.*Tuple.*String.*String.*\]\]$' 
    $nodeMT = $nodeType | ConvertFrom-String | Foreach-Object P1 
    $nodeAddresses = dbg !dumpheap -mt $nodeMT -short 
    $keys = $nodeAddresses | % { dbg !do $_ } | Select-String m_key 
    $keyAddresses = $keys | ConvertFrom-String | Foreach-Object P7
    foreach($keyAddress in $keyAddresses) { 
        $keyObject = dbg !do $keyAddress

        $item1 = $keyObject | Select-String m_Item1 | ConvertFrom-String | % P7 
        $string1 = dbg !do $item1 | Select-String 'String:\s+(.*)' | % { $_.Matches.Groups[1].Value }

        $item2 = $keyObject | Select-String m_Item2 | ConvertFrom-String | % P7 
        $string2 = dbg !do $item2 | Select-String 'String:\s+(.*)' | % { $_.Matches.Groups[1].Value }

        [PSCustomObject] @{ Path = $string1; Content = $string2 } 
    } 
}
Write-Host '{i} This script uses the function Get-ScriptBlockCache to extract scripts from powershell memory dumps.
	For more information go to http://www.leeholmes.com/blog/2019/01/17/extracting-forensic-script-content-from-powershell-process-dumps/'
if ($path.length -eq 0)
{
	Write-Host '	Usage: Get-ScriptBlockCache.ps1 <dump file>'
}
else
{
Write-Host '
{i} If you haven''t installed WinDbg module use: Install-Module WinDbg -Scope CurrentUser'

Write-Host "If you get an error or do not get any results, execute the following command before executing this script"
$ArgumentList="'-z ""$path""'"
Write-Host "	Connect-DbgSession -ArgumentList $ArgumentList"

Write-Host "Executing Get-ScriptBlockCache function on dbg session for file $path"
Get-ScriptBlockCache 
}