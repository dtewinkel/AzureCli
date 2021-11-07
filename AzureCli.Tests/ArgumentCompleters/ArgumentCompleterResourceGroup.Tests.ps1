[CmdletBinding()]
param (
	[Parameter()]
	[string] $ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', "Modules", "AzureCLi")).Path
)

Describe "ArgumentCompleterResourceGroup" {

	BeforeAll {

		function az { $args }

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {

		$command = Get-Command ArgumentCompleterResourceGroup
		$command | Should -HaveParameter wordToComplete
		$command | Should -HaveParameter fakeBoundParameters
	}

	Context "For resource groups" {

		Context "With resource groups available" {

			BeforeAll {

				$resourceGroupName1 = "MyFirstResourceGroup"
				$resourceGroupName2 = "ResourceGroup2"
				$resourceGroupName3 = "SomethingElse"
				$resourceGroupsJson = @"
			[
				"$resourceGroupName1",
				"$resourceGroupName2",
				"$resourceGroupName3"
			]
"@
				Mock az { $resourceGroupsJson }

			}

			It "should expand resource groups to values return by az" {

				$result = ArgumentCompleterResourceGroup -wordToComplete ''

				$result | Should -HaveCount 3

				$result[0].CompletionText | Should -Be $resourceGroupName1
				$result[1].CompletionText | Should -Be $resourceGroupName2
				$result[2].CompletionText | Should -Be $resourceGroupName3
			}

			It "should expand resource groups to values return by az, matching provided name filter" {

				$result = ArgumentCompleterResourceGroup -wordToComplete '*els'

				$result | Should -HaveCount 1
				$result[0].CompletionText | Should -Be $resourceGroupName3
			}

			It "should expand resource groups to nothing, not matching provided filter" {

				$result = ArgumentCompleterResourceGroup -wordToComplete 'aaaa'

				$result | Should -BeNullOrEmpty
			}

			It "should expand resource groups to nothing, not matching provided filter" {

				$subscriptionName = 'MyPrecious'

				$result = ArgumentCompleterResourceGroup -wordToComplete 'Res' -fakeBoundParameters @{ Subscription = $subscriptionName }

				$result | Should -HaveCount 1
				$result[0].CompletionText | Should -Be $resourceGroupName2
				Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains(" --subscription `"${subscriptionName}`"") }
			}
		}

		Context "With no resource groups available" {

			BeforeAll {

				Mock az { "[]" }
			}

			It "should expand resource groups to nothing" {

				$result = ArgumentCompleterResourceGroup -wordToComplete ''

				$result | Should -BeNullOrEmpty
			}
		}
	}
}
