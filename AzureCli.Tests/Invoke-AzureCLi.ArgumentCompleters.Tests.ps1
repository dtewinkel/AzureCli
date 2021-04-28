Describe "Invoke-AzCli with argument completion" {

	BeforeAll {

		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	Context "For subscritions" {

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

				$cmd = "Invoke-AzCli -Subscription "
				$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
				$result.CompletionMatches | Should -HaveCount 6
				$result.CompletionMatches[0].CompletionText | Should -Be $subscriptionName1
				$result.CompletionMatches[1].CompletionText | Should -Be $subscriptionName2
				$result.CompletionMatches[2].CompletionText | Should -Be "'${subscriptionName3}'"
				$result.CompletionMatches[3].CompletionText | Should -Be $subscriptionId1
				$result.CompletionMatches[4].CompletionText | Should -Be $subscriptionId2
				$result.CompletionMatches[5].CompletionText | Should -Be $subscriptionId3
			}

			It "should expand Subscription to values return by az, matching provided name filter" {

				$cmd = "Invoke-AzCli -Subscription ano"
				$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
				$result.CompletionMatches | Should -HaveCount 1
				$result.CompletionMatches[0].CompletionText | Should -Be $subscriptionName2
			}

			It "should expand Subscription to values return by az, matching provided id filter" {

				$cmd = "Invoke-AzCli -Subscription a6de"
				$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
				$result.CompletionMatches | Should -HaveCount 1
				$result.CompletionMatches[0].CompletionText | Should -Be $subscriptionId3
			}

			It "should expand Subscription to nothing, not matching provided filter" {

				$cmd = "Invoke-AzCli -Subscription aaaa"
				{ TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length } | Should -Throw
			}
		}

		Context "With no subscriptions available" {

			BeforeAll {

				Mock az { "[]" }
			}

			It "should expand Subscription to nothing" {

				$cmd = "Invoke-AzCli -Subscription "
				{ TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length } | Should -Throw
			}
		}
	}
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

			$cmd = "Invoke-AzCli -ResourceGroup "
			$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
			$result.CompletionMatches | Should -HaveCount 3
			$result.CompletionMatches[0].CompletionText | Should -Be $resourceGroupName1
			$result.CompletionMatches[1].CompletionText | Should -Be $resourceGroupName2
			$result.CompletionMatches[2].CompletionText | Should -Be $resourceGroupName3
		}

		It "should expand resource groups to values return by az, matching provided name filter" {

			$cmd = "Invoke-AzCli -ResourceGroup *els"
			$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
			$result.CompletionMatches | Should -HaveCount 1
			$result.CompletionMatches[0].CompletionText | Should -Be $resourceGroupName3
		}

		It "should expand resource groups to nothing, not matching provided filter" {

			$cmd = "Invoke-AzCli -ResourceGroup aaaa"
			{ TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length } | Should -Throw
		}

		It "should expand resource groups to nothing, not matching provided filter" {

			$subscriptionName = 'MyPrecious'
			$cmd = "Invoke-AzCli -Subscription $subscriptionName -ResourceGroup Res"
			$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
			$result.CompletionMatches | Should -HaveCount 1
			$result.CompletionMatches[0].CompletionText | Should -Be $resourceGroupName2
			Should -Invoke az -Exactly 1 -ParameterFilter { ($args -join ' ').Contains(" --subscription ${subscriptionName}") }
		}
	}

	Context "With no resource groups available" {

		BeforeAll {

			Mock az { "[]" }
		}

		It "should expand resource groups to nothing" {

			$cmd = "Invoke-AzCli -ResourceGroup Res"
			{ TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length } | Should -Throw

		}
	}
}
