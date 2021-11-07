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
		[string[]] $Arguments
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
			if ($Arguments -contains $debugArgument)
			{
				throw "-CliVerbosity ${CliVerbosity} cannot be used together with ${debugArgument}"
			}
			if ($Arguments -contains $verboseArgument)
			{
				throw "-CliVerbosity ${CliVerbosity} cannot be used together with ${verboseArgument}"
			}

			$additionalArguments += $noWarningsArgument
		}

		"Verbose"
		{
			if ($SuppressCliWarnings.IsPresent)
			{
				throw "-SuppressCliWarnings cannot be used together with -CliVerbosity Verbose"
			}
			if ($Arguments -contains $noWarningsArgument)
			{
				throw "-CliVerbosity ${CliVerbosity} cannot be used together with ${noWarningsArgument}"
			}

			$additionalArguments += $verboseArgument
		}

		"Debug"
		{
			if ($SuppressCliWarnings.IsPresent)
			{
				throw "-SuppressCliWarnings cannot be used together with -CliVerbosity Debug"
			}
			if ($Arguments -contains $noWarningsArgument)
			{
				throw "-CliVerbosity ${CliVerbosity} cannot be used together with ${noWarningsArgument}"
			}

			$additionalArguments += $debugArgument
		}
	}

	if ($SuppressCliWarnings.IsPresent)
	{
		Write-Warning "'-SuppressCliWarnings' is deprecated. Please use '-CliVerbosity NoWarnings' instead. '-SuppressCliWarnings' may be removed in a later major version upgrade."
		if ($Arguments -contains $debugArgument)
		{
			throw "-SuppressCliWarnings cannot be used together with ${debugArgument}"
		}
		if ($Arguments -contains $verboseArgument)
		{
			throw "-SuppressCliWarnings cannot be used together with ${verboseArgument}"
		}
	$additionalArguments += $noWarningsArgument
	}

	$additionalArguments
}
