[CmdletBinding()]
param (
	[Parameter()]
	[string] $ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'AzureCli')).Path
)

Describe "Invoke-AzCli with commands that produce text" {

	BeforeAll {

		$old_PSNativeCommandArgumentPassing = Get-Variable -Name PSNativeCommandArgumentPassing -ValueOnly -ErrorAction SilentlyContinue
		$global:PSNativeCommandArgumentPassing = "Windows"

		function az { $args }

		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder

		Mock az { "raw parameters: " + ($args -join " ") } -ModuleName 'AzureCli'

		$additionalArguments = @()
		if ($PSVersionTable.PSVersion.Major -lt 7)
		{
			$additionalArguments = @{ RemoveParameterValidation =  'Depth' }
		}
		Mock ConvertFrom-Json {} -ModuleName 'AzureCli' @additionalArguments
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
	}

	It "Returns the raw data for no parameters" {

		$expectedValue = 'raw parameters: '
		$result = Invoke-AzCLi

		$result | Should -Be $expectedValue
		Should -Invoke az -Exactly 1 -ModuleName 'AzureCli'
		Should -Invoke ConvertFrom-Json -Exactly 0 -ModuleName 'AzureCli'
	}

	It "Does not convert the data for '-<parameterName>'" -TestCases @(
		@{ parameterName = "Raw"; parameterValue = $true; expected = '' }
		@{ parameterName = "SuppressOutput"; parameterValue = $true; expected = ' "--output" "none"' }
		@{ parameterName = "Output"; parameterValue = 'json'; expected = ' "--output" "json"' }
		@{ parameterName = "Help"; parameterValue = $true; expected = ' "--help"' }
	) {
		param($parameterName, $parameterValue, $expected)

		$expectedValue = 'raw parameters: "vm" "list"' + $expected
		$parameters = @{ $parameterName = $parameterValue }

		$result = Invoke-AzCLi vm list @parameters

		$result | Should -Be $expectedValue
		Should -Invoke az -Exactly 1 -ModuleName 'AzureCli'
		Should -Invoke ConvertFrom-Json -Exactly 0 -ModuleName 'AzureCli'
	}

	It "Does not convert the data for '<parameters>'" -TestCases @(
		@{ parameters = @( "help" ); expected = ' "help"' }
		@{ parameters = @( "vm", "--help" ); expected = ' "vm" "--help"' }
		@{ parameters = @( "--output", "json" ); expected = ' "--output" "json"' }
		@{ parameters = @( "vm", "--output", "json" ); expected = ' "vm" "--output" "json"' }
		@{ parameters = @( "--version" ); expected = ' "--version"' }
		@{ parameters = @( "find" ); expected = ' "find"' }
		@{ parameters = @( "upgrade" ); expected = ' "upgrade"' }
		@{ parameters = @( 'bicep', "upgrade" ); expected = ' "bicep" "upgrade"' }
		@{ parameters = @( "interactive" ); expected = ' "interactive"' }
		@{ parameters = @( "feedback" ); expected = ' "feedback"' }
		@{ parameters = @( "configure" ); expected = ' "configure"' }
	) {
		param($parameters, $expected)

		$expectedValue = 'raw parameters:' + $expected

		$result = Invoke-AzCLi @parameters

		$result | Should -Be $expectedValue
		Should -Invoke az -Exactly 1 -ModuleName 'AzureCli'
		Should -Invoke ConvertFrom-Json -Exactly 0 -ModuleName 'AzureCli'
	}
}
