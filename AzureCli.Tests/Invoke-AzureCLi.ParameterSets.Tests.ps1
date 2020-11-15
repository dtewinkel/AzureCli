Describe "Invoke-AzCli with Interactive commands" {

	BeforeAll {

		. ./Helpers/Az.ps1

		Mock az { $Arguments -join " " }

		. ./Helpers/LoadModule.ps1
	}

	$combinations = @(
		@{ parameters = @{ "Help" = $true; "Raw" = $true } },
		@{ parameters = @{ "Help" = $true; "Output" = "json" } },
		@{ parameters = @{ "AsHashTable" = $true; "Output" = "json" } },
		@{ parameters = @{ "AsHashTable" = $true; "Raw" = $true } },
		@{ parameters = @{ "SuppressOutput" = $true; "Raw" = $true } },
		@{ parameters = @{ "NoEnumerate" = $true; "Output" = "none" } },
		@{ parameters = @{ "NoEnumerate" = $true; "Help" = $true } }
	)
	It "Fails if -Raw and -Help are combined" -TestCases $combinations {
		param($parameters)

		{ Invoke-AzCLi @parameters } | Should -Throw "*Parameter set cannot be resolved *"
	}
}
