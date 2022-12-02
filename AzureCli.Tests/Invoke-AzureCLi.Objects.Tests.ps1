[CmdletBinding()]
param (
	[Parameter()]
	[string] $ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'AzureCli')).Path
)

Describe "Invoke-AzCli With Object Output" {

	BeforeAll {

		$old_PSNativeCommandArgumentPassing = Get-Variable -Name PSNativeCommandArgumentPassing -ValueOnly -ErrorAction SilentlyContinue
		$global:PSNativeCommandArgumentPassing = "Windows"

		$jsonText = '{ "IsAz": true }'
		$convertedObject = [PsCustomObject]@{ IsConvertFromJson = $true }
		function az {}

		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder

		Mock az { $jsonText } -ModuleName 'AzureCli'

		$additionalArguments = @{}
		if ($PSVersionTable.PSVersion.Major -lt 7)
		{
			$additionalArguments = @{ RemoveParameterValidation =  'Depth' }
		}
		Mock ConvertFrom-Json { $convertedObject } @additionalArguments -ModuleName 'AzureCli'
	}

	AfterAll {

		if($old_PSNativeCommandArgumentPassing)
		{
			$global:PSNativeCommandArgumentPassing = $old_PSNativeCommandArgumentPassing
		}
		else
		{
			Clear-Variable PSNativeCommandArgumentPassing -Scope Global
		}
	}

	It "Returns the parsed data from az" {

		$result = Invoke-AzCli vm list --show-details

		Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $InputObject -eq $jsonText } -ModuleName 'AzureCli'
		Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ') -eq '"vm" "list" "--show-details"' } -ModuleName 'AzureCli'
		$result | Should -Be $convertedObject
	}

	It "By default does not pass -NoEnumerate and -AsHashTable to ConvertFrom-Json" {

		Invoke-AzCli one two three

		Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $NoEnumerate -eq $null -and $AsHashTable -eq $null } -ModuleName 'AzureCli'
		Should -Invoke az -Exactly 1 -ModuleName 'AzureCli'
	}

	It "Passes -NoEnumerate to ConvertFrom-Json" -Skip:($PSVersionTable.PSVersion.Major -lt 7) {

		Invoke-AzCli one two three -NoEnumerate

		Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $NoEnumerate -eq $true } -ModuleName 'AzureCli'
		Should -Invoke az -Exactly 1 -ModuleName 'AzureCli'
	}

	It "Passes -AsHashTable to ConvertFrom-Json" {

		Invoke-AzCli one two three -AsHashtable

		Should -Invoke ConvertFrom-Json -Exactly 1 -ParameterFilter { $AsHashTable -eq $true } -ModuleName 'AzureCli'
		Should -Invoke az -Exactly 1 -ModuleName 'AzureCli'
	}
}

