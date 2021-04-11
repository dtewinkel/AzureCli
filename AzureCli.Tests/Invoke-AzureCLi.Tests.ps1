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

	It "Suppresses the --verbose parameter if CliVerbosity is Default" {

		$null = Invoke-AzCli vm list -Verbose -CliVerbosity Default
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -notcontains '"--verbose"' }
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking ["vm" "list"]'}
	}

	It "Include the --only-show-errors parameter if CliVerbosity is NoWarnings" {

		$null = Invoke-AzCli vm list -CliVerbosity verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--verbose"' }
	}

	It "Include the --verbose parameter if CliVerbosity is Verbose" {

		$null = Invoke-AzCli vm list -CliVerbosity verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--verbose"' }
	}

	It "Include the --debug parameter if CliVerbosity is Debug" {

		$null = Invoke-AzCli vm list -CliVerbosity debug
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -ccontains '"--debug"' }
	}


	It "Include the debug parameter if CliVerbosity is debug and -Verbose is specified" {

		$null = Invoke-AzCli vm list -CliVerbosity debug -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -notcontains '"--verbose"' -and $args -ccontains '"--debug"' }
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking ["vm" "list" "--debug"]'}
	}
}
