Describe "AzureCli" {

	Context "With alias iaz" {

		Mock -ModuleName 'AzureCli' Invoke-AzCli {return "hi"}

		It "Invokes Invoke-AzCli" {
			$result = Invoke-AzCli

			$result | Should -Be "hi"

			Assert-MockCalled -ModuleName 'AzureCli' Invoke-AzCli
		}

	}

	Context "With Object Output" {
		$returnValue = "Hello from az cli"
		Mock -ModuleName 'AzureCli' az.exe {return "hi"}

		It "Fails for now" {
			$returnValue = "Hello from az cli"
			Invoke-AzCli | Should -Be $returnValue
			Assert-VerifiableMocks
		}

	}

}
