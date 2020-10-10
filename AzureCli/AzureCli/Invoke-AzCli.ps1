function Invoke-AzCli
{
	<#
	.SYNOPSIS
	Invoke the Azure CLI from PowerShell, providing better error handling and converting the output from JSON to a custom object.

	.DESCRIPTION

	Invoke the Azure CLI from PowerShell.

	Unless specified otherwise, converts the output from JSON to a custom object. This make further dealing with the output in PowerShell much easier.

	Provides better error handling, so that script fails more easily if the Azure CLI fails.

	Fixes the console colors back to what they were before calling the Azure CLI, as the Azure CLI tends to screw up the colors on errors, verbose, and in some other cases.

	Allows to set most of the common Azure CLI parameters through PowerShell parameters:
	  - -Output for --output
	  - -Help for --help
	  - -Query for --query
	  - -Subscription for --subscription
	  - -SuppressCliWarnings for --only-show-errors

	In most cases only the PowerShell or the Azure CLI version of a parameter can be used. Specifying both is an error.

	The parameter -Raw can be used to provide the raw output of the Azure CLI. This cmdlet will not try to convert the output to a custom object in that case.

	The following command groups will produce raw output: help and find. Also if invoked with no parameters, or if the only parameter is --version, then raw output will be produced.

	.PARAMETER Subscription
	Adds the --subscription common parameter. Specify the name or ID of subscription. You can configure the default subscription using `Invoke-AzCli account set -s NAME_OR_ID`.

	.PARAMETER Query
	Adds the --query common parameter. Provide the JMESPath query string. See http://jmespath.org/ for more information and examples.

	.PARAMETER Output
	Adds the --output common parameter. Valid values are json, jsonc, none, table, tsv, yaml, and yamlc. The ourput will not be converted to a custom object.

	.PARAMETER SuppressCliWarnings
	Suppress warnings from the result of calling the Azure CLI. This is passed on as '--only-show-errors' to the Azure CLI.

	.PARAMETER SuppressOutput
	Suppress any object output from the result of calling the Azure CLI. This is passed on as '--output none' to the Azure CLI.

	.PARAMETER Raw
	Do not process the output of Azure CLI.

	.PARAMETER Help
	Get the help text from the Azure CLI. This is passed on as '--help' to the Azure CLI.

	.PARAMETER Arguments
	All the remaining arguments are passed on the Azure CLI.

	.EXAMPLE
	Invoke-AzCli storage account list -Subscription "My Subscription"

	List all storage accounts in the given subscription.

	.EXAMPLE
	iaz version

	Use the alias for Invoke-AzCli to get the version information of Azure CLI.

	#>

	<# Enable -Verbose. #>
	[CmdletBinding(PositionalBinding = $false)]
	param(
		[Parameter()]
		[string] $Subscription = $null,

		[Parameter()]
		[string] $Query = $null,

		[ValidateSet("json", "jsonc", "none", "table", "tsv", "yaml", "yamlc")]
		[alias("o")]
		[string] $Output = $null,

		[Switch] $SuppressOutput,

		[Parameter()]
		[Switch] $SuppressCliWarnings,

		[Switch] $Raw,

		[alias("h")]
		[Switch] $Help,

		[Parameter(ValueFromRemainingArguments)]
		[string[]] $Arguments
	)

	begin
	{
		$verbose = $VerbosePreference -ne 'SilentlyContinue'
		$additionalArguments = @()
		$interactiveCommand = "configure", "feedback", "interactive"
		$textOutputCommands = "find", "help", "upgrade"
		$rawCommandands = $interactiveCommand + $textOutputCommands

		$hostInfo = Get-Host
		$ForegroundColor = $hostInfo.ui.rawui.ForegroundColor
		$BackgroundColor = $hostInfo.ui.rawui.BackgroundColor

		$rawOutput = $Raw.IsPresent

		if ($Output)
		{
			if ($Arguments -contains "--output")
			{
				throw "Both -Output and --output are set on the commandline."
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
			if ($Arguments -contains "--output" -or $Output)
			{
				throw "Both -SuppressOutput and --output are set on the commandline."
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

		if ($Arguments.Length -gt 0 -and $Arguments[0] -in $rawCommandands)
		{
			$rawOutput = $true
		}

		if ($Arguments.Length -eq 1 -and $Arguments[0] -eq "--version")
		{
			$rawOutput = $true
		}

		if ($SuppressCliWarnings.IsPresent)
		{
			$additionalArguments += '--only-show-errors'
		}

		if ($verbose)
		{
			$additionalArguments += '--verbose'
		}

		if ($Subscription)
		{
			if ($Arguments -contains "--subscription")
			{
				throw "Both -Subscription and --subscription are set on the commandline."
			}
			$additionalArguments += '--subscription', $Subscription
		}

		if ($Query)
		{
			if ($Arguments -contains "--query")
			{
				throw "Both -Query and --query are set on the commandline."
			}
			$additionalArguments += '--query', $Query
		}
	}

	process
	{
		$allArguments = $Arguments + $additionalArguments
		$commandLine = (@( 'az', '--%' ) + ( $allArguments | ForEach-Object { "`"${_}`"" } )) -join ' '
		Write-verbose "Invoking [$commandLine]"

		try
		{
			if ($rawOutput)
			{
				Invoke-Expression $commandLine
			}
			else
			{
				$result = Invoke-Expression $commandLine
			}
		}
		finally
		{
			# Restore console colors, as Azure CLI likely to change them.
			$hostInfo.ui.rawui.ForegroundColor = $ForegroundColor
			$hostInfo.ui.rawui.BackgroundColor = $BackgroundColor
		}
		if (-not $?)
		{
			if($null -ne $result)
			{
				$result
				throw "Command exited with error code ${LASTEXITCODE}: ${result}"
			}
			throw "Command exited with error code ${LASTEXITCODE}"
		}
		if ($null -ne $result)
		{
			$result | ConvertFrom-Json
		}
	}
}

New-alias -Name iaz Invoke-AzCli
