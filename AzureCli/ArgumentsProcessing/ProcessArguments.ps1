function ProcessArguments()
{
	[OutputType('System.Array')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[object[]] $Arguments = @(),

		[Parameter()]
		[hashtable] $ConcatenatedArguments = @{},

		[Parameter()]
		[string] $EscapeHandling
	)

	$secretsMask = "********"

	function EscapeParameter($Argument, $escapeHandling)
	{
		switch ($escapeHandling)
		{
			"Always"
			{
				$escaped = "$Argument" -replace '(["\\])', '\$0'
			}

			"Never"
			{
				$escaped = $Argument
			}
		}
		"`"${escaped}`""
	}

	$commandLineArguments = @()
	$verboseCommandLineArguments = @()

	foreach ($argument in $Arguments)
	{
		if ($argument -is [securestring])
		{
			$plainArgument = ConvertFrom-SecureString $argument -AsPlainText
			$commandLineArguments += EscapeParameter $plainArgument $EscapeHandling
			$verboseCommandLineArguments += $secretsMask
		}
		else
		{
			$commandLineArguments += EscapeParameter $argument $EscapeHandling
			$verboseCommandLineArguments += EscapeParameter $argument $EscapeHandling
		}
	}

	foreach ($argument in $ConcatenatedArguments.GetEnumerator())
	{
		$argumentName = $argument.Key
		$argumentValue = $argument.Value
		if ($argumentValue -is [securestring])
		{
			$plainArgument = "${argumentName}=$(ConvertFrom-SecureString $argumentValue -AsPlainText)"

			$commandLineArguments += EscapeParameter $plainArgument $EscapeHandling
			Write-Verbose "${argumentName}=${secretsMask}"
			$verboseCommandLineArguments += EscapeParameter "${argumentName}=${secretsMask}" $EscapeHandling
		}
		else
		{
			$commandLineArgument = EscapeParameter "${argumentName}=${argumentValue}" $EscapeHandling
			$commandLineArguments += $commandLineArgument
			$verboseCommandLineArguments += $commandLineArgument
		}
	}

	$commandLineArguments, $verboseCommandLineArguments
}
