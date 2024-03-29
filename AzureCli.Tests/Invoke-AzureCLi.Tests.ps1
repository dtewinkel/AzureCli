﻿[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',
		Justification='To test not showing SecureString Values in verbose output.')]
[CmdletBinding()]
param (
	[Parameter()]
	[string] $ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'AzureCli')).Path
)

Describe "Invoke-AzCli general handling" {

	BeforeAll {

		$jsonText = '{ "IsAz": true }'

		$old_PSNativeCommandArgumentPassing = Get-Variable -Name PSNativeCommandArgumentPassing -ValueOnly -ErrorAction SilentlyContinue

		$OriginalAzCliVerbosityPreference = Get-Variable -Name AzCliVerbosityPreference -ValueOnly -ErrorAction SilentlyContinue

		if($OriginalAzCliVerbosityPreference)
		{
			Clear-Variable AzCliVerbosityPreference -Scope Global
		}

		$convertToSecureStringCompatibleArguments = @{}
		if($PSVersionTable.PSVersion.Major -lt 7)
		{
			$convertToSecureStringCompatibleArguments += @{ Force = $true }
		}

		function az { $jsonText }
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
		Mock az { $jsonText } -ModuleName 'AzureCli'
		Mock Write-Verbose -ModuleName 'AzureCli'
		Mock Write-Warning -ModuleName 'AzureCli'
	}

	BeforeEach {

		# Set it for most tests.
		$global:PSNativeCommandArgumentPassing = "Windows"
	}

	AfterAll {
		if($old_PSNativeCommandArgumentPassing)
		{
			$global:PSNativeCommandArgumentPassing = $old_PSNativeCommandArgumentPassing
		}
		else
		{
			Clear-Variable PSNativeCommandArgumentPassing -Scope Global
		}

		if ($OriginalAzCliVerbosityPreference)
		{
			$global:AzCliVerbosityPreference = $OriginalAzCliVerbosityPreference
		}
	}

	It "throw an exception if az is not found" {

		Mock Get-Command { } -ParameterFilter { $name -eq 'az' } -ModuleName 'AzureCli'
		{ Invoke-AzCli test -Query '{ name }' } | Should -Throw "The 'az' Azure CLI command is not found. Please go to*"
	}

	It "Returns the passed query to az" {

		Invoke-AzCli test -Query '{ name }'
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains('"--query" "{ name }"') } -ModuleName 'AzureCli'
	}

	It "Sets the Subscription parameter" {

		Invoke-AzCli vm list -Subscription sub
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains('"--subscription" "sub"') } -ModuleName 'AzureCli'
	}

	It "Sets the ResourceGroup parameter" {

		Invoke-AzCli vm list -ResourceGroup rg
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains('"--resource-group" "rg"') } -ModuleName 'AzureCli'
	}

	It "Escapes strings with double quotes or backslashes if EscapeHandling Always is specified" {

		Invoke-AzCli vm list -Query 'query with " and \.' -EscapeHandling Always
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"query with \" and \\."' } -ModuleName 'AzureCli'
	}

	It "Does not escapes strings with double quotes or backslashes if EscapeHandling is not specified" {

		Invoke-AzCli vm list -Query 'query with " and \.'
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"query with " and \."' } -ModuleName 'AzureCli'
	}

	It "Does not escapes strings with double quotes or backslashes if EscapeHandling Never is specified" {

		Invoke-AzCli vm list -Query 'query with " and \.' -EscapeHandling Never
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"query with " and \."' } -ModuleName 'AzureCli'
	}

	It "Mask a SecureString in the verbose output" {

		$plainText = "PlainTextSecret"
		$secureString = ConvertTo-SecureString -AsPlainText $plainText @convertToSecureStringCompatibleArguments

		Invoke-AzCli something --password $secureString -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains("`"--password`" `"${plainText}`"") } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "something" "--password" ******** "--verbose"]' } -ModuleName 'AzureCli'
	}

	It "Adds -ConcatenatedArguments" {

		Invoke-AzCli something -ConcatenatedArguments @{ '--arg' = 1 } -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains("`"--arg=1`"") } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "something" "--arg=1" "--verbose"]' } -ModuleName 'AzureCli'
	}

	It "Mask a SecureString in the verbose output for -ConcatenatedArguments" {

		$plainText = "PlainTextSecret"
		$secureString = ConvertTo-SecureString -AsPlainText $plainText @convertToSecureStringCompatibleArguments

		Invoke-AzCli something -ConcatenatedArguments @{ '--password' =  $secureString } -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains("`"--password=${plainText}`"") } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "something" "--password=********" "--verbose"]' } -ModuleName 'AzureCli'
	}

	It "Sets the SuppressCliWarnings parameter" {

		Invoke-AzCli vm list -SuppressCliWarnings
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--only-show-errors"' } -ModuleName 'AzureCli'
		Should -Invoke Write-Warning -ParameterFilter { $Message -like "'-SuppressCliWarnings' is deprecated. Please use '-CliVerbosity NoWarnings' instead.*" } -ModuleName 'AzureCli'
	}

	It "Sets the Verbose parameter" {

		Invoke-AzCli vm list -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--verbose"' } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list" "--verbose"]' } -ModuleName 'AzureCli'
	}

	It "Suppresses the --verbose parameter if CliVerbosity is Default" {

		Invoke-AzCli vm list -Verbose -CliVerbosity Default
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -notcontains '"--verbose"' } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list"]' } -ModuleName 'AzureCli'
	}

	Context "With `$AzCliVerbosityPreference set." {

		BeforeAll {
			$OriginalAzCliVerbosityPreference = Get-Variable -Name AzCliVerbosityPreference -ValueOnly -ErrorAction SilentlyContinue

			$global:AzCliVerbosityPreference = 'Default'
		}

		It "Suppresses the --verbose parameter if CliVerbosity is set globally to Default" {

			Invoke-AzCli vm list -Verbose
			Should -Invoke az -Exactly 1 -ParameterFilter { $args -notcontains '"--verbose"' } -ModuleName 'AzureCli'
			Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list"]' } -ModuleName 'AzureCli'
		}

		It "Include the --only-show-errors parameter if CliVerbosity is NoWarnings and CliVerbosity is set globally to Default" {

			Invoke-AzCli vm list -CliVerbosity NoWarnings
			Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--only-show-errors"' } -ModuleName 'AzureCli'
		}

		AfterAll {
			if ($OriginalAzCliVerbosityPreference)
			{
				$global:AzCliVerbosityPreference = $OriginalAzCliVerbosityPreference
			}
			else
			{
				Clear-Variable AzCliVerbosityPreference -Scope Global
			}
		}
	}

	It "Include the --only-show-errors parameter if CliVerbosity is NoWarnings" {

		Invoke-AzCli vm list -CliVerbosity NoWarnings
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--only-show-errors"' } -ModuleName 'AzureCli'
	}

	It "Include the --verbose parameter if CliVerbosity is Verbose" {

		Invoke-AzCli vm list -CliVerbosity verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--verbose"' } -ModuleName 'AzureCli'
	}

	It "Include the --debug parameter if CliVerbosity is Debug" {

		Invoke-AzCli vm list -CliVerbosity debug
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -ccontains '"--debug"' } -ModuleName 'AzureCli'
	}

	It "Include the debug parameter if CliVerbosity is Debug and -Verbose is specified" {

		Invoke-AzCli vm list -CliVerbosity Debug -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -notcontains '"--verbose"' -and $args -ccontains '"--debug"' } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list" "--debug"]' } -ModuleName 'AzureCli'
	}

	It "Does not quote each parameter if PSNativeCommandArgumentPassing is set to Standard" {

		$global:PSNativeCommandArgumentPassing = "Standard"

		Invoke-AzCli vm list --name dummy
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' - ') -eq 'vm - list - --name - dummy' } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az vm list --name dummy]' } -ModuleName 'AzureCli'
	}

	It "Does quotes each parameter if PSNativeCommandArgumentPassing is set to Windows" {

		$global:PSNativeCommandArgumentPassing = "Windows"

		Invoke-AzCli vm list --name dummy
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' - ') -eq '"vm" - "list" - "--name" - "dummy"' } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list" "--name" "dummy"]' } -ModuleName 'AzureCli'
	}

	It "Does quotes each parameter if PSNativeCommandArgumentPassing is set to Legacy" {

		$global:PSNativeCommandArgumentPassing = "Legacy"

		Invoke-AzCli vm list --name dummy
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' - ') -eq '"vm" - "list" - "--name" - "dummy"' } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list" "--name" "dummy"]' } -ModuleName 'AzureCli'
	}

	It "Does quotes each parameter if PSNativeCommandArgumentPassing is not set" {

		Remove-Variable -name $PSNativeCommandArgumentPassing -Scope global -ErrorAction SilentlyContinue

		Invoke-AzCli vm list --name dummy
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' - ') -eq '"vm" - "list" - "--name" - "dummy"' } -ModuleName 'AzureCli'
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list" "--name" "dummy"]' } -ModuleName 'AzureCli'
	}
}
