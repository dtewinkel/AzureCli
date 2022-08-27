[cmdletbinding()]
param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..'))
)

$toolsFolder = Join-Path $RootPath tools
$reportGenerator = Join-Path $toolsFolder reportgenerator.exe

$modulesFolder = Join-Path $RootPath Modules
$testOutputFolder = Join-Path $RootPath TestResults
$coverageOutput = Join-Path $testOutputFolder Coverage.Pester.xml

$modulePaths = (Get-ChildItem "${modulesFolder}" -Directory -Recurse).FullName -join ';'
& $reportGenerator "-targetdir:${testOutputFolder}" "-reports:${coverageOutput}" "-sourcedirs:${modulePaths}" -verbosity:warning
Write-Host "Coverage report written to ${testOutputFolder}/index.htm"
