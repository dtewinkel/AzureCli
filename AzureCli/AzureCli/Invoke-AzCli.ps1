function Invoke-AzCli
{
	<#
	.SYNOPSIS
	Invokes the Azure CLI from PowerShell, providing better error handling and converting the output from JSON to a custom object.

	.DESCRIPTION

	Invokes the Azure CLI from PowerShell.

	Unless specified otherwise, converts the output from JSON to a custom object. This make further dealing with the output in PowerShell much easier.

	Provides better error handling, so that script fails more easily if the Azure CLI fails.

	Fixes the console colors back to what they were before calling the Azure CLI, as it tends to screw up the colors on errors, verbose output, and other cases.

	Allows to set most of the common Azure CLI parameters through PowerShell parameters:

	- -Output for --output
	- -Help for --help
	- -Query for --query
	- -Subscription for --subscription

	In most cases only the PowerShell or the Azure CLI version of a parameter can be used. Specifying both is an error.

	.PARAMETER Subscription
	Adds the --subscription common parameter. Specify the name or ID of subscription. You can configure the default subscription using `Invoke-AzCli account set -s NAME_OR_ID`.

	.PARAMETER Query
	Adds the --query common parameter. Provide the JMESPath query string. See http://jmespath.org/ for more information and examples.

	.PARAMETER Output
	If Output is set to object (the default), then the JSON output of the Azure CLI will be converted to a custom object for easy processing in PowerShell

	Otherwise adds the --query common parameter. Valid values are json, jsonc, none, table, tsv, yaml, and yamlc.

	.PARAMETER SuppressCliWarnings
	Suppress warnings from the result of calling the Azure CLI. This is passed on as '--only-show-errors' to the Azure CLI.

	.PARAMETER SuppressOutput
	Suppress any object output from the result of calling the Azure CLI. This is passed on as '--output none' to the Azure CLI.

	.PARAMETER Raw
	Do not process the output of Azure CLI.

	.PARAMETER Help
	Get the help text from the Azure CLI.

	.PARAMETER Arguments
	All the remaining arguments are passedon the Azure CLI.

	.EXAMPLE
	Invoke-AzCli storage account list -Subscription "My Subscription"

	List all storage accounts in the given subscription.

	.EXAMPLE
	iaz version

	Use the alias for Invoke-AzCli to get the verion information of Azure CLI.

	#>

	<# Enable -Verbose, -Force and -WhatIf. #>
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

		$hostInfo = Get-Host
		$ForegroundColor = $hostInfo.ui.rawui.ForegroundColor
		$BackgroundColor = $hostInfo.ui.rawui.BackgroundColor

		$rawOutput = $false
		if ($Raw.IsPresent)
		{
			$rawOutput = true
		}

		if ($Output)
		{
			if ($Arguments -contains "--output")
			{
				throw "Both -Output and --output are set on the commandline."
			}
			$additionalArguments += '--output', $Output
			$outputRequested = $true
		}
		elseif ($Arguments -contains "--output")
		{
			$outputRequested = $true
		}

		if ($Arguments -contains "--help")
		{
			$helpRequested = $true
		}
		if ($Help.IsPresent)
		{
			$additionalArguments += '--help'
			$helpRequested = $true
		}

		if (-not $helpRequested -and $SuppressOutput.IsPresent)
		{
			if ($Arguments -contains "--output" -or $Output)
			{
				throw "Both -SuppressOutput and --output are set on the commandline."
			}
			$additionalArguments = @('--output', 'none')
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
		Write-verbose "Invoking [az $Arguments $additionalArguments]"
		try
		{
			if ($Raw.IsPresent)
			{
				az @Arguments @additionalArguments
			}
			else
			{
				$result = az @Arguments @additionalArguments
			}
		}
		finally
		{
				$hostInfo.ui.rawui.ForegroundColor = $ForegroundColor
				$hostInfo.ui.rawui.BackgroundColor = $BackgroundColor
		}
		# Restore console colors, as az cli likely to change them.
		if (-not $?)
		{
			if($null -ne $result)
			{
				$result
				throw "Command exited with error code ${LASTEXITCODE}: ${result}"
			}
			throw "Command exited with error code ${LASTEXITCODE}"
		}
		if ($helpRequested -or $outputRequested -or $Arguments.Length -eq 0)
		{
			$result
		}
		elseif ($null -ne $result -and -not $SuppressOutput.IsPresent -and -not $outputRequested)
		{
			$result | ConvertFrom-Json
		}
	}
}

New-alias -Name iaz Invoke-AzCli
