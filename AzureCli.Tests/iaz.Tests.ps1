Describe "iaz" {

	It "should be an alias of Invoke-AzCli" {

		. $PSScriptRoot/Helpers/LoadModule.ps1

		$alias = Get-Alias iaz

		$alias.ReferencedCommand | Should -Be "Invoke-AzCli"
	}
}
