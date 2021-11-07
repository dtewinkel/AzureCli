[CmdletBinding()]
param (
	[Parameter()]
	[string] $ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', "AzureCLi")).Path
)

Describe "ArgumentCompleterSubscription" {

	BeforeAll {

		function az { $args }

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {

		$command = Get-Command ArgumentCompleterSubscription
		$command | Should -HaveParameter wordToComplete
	}

	Context "With subscriptions available" {

		BeforeAll {

			$subscriptionName1 = "Sub1"
			$subscriptionName2 = "anothersub"
			$subscriptionName3 = "My Demo Subscription"
			$subscriptionId1 = '2e7608f0-dcb1-4ce8-bd04-437d6cfc99d8'
			$subscriptionId2 = '348eb65a-4d5a-44c3-ba89-59aeffbe6eca'
			$subscriptionId3 = 'a6de7999-020b-473d-b853-5f19b1529f66'
			$SubscriptionJson = @"
			[
				{
					"name": "${subscriptionName1}",
					"id": "${subscriptionId1}"
				},
				{
					"name": "${subscriptionName2}",
					"id": "${subscriptionId2}"
				},
				{
					"name": "${subscriptionName3}",
					"id": "${subscriptionId3}"
				}
			]
"@
			Mock az { $SubscriptionJson }

		}

		It "should expand Subscription to values return by az" {

			$result = ArgumentCompleterSubscription -wordToComplete ''
			$result | Should -HaveCount 6
			$result[0].CompletionText | Should -Be $subscriptionName1
			$result[0].ListItemText | Should -Be $subscriptionName1
			$result[0].ToolTip | Should -Be "Subscription with name '${subscriptionName1}' (ID = '${subscriptionId1}')."
			$result[1].CompletionText | Should -Be $subscriptionName2
			$result[1].ListItemText | Should -Be $subscriptionName2
			$result[1].ToolTip | Should -Be "Subscription with name '${subscriptionName2}' (ID = '${subscriptionId2}')."
			$result[2].CompletionText | Should -Be "'${subscriptionName3}'"
			$result[2].ListItemText | Should -Be "${subscriptionName3}"
			$result[2].ToolTip | Should -Be "Subscription with name '${subscriptionName3}' (ID = '${subscriptionId3}')."
			$result[3].CompletionText | Should -Be $subscriptionId1
			$result[3].ListItemText | Should -Be $subscriptionId1
			$result[3].ToolTip | Should -Be "Subscription with ID '${subscriptionId1}' (name = '${subscriptionName1}')."
			$result[4].CompletionText | Should -Be $subscriptionId2
			$result[4].ListItemText | Should -Be $subscriptionId2
			$result[4].ToolTip | Should -Be "Subscription with ID '${subscriptionId2}' (name = '${subscriptionName2}')."
			$result[5].CompletionText | Should -Be $subscriptionId3
			$result[5].ListItemText | Should -Be $subscriptionId3
			$result[5].ToolTip | Should -Be "Subscription with ID '${subscriptionId3}' (name = '${subscriptionName3}')."

			Should -Invoke az -Times 1 -ParameterFilter { `
				$args[0] -eq 'account' -and $args[1] -eq 'list' `
				-and $args[2] -eq '--query' `
				-and $args[3] -eq '[].{ name: name, id: id }' `
			 }
		}

		It "should expand Subscription to values return by az, matching provided name filter" {

			$result = ArgumentCompleterSubscription -wordToComplete 'ano'

			$result | Should -HaveCount 1
			$result[0].CompletionText | Should -Be $subscriptionName2
			$result[0].ListItemText | Should -Be $subscriptionName2
			$result[0].ToolTip | Should -Be "Subscription with name '${subscriptionName2}' (ID = '${subscriptionId2}')."
		}

		It "should expand Subscription to values return by az, matching provided id filter" {

			$result = ArgumentCompleterSubscription -wordToComplete 'a6de'

			$result | Should -HaveCount 1
			$result[0].CompletionText | Should -Be $subscriptionId3
			$result[0].ListItemText | Should -Be $subscriptionId3
			$result[0].ToolTip | Should -Be "Subscription with ID '${subscriptionId3}' (name = '${subscriptionName3}')."
		}

		It "should expand Subscription to nothing, not matching provided filter" {

			$result = ArgumentCompleterSubscription -wordToComplete 'aaaa'

			$result | Should -BeNullOrEmpty
		}
	}

	Context "With no subscriptions available" {

		BeforeAll {

			Mock az { "[]" }
		}

		It "should expand Subscription to nothing" {

			$result = ArgumentCompleterSubscription -wordToComplete ''

			$result | Should -BeNullOrEmpty
		}
	}
}
