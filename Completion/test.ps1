[CmdletBinding()]
param (
		$Cursor = -1
)

$commands = "", "xxxx", "xxx yyy", "xxx yyy --aaa", "xxx yyy --aaa -b --ccc", "--aaa"

foreach ($command in $commands)
{

	$cursorPos = $Cursor -eq -1 ? $command.Length : $Cursor
	$pos = $command.IndexOf('-')
	if($pos -eq -1)
	{
		$pos = $command.Length
	}
	if($pos -ge $cursorPos)
	{
		$pos = $command.LastIndexOf(' ', $cursorPos)
		if($pos -eq $cursorPos)
		{
			"--- $pos ---"
		}
		$pos = $pos -eq -1 ? 0 : $pos
	}
	$toSend = $pos -eq 0 ? "" : $command.Substring(0, $pos)
	"${pos} => [${command}] => (${toSend})"
}
