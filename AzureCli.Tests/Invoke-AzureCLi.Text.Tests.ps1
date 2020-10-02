Describe "Invoke-AzCli with commands that produce text" {

	BeforeAll {

		. ./Helpers/Az.ps1

		Mock az { $Arguments -join " " }

		. ./Helpers/LoadModule.ps1
	}

	It "Returns the raw data for '--version'" {

		$expectedValue = '--% "--version"'
		$result = Invoke-AzCLi --version
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for 'find'" {

		$expectedValue = '--% "find"'
		$result = Invoke-AzCLi find
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for 'help'" {

		$expectedValue = '--% "help"'
		$result = Invoke-AzCLi help
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for '-Help'" {

		$expectedValue = '--% "vm" "list" "--help"'
		$result = Invoke-AzCLi vm list -Help
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for '--help'" {

		$expectedValue = '--% "vm" "list" "--help"'
		$result = Invoke-AzCLi vm list -Help
		$result | Should -Be $expectedValue
		Should -Invoke az
	}
}
