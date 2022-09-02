
Describe "Complete" {

	BeforeAll {
		. ./complete.ps1
	}

	It "Work" {

		$result = Complete "aaa bbb"

		Write-Host $result

		$result.ToSend | Should -Be "aaa"
	}
}
