BeforeDiscovery {
}

Describe "Invoke-AzCli With Object Output" {

	BeforeAll {
		$jsonText = '{ "IsAz": true }'
		$convertedObject = [PsCustomObject]@{ IsConvertFromJson = $true }

		. $PSScriptRoot/Helpers/Az.ps1
		Mock az { $jsonText }
		Mock ConvertFrom-Json { $convertedObject }
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "Returns the parsed data from az" {

		$result = Invoke-AzCli vm list --show-details
		Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $InputObject -eq $jsonText }
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ') -eq '"vm" "list" "--show-details"' }
		$result | Should -Be $convertedObject
	}

	It "By default does not pass -NoEnumerate and -AsHashTable to ConvertFrom-Json" {

		$null = Invoke-AzCli one two three
		Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $NoEnumerate -eq $null -and $AsHashTable -eq $null }
		Should -Invoke az -Exactly 1
	}

	It "Passes -NoEnumerate to ConvertFrom-Json" {

		$null = Invoke-AzCli one two three -NoEnumerate
		Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $NoEnumerate -eq $true }
		Should -Invoke az -Exactly 1
	}

	It "Passes -AsHashTable to ConvertFrom-Json" {

		$null = Invoke-AzCli one two three -AsHashtable
		Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $AsHashTable -eq $true }
		Should -Invoke az -Exactly 1
	}
}

