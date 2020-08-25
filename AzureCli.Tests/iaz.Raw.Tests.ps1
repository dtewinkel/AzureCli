Describe "iaz With Text Output" {

	BeforeAll {

		. ./Helpers/Az.ps1

		Mock az { $Arguments -join "," }

		. ./Helpers/LoadModule.ps1
	}

	It "'--version' returns the raw data from az" {

		$expectedValue = '--version'
		$result = iaz --version
		$result | Should -Be $expectedValue
		Should -Invoke az
	}
}
