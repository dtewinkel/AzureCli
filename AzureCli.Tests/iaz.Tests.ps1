[CmdletBinding()]
param (
	[Parameter()]
	[string] $ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'AzureCli')).Path
)

Describe "iaz" {

	It "should be an alias of Invoke-AzCli" {

		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder

		$alias = Get-Alias iaz

		$alias.ReferencedCommand | Should -Be "Invoke-AzCli"
	}
}
