Describe "Complete" {

	BeforeAll {
		. $PSScriptRoot/complete.ps1
	}

	Context "with cursor at end of parameters" {

		It "uses [<commands>] with filter [<filter>] for parameters [<parameters>]" -TestCases @(
			@{ parameters = ""; commands = ""; filter = "*" }
			@{ parameters = "aaa"; commands = ""; filter = "aaa*" }
			@{ parameters = "aaa "; commands = "aaa"; filter = "*" }
			@{ parameters = "aaa bbb"; commands = "aaa"; filter = "bbb*"}
			@{ parameters = "aaa bbb "; commands = "aaa bbb"; filter = "*" }
			@{ parameters = "aaa bbb -ccc"; commands = "aaa bbb"; filter = "-ccc*" }
			@{ parameters = "aaa bbb -ccc "; commands = "aaa bbb"; filter = "*" }
			@{ parameters = "aaa bbb -ccc --"; commands = "aaa bbb"; filter = "--*" }
			@{ parameters = "aaa bbb -ccc -ddd "; commands = "aaa bbb"; filter = "*" }
		) {
			param($parameters, $commands, $filter)

			$result = Complete $parameters

			Write-Host $result

			$result.ToSend | Should -Be $commands -Because "commands should match"
			$result.Filter | Should -Be $filter -Because "filter should match"
		}
	}
}
