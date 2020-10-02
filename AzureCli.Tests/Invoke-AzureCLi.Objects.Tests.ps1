Describe "Invoke-AzCli With Object Output" {

	BeforeAll {

		. ./Helpers/Az.ps1

		Mock az { @{ Arguments = $Arguments } | ConvertTo-Json }

		. ./Helpers/LoadModule.ps1
	}

	It "Return the passed query to az" {

		$expectedValue = @{ Arguments = ('--%', '"version" "--verbose" "--query" "{ name }"') }
		$result = Invoke-AzCli version -Query '{ name }' -Verbose
		$result.Arguments | Should -Be $expectedValue.Arguments
		Should -Invoke az
	}

	It "Return the parsed data from az" {

		$expectedValue = @{ Arguments = ('--%', '"vm" "list"') }
		$result = Invoke-AzCli vm list
		$result.Arguments | Should -Be $expectedValue.Arguments
		Should -Invoke az
	}
}
