function Complete
{
	[CmdletBinding()]
	param ($Command, $Cursor)

	$cursorPos = $Cursor -eq -1 ? $Command.Length : $Cursor
	$pos = $Command.IndexOf('-')
	if ($pos -eq -1)
	{
		$pos = $Command.Length
	}
	if ($pos -ge $cursorPos)
	{
		$pos = $Command.LastIndexOf(' ', $cursorPos)
		if ($pos -eq $cursorPos)
		{
			"--- $pos ---"
		}
		$pos = $pos -eq -1 ? 0 : $pos
	}
	$toSend = $pos -eq 0 ? "" : $Command.Substring(0, $pos)
	[PSCustomObject]@{
		Command   = $Command
		CursorPos = $cursorPos
		Pos       = $pos
		ToSend    = $toSend
		Filter    = ""
	}
}
