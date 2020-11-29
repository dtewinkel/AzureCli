Describe "Invoke-AzCli with commands that produce text" {

	BeforeAll {
		. $PSScriptRoot/Helpers/Az.ps1
		Mock az { "raw parameters: " + ($args -join " ") }
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "Returns the raw data for no parameters" {

		$expectedValue = 'raw parameters: '
		$result = Invoke-AzCLi
		$result | Should -Be $expectedValue
		Should -Invoke az -Exactly 1
		Should -Invoke ConvertFrom-Json -Exactly 0
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
		Should -Invoke az -Exactly 1
		Should -Invoke ConvertFrom-Json -Exactly 0
	}

	It "Does not convert the data for '<parameters>'" -TestCases @(
		@{ parameters = @( "help" ); expected = ' "help"' }
		@{ parameters = @( "vm", "--help" ); expected = ' "vm" "--help"' }
		@{ parameters = @( "--output", "json" ); expected = ' "--output" "json"' }
		@{ parameters = @( "--version" ); expected = ' "--version"' }
		@{ parameters = @( "find" ); expected = ' "find"' }
		@{ parameters = @( "upgrade" ); expected = ' "upgrade"' }
		@{ parameters = @( "interactive" ); expected = ' "interactive"' }
		@{ parameters = @( "feedback" ); expected = ' "feedback"' }
		@{ parameters = @( "configure" ); expected = ' "configure"' }
	) {
		param($parameters, $expected)

		$expectedValue = 'raw parameters:' + $expected
		$result = Invoke-AzCLi @parameters
		$result | Should -Be $expectedValue
		Should -Invoke az -Exactly 1
		Should -Invoke ConvertFrom-Json -Exactly 0
	}
}
