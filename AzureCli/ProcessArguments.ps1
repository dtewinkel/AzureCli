function ProcessArguments()
{
	[OutputType('System.Array')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[object[]] $Arguments,

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

	$commandLineArguments, $verboseCommandLineArguments
}
