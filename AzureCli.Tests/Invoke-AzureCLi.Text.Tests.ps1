Describe "Invoke-AzCli with commands that produce text" {

	BeforeAll {

		. $PSScriptRoot/Helpers/Az.ps1

		Mock az { "raw parameters: " + ($Arguments -join " ") }

		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "Returns the raw data for no parameters" {

		$expectedValue = 'raw parameters: '
		$result = Invoke-AzCLi
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for '--version'" {

		$expectedValue = 'raw parameters: "--version"'
		$result = Invoke-AzCLi --version
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for 'find'" {

		$expectedValue = 'raw parameters: "find"'
		$result = Invoke-AzCLi find
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for 'help'" {

		$expectedValue = 'raw parameters: "help"'
		$result = Invoke-AzCLi help
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for '-Help'" {

		$expectedValue = 'raw parameters: "vm" "list" "--help"'
		$result = Invoke-AzCLi vm list -Help
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for '--help'" {

		$expectedValue = 'raw parameters: "vm" "list" "--help"'
		$result = Invoke-AzCLi vm list -Help
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for 'upgrade'" {

		$expectedValue = 'raw parameters: "upgrade"'
		$result = Invoke-AzCLi upgrade
		$result | Should -Be $expectedValue
		Should -Invoke az
	}
}
