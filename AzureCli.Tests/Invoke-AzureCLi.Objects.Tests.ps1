Describe "Invoke-AzCli With Object Output" {

	Context "With default output" {

		BeforeAll {

			. $PSScriptRoot/Helpers/Az.ps1

			Mock az { @{ Arguments = $Arguments } | ConvertTo-Json }

			. $PSScriptRoot/Helpers/LoadModule.ps1
		}

		It "Returns the passed query to az" {

			$expectedValue = @{ Arguments = '"version"', '"--verbose"', '"--query"', '"{ name }"' }
			$result = Invoke-AzCli version -Query '{ name }' -Verbose
			$result.Arguments | Should -Be $expectedValue.Arguments
		}

		It "Returns the parsed data from az" {

			$expectedValue = @{ Arguments = '"vm"', '"list"' }
			$result = Invoke-AzCli vm list
			$result.Arguments | Should -Be $expectedValue.Arguments
			Should -Invoke az
		}
	}
}
