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

	Context "With Json output options" {

		BeforeAll {

			. $PSScriptRoot/Helpers/Az.ps1

			Mock az { $Arguments | ConvertTo-Json -AsArray }

			. $PSScriptRoot/Helpers/LoadModule.ps1
		}

		It "Returns the passed array as array when -NoEnumerate is given" {

			$expectedValue = @( '"one"', '"two"', '"three"' )
			$result = Invoke-AzCli one two three -NoEnumerate
			$result | Should -Be $expectedValue
			$result.GetType() | Should -Be 'System.Object[]'
		}

		It "Returns the passed array as array" {

			$expectedValue = @( '"one"', '"two"', '"three"' )
			$result = Invoke-AzCli one two three
			$result | Should -Be $expectedValue
			$result.GetType() | Should -Be 'System.Object[]'
		}

		It "Returns the passed single parameter as array when -NoEnumerate is given" {

			$expectedValue = @( '"One"' )
			$result = Invoke-AzCli One -NoEnumerate
			$result | Should -Be $expectedValue
			$result.GetType() | Should -Be 'System.Object[]'
		}

		It "Returns the passed single parameter as string" {

			$expectedValue = '"One"'
			$result = Invoke-AzCli One
			$result | Should -Be $expectedValue
			$result.GetType() | Should -Be 'string'
		}
	}
}
