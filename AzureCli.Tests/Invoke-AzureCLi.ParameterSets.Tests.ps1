[CmdletBinding()]
param (
	[Parameter()]
	[string]
	[string] $ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'AzureCli')).Path
)

Describe "Invoke-AzCli with Interactive commands" {

	BeforeAll {

		if($AzCliVerbosityPreference)
		{
			$OriginalAzCliVerbosityPreference = $AzCliVerbosityPreference
			Clear-Variable AzCliVerbosityPreference -Scope Global
		}

		function az { $jsonText }
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
		Mock az -ModuleName 'AzureCli'
		Mock Write-Warning -ModuleName 'AzureCli'
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

	$combinations = @(
		@{ first = "Help"; second = "SuppressOutput"; secondValue = $true }
		@{ first = "Help"; second = "AsHashTable"; secondValue = $true }
		@{ first = "Help"; second = "NoEnumerate"; secondValue = $true }
		@{ first = "Help"; second = "Raw"; secondValue = $true }
		@{ first = "Help"; second = "Output"; secondValue = 'json' }
		@{ first = "Raw"; second = "SuppressOutput"; secondValue = $true }
		@{ first = "Raw"; second = "AsHashTable"; secondValue = $true }
		@{ first = "Raw"; second = "NoEnumerate"; secondValue = $true }
		@{ first = "Raw"; second = "Output"; secondValue = 'json' }
		@{ first = "SuppressOutput"; second = "AsHashTable"; secondValue = $true }
		@{ first = "SuppressOutput"; second = "NoEnumerate"; secondValue = $true }
		@{ first = "SuppressOutput"; second = "Output"; secondValue = 'json' }
		@{ first = "AsHashTable"; second = "Output"; secondValue = 'json' }
		@{ first = "NoEnumerate"; second = "Output"; secondValue = 'json' }
	)
	It "Fails with combined parameters: <first>, <second> with message about parameter set" -TestCases $combinations {
		param($first, $second, $secondValue)

		$parameters = @{ $first = $true; $second = $secondValue }

		{ Invoke-AzCLi @parameters } | Should -Throw "*Parameter set cannot be resolved *"

		Should -Not -Invoke az -ModuleName 'AzureCli'
	}

	$combinations = @(
		@{ first = "SuppressCliWarnings"; second = "CliVerbosity"; secondValue = 'Debug'; exceptionMessage = "-SuppressCliWarnings cannot be used together with -CliVerbosity Debug" }
		@{ first = "SuppressCliWarnings"; second = "CliVerbosity"; secondValue = 'Verbose'; exceptionMessage = "-SuppressCliWarnings cannot be used together with -CliVerbosity Verbose" }
		@{ first = "SuppressCliWarnings"; second = "Verbose"; secondValue = $true; exceptionMessage = "-SuppressCliWarnings cannot be used together with -Verbose" }
	)
	It "Fails with combined parameters: <first>, <second> with exception" -TestCases $combinations {
		param($first, $second, $secondValue, $exceptionMessage)

		$parameters = @{ $first = $true; $second = $secondValue }

		{ Invoke-AzCLi @parameters } | Should -Throw $exceptionMessage

		Should -Not -Invoke az -ModuleName 'AzureCli'
	}

	It "Fails with combined parameters: <first>, <second> with exception" -TestCases $combinations {
		param($first, $second, $secondValue, $exceptionMessage)

		$parameters = @{ $first = $true; $second = $secondValue }

		{ Invoke-AzCLi @parameters } | Should -Throw $exceptionMessage

		Should -Not -Invoke az -ModuleName 'AzureCli'
	}

	$combinations = @(
		@{ first = "-SuppressCliWarnings"; second = '--debug'; exceptionMessage = "-SuppressCliWarnings cannot be used together with --debug" }
		@{ first = "-SuppressCliWarnings"; second = '--verbose'; exceptionMessage = "-SuppressCliWarnings cannot be used together with --verbose" }
	)
	It "Fails with combined parameters: <first>, <second> with exception" -TestCases $combinations {
		param($first, $second, $exceptionMessage)

		$parameters = @{ $first = $true }

		{ Invoke-AzCLi @parameters $second } | Should -Throw $exceptionMessage

		Should -Invoke Write-Warning -ParameterFilter { $Message -like "'-SuppressCliWarnings' is deprecated. Please use '-CliVerbosity NoWarnings' instead.*" } -ModuleName 'AzureCli'
		Should -Not -Invoke az -ModuleName 'AzureCli'
	}

	$combinations = @(
		@{ first = "NoWarnings"; second = '--debug' }
		@{ first = "NoWarnings"; second = '--verbose' }
		@{ first = "Verbose"; second = '--only-show-errors' }
		@{ first = "Debug"; second = '--only-show-errors' }
	)
	It "Fails with combined parameters: -CliVerbosity NoWarnings, <parameter> with exception" -TestCases $combinations {
		param($first, $second)

		$exceptionMessage = "-CliVerbosity ${first} cannot be used together with ${second}"

		{ Invoke-AzCLi -CliVerbosity $first $second } | Should -Throw $exceptionMessage

		Should -Not -Invoke az -ModuleName 'AzureCli'
	}

	$combinations = @(
		@{ first = "SuppressOutput"; firstValue = $true; second = "--output"; secondValue = 'json' }
		@{ first = "Output"; firstValue = 'json'; second = "--output"; secondValue = 'json' }
		@{ first = "Subscription"; firstValue = 'sub'; second = "--subscription"; secondValue = 'sub' }
		@{ first = "ResourceGroup"; firstValue = 'sub'; second = "--resource-group"; secondValue = 'sub' }
		@{ first = "Query"; firstValue = 'q'; second = "--query"; secondValue = 'q' }
	)
	It "Fails with combined parameters: <first>, <second>" -TestCases $combinations {
		param($first, $firstvalue, $second, $secondValue)

		$firstParameter = @{ $first = $firstvalue }
		$secondParameter = @( $second )
		if($secondValue)
		{
			$secondParameter += $secondValue
		}
		$expected = "Both -${first} and ${second} are provided as parameter. This is not allowed."

		{ Invoke-AzCLi @firstParameter @secondParameter } | Should -Throw $expected

		Should -Not -Invoke az -ModuleName 'AzureCli'
	}
}
