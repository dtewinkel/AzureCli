function Invoke-AzCli
{
<#

.SYNOPSIS

Invoke the Azure CLI from PowerShell, converting output to PowerShell custom objects and providing better error handling.

.DESCRIPTION

Invoke the Azure CLI from PowerShell.

Unless specified otherwise, converts the output from JSON to a custom object (PSCustomObject). This make further
processing the output in PowerShell much easier.

Provides better error handling, so that script fails more easily if the Azure CLI fails.

In some scenarios the Azure CLI changes console output colors, but does not change them back to what they were. This may
happen for errors, verbose output, and in some other cases. Invoke-AzCli fixes the console colors back to what they were
before calling Azure CLI.

Allows to set most of the common or often used Azure CLI parameters through PowerShell parameters:
  - -Output for --output. Setting -Output, --output, or -Raw stops Invoke-AzCli from converting the output of Azure CLI
     to custom objects.
  - -Help for --help.
  - -Query for --query.
  - -Subscription for --subscription. -Subscription provides argument completion for subscription names and subscription
     IDs for the logged-in account.
  - -ResourceGroup for --resource-group -ResourceGroup provides argument completion for resource group names for the
     active subscription, or the subscription provides with -Subscription.
  - -CliVerbosity NoWarnings for --only-show-errors
  - -CliVerbosity Verbose for --verbose.
  - -CliVerbosity Debug for --debug.

In most cases only the PowerShell or the Azure CLI version of a parameter can be used. Specifying both is an error.

The parameter -Raw can be used to provide the raw output of the Azure CLI. This cmdlet will not try to convert the
output to a custom object in that case.

The following command groups will produce raw output: help, find, and upgrade. Also if invoked with no parameters, or if
the only parameter is --version, then raw output will be produced.

The commands configure, feedback, and interactive are interactive and do not produce JSON output.

By default -Verbose will output verbose information about the command-line used to call Azure CLI. Unless the
-CliVerbosity is specified this will also result in verbose output from the Azure CLI.

.EXAMPLE

Invoke-AzCli storage account list -Subscription "My Subscription"

List all storage accounts in the given subscription.

.EXAMPLE

iaz version

Uses the alias for Invoke-AzCli to get the version information of Azure CLI.

.EXAMPLE

Invoke-AzCli storage account list -Verbose -CliVerbosity None

List all storage accounts in the current subscription.
Print the arguments that are sent to the Azure CLI.
No verbosity from the Azure CLI.


.EXAMPLE

Invoke-AzCli storage account list -Query '[].{ name: name }' -NoEnumerate -AsHashtable

List all storage accounts in the current subscription.
Query to get only the name in an object per sttorage account.
Pass -NoEnumerate and -AsHashtable to ConvertFrom-Json.

#>

	[CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'ObjectOutput')]
	param(
		<#
		Adds the --subscription common parameter. Specify the name or ID of subscription.

		The -Subscription parameter supports argument completion, with the subscription name and IDs available to the
		current session.
		#>
		[Parameter()]
		[string] $Subscription,

		<#
		Adds the --resource-group parameter. Specify the name of the resource group.

		The -ResourceGroup parameter supports argument completion, with the resource groups available in to the currently
		selescted subscription in the current session, or the resource groups available in the subscription that is selected
		 with -Subscription.
		#>
		[Parameter()]
		[string] $ResourceGroup,

		<#
		Adds the --query common parameter. Provide the JMESPath query string. See http://jmespath.org/ for more information
		and examples.

		#>
		[Parameter()]
		[string] $Query,

		<#
		Defines how the double quoute (") and backslash (\) for the command-line parameters are escaped before sending them
		to the Azure CLI. Th following values are valid:

		- Never: Do not escape " or \. Any escaping must be done by the caller. This is the default value.
		- Always: Always escape " or \.
		#>
		[Parameter()]
		[ValidateSet("Never", "Always")]
		[string] $EscapeHandling = "Never",

		<#
		Adds the --output common parameter. Valid values are json, jsonc, none, table, tsv, yaml, and yamlc. The output
		will not be converted to a custom object.
		#>
		[Parameter(ParameterSetName = 'TextOutput')]
		[ValidateSet("json", "jsonc", "none", "table", "tsv", "yaml", "yamlc")]
		[alias("o")]
		[string] $Output,

		<#
		Converts the output to a HashTable instead of to a PSCustomObject. This is useful in certain scenarios:

		- If the JSON contains a list with keys that only differ in casing. Without the switch, those keys would be seen as
			identical keys and therefore only the last one would get used.
		- If the JSON contains a key that is an empty string. Without the switch, the cmdlet would throw an error since a
			PSCustomObject does not allow for that but a hash table does.
		- Hash tables can be processed faster for certain data structures.

		This switch will can only be used in PowerShell 6.0 or newer.
		#>
		[Parameter(ParameterSetName = 'ObjectOutput')]
		[Switch] $AsHashtable,

		<#
		Specifies that output is not enumerated. Setting this parameter causes arrays to be sent as a single object instead
		of sending every element separately. This guarantees that JSON can be round-tripped via ConvertTo-Json.
		#>
		[Parameter(ParameterSetName = 'ObjectOutput')]
		[Switch] $NoEnumerate,

		<#
		Suppress any object output from the result of calling the Azure CLI. This is passed on as '--output none' to the
		Azure CLI.
		#>
		[Parameter(ParameterSetName = 'NoOutput')]
		[Switch] $SuppressOutput,

		<#
		Do not process the output of Azure CLI.
		#>
		[Parameter(ParameterSetName = 'RawOutput')]
		[Switch] $Raw,

		<#
		Get help from Azure CLI. This is passed on as '--help' to the Azure CLI.
		#>
		[Parameter(ParameterSetName = 'HelpOutput')]
		[alias("h")]
		[Switch] $Help,

		<#
		Set the verbosity of Azure CLI. Valid values are NoWarnings, Default, Verbose, and Debug.
		Use NoWarnings to suppress all warnings from Azure CLI. This is passed on as '--only-show-errors' to the Azure CLI.
		Use Default to suppress Azure CLI verbosity in combination with -Verbose. Azure CLI will not be verbose, but, if
		-Verbose is used, then Invoke-AzCli will be verbose.
		Use Verbose to get verbose output from Azure CLI, without using -Verbose. This is passed on as '--verbose' to the
		Azure CLI.
		Use Debug to get debug output. This is passed on as '--debug' to the Azure CLI.

		The default value for -CliVerbosity can be set with the variable $AzCliVerbosityPreference.

		If -CliVerbosity is set, or the variable $AzCliVerbosityPreference is set, then the default behavior of -Verbose to
		also pass --verbose to Azure CLI is disabled.
		#>
		[Parameter()]
		[ValidateSet("NoWarnings", "Default", "Verbose", "Debug")]
		[string] $CliVerbosity = $AzCliVerbosityPreference,

		<#
		Add each item in the hashtable as an argument in the form <name>=<value>. This is mainly required if value starts
		with a - and would otherwise be iterpreted as an argument and not a value. For instance '--password "-123"' fails,
		where '--password=-123' succeeds.
		The values in the hash table of -ConcatenatedArguments parameter will be masked in verbose output if they are of
		type SecureString.
		#>
		[Parameter()]
		[hashtable] $ConcatenatedArguments = @{},

		<#
		Deprecated. Please use '-CliVerbosity NoWarnings' instead.

		Suppress warnings from the result of calling the Azure CLI. This is passed on as '--only-show-errors' to the Azure CLI.
		#>
		[Parameter()]
		[Switch] $SuppressCliWarnings,

		<#
		All the remaining arguments are passed on the Azure CLI.
		#>
		[Parameter(ValueFromRemainingArguments)]
		[object[]] $Arguments
	)

	AssertAzPresent

	$rawOutput, $additionalArguments = HandleRawOutputs -Output $Output -Help:$Help -SuppressOutput:$SuppressOutput -Raw:$Raw -Arguments $Arguments
	$additionalArguments += HandleVerbosity -SuppressCliWarnings:$SuppressCliWarnings -CliVerbosity $CliVerbosity -Arguments $Arguments
	$additionalArguments += HandleSubscription -Subscription $Subscription -Arguments $Arguments
	$additionalArguments += HandleResourceGroup -ResourceGroup $ResourceGroup -Arguments $Arguments
	$additionalArguments += HandleQuery -Query $Query -Arguments $Arguments
	$commandLine1, $verboseCommandLine1 = ProcessArguments -Arguments $Arguments -ConcatenatedArguments $ConcatenatedArguments -EscapeHandling $EscapeHandling
	$commandLine2, $verboseCommandLine2 = ProcessArguments -Arguments $additionalArguments -EscapeHandling $EscapeHandling
	$commandLine = $commandLine1 + $commandLine2
	$verboseCommandLine = $verboseCommandLine1 + $verboseCommandLine2
	if(-not $rawOutput)
	{
		$jsonArguments = HandleJson -AsHashtable:$AsHashtable -NoEnumerate:$NoEnumerate
	}

	Write-Verbose "Invoking [az $verboseCommandLine]"

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
		$result | ConvertFrom-Json @jsonArguments
	}
}

New-Alias -Name iaz Invoke-AzCli
