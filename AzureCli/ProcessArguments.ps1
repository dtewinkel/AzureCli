function ProcessArguments()
{
	[OutputType('System.Array')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[object[]] $Arguments
	)

	function EscapeParameter($Argument)
	{
		$escaped = "$Argument" -replace '"', '\"'
		"`"${escaped}`""
	}

	$commandLineArguments = @()
	$verboseCommandLineArguments = @()
	foreach ($argument in $Arguments)
	{
		$commandLineArguments += EscapeParameter $argument
		$verboseCommandLineArguments += EscapeParameter $argument
	}

	$commandLineArguments, $verboseCommandLineArguments
}
