function ProcessArguments()
{
	[OutputType('System.Array')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[object[]] $Arguments
	)

	$secretsMask = "********"

	function EscapeParameter($Argument)
	{
		$escaped = "$Argument" -replace '"', '\"'
		"`"${escaped}`""
	}

	$commandLineArguments = @()
	$verboseCommandLineArguments = @()
	foreach ($argument in $Arguments)
	{
		if ($argument -is [securestring])
		{
			$plainArgument = ConvertFrom-SecureString $argument -AsPlainText
			$commandLineArguments += EscapeParameter $plainArgument
			$verboseCommandLineArguments += $secretsMask
		}
		else
		{
			$commandLineArguments += EscapeParameter $argument
			$verboseCommandLineArguments += EscapeParameter $argument
		}
	}

	$commandLineArguments, $verboseCommandLineArguments
}
