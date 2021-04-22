function HandleRawOutputs()
{
	[OutputType('System.Array')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[string] $Output,

		[Parameter()]
		[Switch] $SuppressOutput,

		[Parameter()]
		[Switch] $Raw,

		[Parameter()]
		[object[]] $Arguments
	)

	$additionalArguments = @()
	$interactiveCommand = "configure", "feedback", "interactive"
	$textOutputCommands = "find", "help", "upgrade"
	$rawCommands = $interactiveCommand + $textOutputCommands
	$rawOutput = $Raw.IsPresent

	if ($Output)
	{
		if ($Arguments -contains "--output")
		{
			throw "Both -Output and --output are provided as parameter. This is not allowed."
		}
		$additionalArguments += '--output', $Output
		$rawOutput = $true
	}
	elseif ($Arguments -contains "--output")
	{
		$rawOutput = $true
	}

	if ($SuppressOutput.IsPresent)
	{
		if ($Arguments -contains "--output")
		{
			throw "Both -SuppressOutput and --output are provided as parameter. This is not allowed."
		}
		$additionalArguments = @('--output', 'none')
		$rawOutput = $true
	}

	if ($Arguments -contains "--help")
	{
		$rawOutput = $true
	}
	if ($Help.IsPresent)
	{
		$additionalArguments += '--help'
		$rawOutput = $true
	}

	if ($Arguments.Length -eq 0)
	{
		$rawOutput = $true
	}

	if ($Arguments.Length -gt 0 -and $Arguments[0] -in $rawCommands)
	{
		$rawOutput = $true
	}

	if ($Arguments.Length -eq 1 -and $Arguments[0] -eq "--version")
	{
		$rawOutput = $true
	}

	$rawOutput, $additionalArguments

}
