function Complete
{
	[CmdletBinding()]
	param ($Command, $Cursor = -1)

	$cursorPos = $Cursor -eq -1 ? $Command.Length : $Cursor
	$pos = $Command.IndexOf('-') -1
	if ($pos -le -1)
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

	$filter = '*'
	if($cursorPos -gt 0)
	{
		if($command[$cursorPos - 1] -ne ' ')
		{
			$filterStart = $command.LastIndexOf(' ', $cursorPos - 1) + 1
			if($filterStart -le 0)
			{
				$filterStart = 0
			}
			$filter = $Command.Substring($filterStart, $cursorPos - $filterStart) + '*'
		}
	}

	$toSend = $pos -eq 0 ? "" : $Command.Substring(0, $pos)
	[PSCustomObject]@{
		Command   = $Command
		CursorPos = $cursorPos
		Pos       = $pos
		ToSend    = $toSend
		Filter    = $filter
	}
}
