Describe "Invoke-AzCli" {


	BeforeAll {

		function az
		{
			param(
				[Parameter(ValueFromRemainingArguments)]
				[string[]] $Arguments
			)
		}

		$env:PSModulePath = (Resolve-Path .).Path + ";" + (Resolve-Path .).Path + "\bin\Release;" + $env:PSModulePath
	}

	Context "With Object Output" {

		BeforeAll {
			Remove-Module AzureCLi -Force

			Mock az { @{ Arguments = $Arguments } | ConvertTo-Json }

			Import-Module AzureCLi -Force
		}

		It "Return the parsed data from az" {

			$expectedValue = @{ Arguments = ('--version') }
			$result = Invoke-AzCli --version
			$result.Arguments | Should -Be $expectedValue.Arguments
			Should -Invoke az
		}

		It "Return the passes query to az" {

			$expectedValue = @{ Arguments = ('version', '--verbose', '--query', '{ name }') }
			$result = Invoke-AzCli version -Query '{ name }' -Verbose
			$result.Arguments | Should -Be $expectedValue.Arguments
			Should -Invoke az
		}
	}

	Context "With Raw Output" {

		BeforeAll {
			Remove-Module AzureCLi -Force

			Mock az { $Arguments -join "," }

			Import-Module AzureCLi -Force
		}

		It "Return the raw data from az" {

			$expectedValue = '--version'
			$result = iaz --version -Raw
			$result | Should -Be $expectedValue
			Should -Invoke az
		}
	}
}
