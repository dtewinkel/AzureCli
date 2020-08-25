Describe "Invoke-AzCli with Interactive commands" {

	BeforeAll {

		. ./Helpers/Az.ps1

		Mock az { $Arguments -join "," }

		. ./Helpers/LoadModule.ps1
	}

	It "Returns the raw data for 'configure'" {

		$expectedValue = 'configure'
		$result = Invoke-AzCLi configure
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for 'feedback'" {

		$expectedValue = 'feedback'
		$result = Invoke-AzCLi feedback
		$result | Should -Be $expectedValue
		Should -Invoke az
	}

	It "Returns the raw data for 'interactive'" {

		$expectedValue = 'interactive'
		$result = Invoke-AzCLi interactive
		$result | Should -Be $expectedValue
		Should -Invoke az
	}
}
