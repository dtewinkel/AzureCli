#Requires -Module PSScriptAnalyzer

[cmdletbinding()]
param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..'))
)

$modulesFolder = Join-Path $RootPath Modules
$moduleFolder = Join-Path $modulesFolder AzureCLi
$testFolder = Join-Path $RootPath AzureCli.Tests

Invoke-ScriptAnalyzer (Join-Path -Path $moduleFolder -ChildPath *.ps1) -ExcludeRule PSReviewUnusedParameter, PSUseShouldProcessForStateChangingFunctions
Invoke-ScriptAnalyzer $testFolder -Severity Error

