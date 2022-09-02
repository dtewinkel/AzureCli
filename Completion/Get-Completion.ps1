function DetectOptions([string[]] $ForWords)
{
	$text = az @ForWords --help 2>$null

	$detect = $false
	$capture = $false
	$toExpand = @()
	foreach($line in $text )
	{
		if ($line -eq "")
		{
			$detect = $true
			continue
		}

		if($detect)
		{
			switch -Regex ($line)
			{
				"^(Group|Command|Examples|To Search.*)$"
				{
					$capture = $false
				}

				"^(Subgroups:|Commands:|Arguments|Global Arguments)$"
				{
					$capture = $true
				}

				default
				{
					Write-Error "Huh: ${line}"
				}
			}

			$detect = $false
			continue
		}


		if($capture)
		{
			if($line -match '^ {4}.* : .+$')
			{
				$commandPart = ($line -split ':')[0]
				$commands = $commandPart -split ' ' | Where-Object { $_ -ne "" -and $_ -notmatch '^\[.*\]$' -and $_ -notmatch '^-\w' }
				$toExpand += $commands
			}
		}

	}

	$toExpand
}

function ExpandForAz([string] $ToExpand)
{
}

$scriptblock = {
	param($commandName, $wordToComplete, $cursorPosition)
	$command = $wordToComplete
	[string]$words = ($command -split ' ')[1..999] -join ' '
	if($commandName)
	{
		$words = $words.Substring(0, $words.Length - $commandName.Length)
	}

	$ForGroup = $words -split ' '
	$wordsForDetection = $ForGroup[-999..-2] | Where-Object { $_ -notlike '-*' }
	$filter = "$($ForGroup[-1])*"

	"{${commandName}} [${words}] <${cursorPosition}> (${wordToComplete}) => {${wordsForDetection}} (${filter})" |
		Out-File "${HOME}/az-completer.txt" -Append

	$options = DetectOptions $wordsForDetection | Where-Object { $_ -like $filter }

	$options | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}
Register-ArgumentCompleter -Native -CommandName az -ScriptBlock $scriptblock
