Describe "Invoke-AzCli general handling" {

	$jsonText = '{ "IsAz": true }'

	BeforeAll {

		. $PSScriptRoot/Helpers/Az.ps1
		Mock az { $jsonText }
		Mock Write-Verbose
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "throw an exception if az is not found" {

		Mock Get-Command { $Null } -ParameterFilter { $name -eq 'az' }
		{ Invoke-AzCli test -Query '{ name }' } | Should -Throw "The az CLI is not found. Please go to*"
	}


	It "Returns the passed query to az" {

		$null = Invoke-AzCli test -Query '{ name }'
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains('"--query" "{ name }"') }
	}

	It "Sets the Subscription parameter" {

		$null = Invoke-AzCli vm list -Subscription sub
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains('"--subscription" "sub"') }
	}

	It "Sets the ResourceGroup parameter" {

		$null = Invoke-AzCli vm list -ResourceGroup rg
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains('"--resource-group" "rg"') }
	}

	It "Sets the SuppressCliWarnings parameter" {

		$null = Invoke-AzCli vm list -SuppressCliWarnings
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--only-show-errors"' }
	}

	It "Sets the Verbose parameter" {

		$null = Invoke-AzCli vm list -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--verbose"' }
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking ["vm" "list" "--verbose"]'}
	}
}
