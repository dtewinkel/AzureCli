#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.1.0" }

param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..')),

	[Parameter()]
	[String] $TestOutput = (Join-Path $RootPath TestResults TestResults.Pester.xml),

	[Parameter()]
	[String] $CoverageOutput = (Join-Path $RootPath TestResults Coverage.Pester.xml)
)

$modulesFolder = Join-Path $RootPath Modules
$moduleFolder = Join-Path $modulesFolder AzureCli
$testFolder = Join-Path $RootPath AzureCli.Tests
$testOutputFolder = Join-Path $RootPath TestResults

Import-Module Pester

$configuration = [PesterConfiguration]@{
		TestResult = @{
				Enabled = $true
				OutputPath = $TestOutput
		}
		Output = @{
				Verbosity = 'Detailed'
		}
		CodeCoverage = @{
			Enabled = $true
			Path = "${moduleFolder}/*.psm1", "${moduleFolder}/*-*.ps1", "${moduleFolder}/*/*.ps1"
			OutputPath = $CoverageOutput
		}
}

$null = New-Item -ItemType directory -Path $testOutputFolder -Force

Push-Location $testFolder

try
{
	Invoke-Pester -Configuration $configuration
}
finally
{
	Pop-Location
}
