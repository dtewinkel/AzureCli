[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',
		Justification='To test not showing SecureString Values in verbose output.')]
param()

Describe "Invoke-AzCli general handling" {

	$jsonText = '{ "IsAz": true }'

	BeforeAll {

		. $PSScriptRoot/Helpers/Az.ps1
		Mock az { $jsonText }
		Mock Write-Verbose
		Mock Write-Warning
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "throw an exception if az is not found" {

		Mock Get-Command { $Null } -ParameterFilter { $name -eq 'az' }
		{ Invoke-AzCli test -Query '{ name }' } | Should -Throw "The az CLI is not found. Please go to*"
	}

	It "Returns the passed query to az" {

		Invoke-AzCli test -Query '{ name }'
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains('"--query" "{ name }"') }
	}

	It "Sets the Subscription parameter" {

		Invoke-AzCli vm list -Subscription sub
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains('"--subscription" "sub"') }
	}

	It "Sets the ResourceGroup parameter" {

		Invoke-AzCli vm list -ResourceGroup rg
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains('"--resource-group" "rg"') }
	}

	It "Mask a SecureString in the verbose output" {

		$plainText = "PlainTextSecret"
		$secureString = ConvertTo-SecureString -AsPlainText $plainText

		Invoke-AzCli something --password $secureString -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains("`"--password`" `"${plainTExt}`"") }
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "something" "--password" ******** "--verbose"]' }
	}


	It "Sets the SuppressCliWarnings parameter" {

		Invoke-AzCli vm list -SuppressCliWarnings
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--only-show-errors"' }
		Should -Invoke Write-Warning -ParameterFilter { $Message -like "'-SuppressCliWarnings' is deprecated. Please use '-CliVerbosity NoWarnings' instead.*" }
	}

	It "Sets the Verbose parameter" {

		Invoke-AzCli vm list -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--verbose"' }
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list" "--verbose"]' }
	}

	It "Suppresses the --verbose parameter if CliVerbosity is Default" {

		Invoke-AzCli vm list -Verbose -CliVerbosity Default
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -notcontains '"--verbose"' }
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list"]' }
	}

	Context "With `$AzCliVerbosityPreference set." {

		BeforeAll {
			$OriginalAzCliVerbosityPreference = $AzCliVerbosityPreference
			$global:AzCliVerbosityPreference = 'Default'
		}

		It "Suppresses the --verbose parameter if CliVerbosity is set globally to Default" {

			Invoke-AzCli vm list -Verbose
			Should -Invoke az -Exactly 1 -ParameterFilter { $args -notcontains '"--verbose"' }
			Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list"]' }
		}

		It "Include the --only-show-errors parameter if CliVerbosity is NoWarnings and CliVerbosity is set globally to Default" {

			Invoke-AzCli vm list -CliVerbosity NoWarnings
			Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--only-show-errors"' }
		}

		AfterAll {
			if ($OriginalAzCliVerbosityPreference)
			{
				$global:AzCliVerbosityPreference = $OriginalAzCliVerbosityPreference
			}
			else
			{
				Clear-Variable AzCliVerbosityPreference -Scope Global
			}
		}
	}

	It "Include the --only-show-errors parameter if CliVerbosity is NoWarnings" {

		Invoke-AzCli vm list -CliVerbosity NoWarnings
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--only-show-errors"' }
	}

	It "Include the --verbose parameter if CliVerbosity is Verbose" {

		Invoke-AzCli vm list -CliVerbosity verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -contains '"--verbose"' }
	}

	It "Include the --debug parameter if CliVerbosity is Debug" {

		Invoke-AzCli vm list -CliVerbosity debug
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -ccontains '"--debug"' }
	}

	It "Include the debug parameter if CliVerbosity is Debug and -Verbose is specified" {

		Invoke-AzCli vm list -CliVerbosity Debug -Verbose
		Should -Invoke az -Exactly 1 -ParameterFilter { $args -notcontains '"--verbose"' -and $args -ccontains '"--debug"' }
		Should -Invoke Write-Verbose -ParameterFilter { $Message -eq 'Invoking [az "vm" "list" "--debug"]' }
	}
}
