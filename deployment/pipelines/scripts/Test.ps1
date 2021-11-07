#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.3.1" }

param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..')),

	[Parameter()]
	[String] $ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..', 'Modules', 'AzureCli')),

	[Parameter()]
	[String] $TestPath = (Resolve-Path (Join-Path $RootPath 'AzureCli.Tests')),

	[Parameter()]
	[String] $TestOutput = (Join-Path $RootPath TestResults TestResults.Pester.xml),

	[Parameter()]
	[String] $CoverageOutput = (Join-Path $RootPath TestResults Coverage.Pester.xml),

	[Parameter()]
	[String] $CoverageOutputFormat,

	[Parameter()]
	[String] $OutputVerbosity = 'Detailed'
)

$testOutputFolder =  ([System.IO.Fileinfo]$TestOutput).DirectoryName

$configuration = New-PesterConfiguration

$container = New-PesterContainer -Path $testPath -Data @{ ModuleFolder = $moduleFolder }
$configuration.Run.Container = $container

$configuration.TestResult.Enabled = $true
$configuration.TestResult.OutputPath = $TestOutput
$configuration.Output.Verbosity = $OutputVerbosity
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = "${moduleFolder}/*.psm1", "${moduleFolder}/*-*.ps1", "${moduleFolder}/*.ps1", "${moduleFolder}/*/*.ps1"
$configuration.CodeCoverage.OutputPath = $CoverageOutput
$configuration.CodeCoverage.UseBreakpoints = $false
$configuration.TestDrive.Enabled = $false
$configuration.TestRegistry.Enabled = $false
if($CoverageOutputFormat)
{
	$configuration.CodeCoverage.OutputFormat = $CoverageOutputFormat
}

$null = New-Item -ItemType directory -Path $testOutputFolder -Force

Invoke-Pester -Configuration $configuration
