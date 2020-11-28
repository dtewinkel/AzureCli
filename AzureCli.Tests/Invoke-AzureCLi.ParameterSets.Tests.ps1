Describe "Invoke-AzCli with Interactive commands" {

	BeforeAll {

		. $PSScriptRoot/Helpers/Az.ps1

		Mock az { $Arguments -join " " }

		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	$combinations = @(
		@{ first = "Help"; second = "SuppressOutput"; secondValue = $true }
		@{ first = "Help"; second = "AsHashTable"; secondValue = $true }
		@{ first = "Help"; second = "NoEnumerate"; secondValue = $true }
		@{ first = "Help"; second = "Raw"; secondValue = $true }
		@{ first = "Help"; second = "Output"; secondValue = 'json' }
		@{ first = "Raw"; second = "SuppressOutput"; secondValue = $true }
		@{ first = "Raw"; second = "AsHashTable"; secondValue = $true }
		@{ first = "Raw"; second = "NoEnumerate"; secondValue = $true }
		@{ first = "Raw"; second = "Output"; secondValue = 'json' }
		@{ first = "SuppressOutput"; second = "AsHashTable"; secondValue = $true }
		@{ first = "SuppressOutput"; second = "NoEnumerate"; secondValue = $true }
		@{ first = "SuppressOutput"; second = "Output"; secondValue = 'json' }
		@{ first = "AsHashTable"; second = "Output"; secondValue = 'json' }
		@{ first = "NoEnumerate"; second = "Output"; secondValue = 'json' }
	)
	It "Fails with combined parameters: <first>, <second>" -TestCases $combinations {
		param($first, $second, $secondValue)

		$parameters = @{ $first = $true; $second = $secondValue }
		{ Invoke-AzCLi @parameters } | Should -Throw "*Parameter set cannot be resolved *"
	}

	$combinations = @(
		@{ first = "SuppressOutput"; firstValue = $true; second = "--output"; secondValue = 'json' }
		@{ first = "Output"; firstValue = 'json'; second = "--output"; secondValue = 'json' }
		@{ first = "Subscription"; firstValue = 'sub'; second = "--subscription"; secondValue = 'sub' }
		@{ first = "ResourceGroup"; firstValue = 'sub'; second = "--resource-group"; secondValue = 'sub' }
		@{ first = "Query"; firstValue = 'q'; second = "--query"; secondValue = 'q' }
	)
	It "Fails with combined parameters: <first>, <second>" -TestCases $combinations {
		param($first, $firstvalue, $second, $secondValue)

		$firstParameter = @{ $first = $firstvalue }
		$secondParameter = @( $second )
		if($secondValue)
		{
			$secondParameter += $secondValue
		}
		$expected = "Both -${first} and ${second} are provided as parameter. This is not allowed."
		{ Invoke-AzCLi @firstParameter @secondParameter } | Should -Throw $expected
	}
}
