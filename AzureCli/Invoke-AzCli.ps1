function Invoke-AzCli
{
	<#
.SYNOPSIS
Invoke the Azure CLI from PowerShell, providing better error handling and converting the output from JSON to a custom object or a hash table.

.DESCRIPTION

Invoke the Azure CLI from PowerShell.

Unless specified otherwise, converts the output from JSON to a custom object (PSCustomObject). This make further dealing with the output in PowerShell much easier.

Provides better error handling, so that script fails more easily if the Azure CLI fails.

Fixes the console colors back to what they were before calling the Azure CLI, as the Azure CLI tends to screw up the colors on errors, verbose, and in some other cases.

Allows to set most of the common or often used Azure CLI parameters through PowerShell parameters:
	- -Output for --output
	- -Help for --help
	- -Query for --query
	- -Subscription for --subscription
	- -ResourceGroup for --resource-group
	- -SuppressCliWarnings for --only-show-errors

In most cases only the PowerShell or the Azure CLI version of a parameter can be used. Specifying both is an error.

The parameter -Raw can be used to provide the raw output of the Azure CLI. This cmdlet will not try to convert the output to a custom object in that case.

The following command groups will produce raw output: help, find, and upgrade. Also if invoked with no parameters, or if the only parameter is --version, then raw output will be produced.

The commands configure, feedback, and interactive are interactive and do not produce JSON output.

By default -Verbose will output verbose information about the commandline used to call Azure CLI. Unless the -CliVerbosity is specified this will also result in verbose output from the Azure CLI.

.PARAMETER Subscription
Adds the --subscription common parameter. Specify the name or ID of subscription. Tab-completion on the name and the id of the subscripotion. You can configure the default subscription using `Invoke-AzCli account set -s NAME_OR_ID`.

.PARAMETER ResourceGroup
Adds the --resource-group parameter. Specify the name of the resource group. Tab-completion on the name of the resource group.

.PARAMETER Query
Adds the --query common parameter. Provide the JMESPath query string. See http://jmespath.org/ for more information and examples.

.PARAMETER Output
Adds the --output common parameter. Valid values are json, jsonc, none, table, tsv, yaml, and yamlc. The ourput will not be converted to a custom object.

.PARAMETER AsHashtable
Adds the --output common parameter. Valid values are json, jsonc, none, table, tsv, yaml, and yamlc. The ourput will not be converted to a custom object.

.PARAMETER NoEnumerate
Specifies that output is not enumerated. Setting this parameter causes arrays to be sent as a single object instead of sending every element separately. This guarantees that JSON can be round-tripped via `ConvertTo-Json`.

.PARAMETER SuppressCliWarnings
Suppress warnings from the result of calling the Azure CLI. This is passed on as '--only-show-errors' to the Azure CLI.

.PARAMETER SuppressOutput
Suppress any object output from the result of calling the Azure CLI. This is passed on as '--output none' to the Azure CLI.

.PARAMETER CliVerbosity
Set the verbosity of Azure CLI. Valid valuse are `NoWarnings`, `Default`, `Vebose`, and `Debug`.
Use `NoWarnings` to get verbose output, without using `-Verbose`. This is passed on as '--verbose' to the Azure CLI. Azure CLI will be verbose. Invoke-AzCli will not be verbose.
Use `Default` to suppress Azure CLI verbosity in combination with `-Verbose`. Azure CLI will not be verbose, but, if -Verbose is used, then Invoke-AzCli will be verbose.
Use `verbose` to get verbose output, without using `-Verbose`. This is passed on as '--verbose' to the Azure CLI.
Use `Debug` to get debug output. This is passed on as '--debug' to the Azure CLI.

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

Uses the alias for Invoke-AzCli to get the version information of Azure CLI.

#>

	<# Enable -Verbose. #>
	[CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'ObjectOutput')]
	param(
		[Parameter()]
		[string] $Subscription,

		[Parameter()]
		[string] $ResourceGroup,

		[Parameter()]
		[string] $Query,

		[Parameter(ParameterSetName = 'TextOutput')]
		[ValidateSet("json", "jsonc", "none", "table", "tsv", "yaml", "yamlc")]
		[alias("o")]
		[string] $Output,

		[Parameter(ParameterSetName = 'ObjectOutput')]
		[Switch] $AsHashtable,

		[Parameter(ParameterSetName = 'ObjectOutput')]
		[Switch] $NoEnumerate,

		[Parameter(ParameterSetName = 'NoOutput')]
		[Switch] $SuppressOutput,

		[Parameter(ParameterSetName = 'RawOutput')]
		[Switch] $Raw,

		[Parameter(ParameterSetName = 'HelpOutput')]
		[alias("h")]
		[Switch] $Help,

		[Parameter()]
		[Switch] $SuppressCliWarnings,

		[Parameter()]
		[ValidateSet("NoWarnings", "Default", "Verbose", "Debug")]
		[string] $CliVerbosity,

		[Parameter(ValueFromRemainingArguments)]
		[string[]] $Arguments
	)

	begin
	{
		$azCmd = Get-Command az -ErrorAction SilentlyContinue
		if (-not $azCmd)
		{
			throw "The az CLI is not found. Please go to https://docs.microsoft.com/en-us/cli/azure/install-azure-cli to install it."
		}

		$verbose = $VerbosePreference -ne 'SilentlyContinue'
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

		if ($SuppressCliWarnings.IsPresent)
		{
			$additionalArguments += '--only-show-errors'
		}

		if ($verbose)
		{
			if (-not $CliVerbosity)
			{
				$additionalArguments += '--verbose'
			}
		}

		switch ($CliVerbosity)
		{
			"NoWarnings"
			{
				$additionalArguments += '--only-show-errors'
			}

			"Verbose"
			{
				$additionalArguments += '--verbose'
			}

			"Debug"
			{
				$additionalArguments += '--debug'
			}
		}

		if ($Subscription)
		{
			if ($Arguments -contains "--subscription")
			{
				throw "Both -Subscription and --subscription are provided as parameter. This is not allowed."
			}
			$additionalArguments += '--subscription', $Subscription
		}

		if ($ResourceGroup)
		{
			if ($Arguments -contains "--resource-group")
			{
				throw "Both -ResourceGroup and --resource-group are provided as parameter. This is not allowed."
			}
			$additionalArguments += '--resource-group', $ResourceGroup
		}

		if ($Query)
		{
			if ($Arguments -contains "--query")
			{
				throw "Both -Query and --query are provided as parameter. This is not allowed."
			}
			$additionalArguments += '--query', $Query
		}
	}

	process
	{
		$allArguments = $Arguments + $additionalArguments
		$commandLine = @( $allArguments | ForEach-Object { "`"${_}`"" } )
		Write-Verbose "Invoking [$commandLine]"

		if ($rawOutput)
		{
			az @commandLine
			$hadError = -not $?
		}
		else
		{
			$hostInfo = Get-Host
			$ForegroundColor = $hostInfo.ui.rawui.ForegroundColor
			$BackgroundColor = $hostInfo.ui.rawui.BackgroundColor
			try
			{
				$result = az @commandLine
				$hadError = -not $?
			}
			finally
			{
				# Restore console colors, as Azure CLI likely to change them.
				$hostInfo.ui.rawui.ForegroundColor = $ForegroundColor
				$hostInfo.ui.rawui.BackgroundColor = $BackgroundColor
			}
		}
		if ($hadError)
		{
			if ($null -ne $result)
			{
				$result
				throw "Command exited with error code ${LASTEXITCODE}: ${result}"
			}
			throw "Command exited with error code ${LASTEXITCODE}"
		}
		if ($null -ne $result)
		{
			$additionalArguments = @{}
			if ($NoEnumerate.IsPresent)
			{
				$additionalArguments.Add("NoEnumerate", $true)
			}
			if ($AsHashtable.IsPresent)
			{
				$additionalArguments.Add("AsHashtable", $true)
			}
			$result | ConvertFrom-Json @additionalArguments
		}
	}
}

New-Alias -Name iaz Invoke-AzCli
