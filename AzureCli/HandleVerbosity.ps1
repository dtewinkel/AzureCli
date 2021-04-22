function HandleVerbosity()
{
	[OutputType('System.Array')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[Switch] $SuppressCliWarnings,

		[Parameter()]
		[string] $CliVerbosity,

		[Parameter()]
		[object[]] $Arguments
	)

	$additionalArguments = @()

	$verboseArgument = '--verbose'
	$debugArgument = '--debug'
	$noWarningsArgument = '--only-show-errors'

	$verbose = $VerbosePreference -ne 'SilentlyContinue'

	if ($verbose)
	{
		if (-not $CliVerbosity)
		{
			if ($SuppressCliWarnings.IsPresent)
			{
				throw "-SuppressCliWarnings cannot be used together with -Verbose"
			}

			$additionalArguments += $verboseArgument
		}
	}

	switch ($CliVerbosity)
	{
		"NoWarnings"
		{
			$additionalArguments += $noWarningsArgument
		}

		"Verbose"
		{
			if ($SuppressCliWarnings.IsPresent)
			{
				throw "-SuppressCliWarnings cannot be used together with -CliVerbosity Verbose"
			}

			$additionalArguments += $verboseArgument
		}

		"Debug"
		{
			if ($SuppressCliWarnings.IsPresent)
			{
				throw "-SuppressCliWarnings cannot be used together with -CliVerbosity Debug"
			}

			$additionalArguments += $debugArgument
		}
	}

	if ($SuppressCliWarnings.IsPresent)
	{
		Write-Warning "'-SuppressCliWarnings' is deprecated. Please use '-CliVerbosity NoWarnings' instead. '-SuppressCliWarnings' may be removed in a later major version upgrade."
		$additionalArguments += $noWarningsArgument
	}

	$additionalArguments
}
