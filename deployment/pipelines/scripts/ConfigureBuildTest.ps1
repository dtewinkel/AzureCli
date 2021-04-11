[cmdletbinding()]
param()

Write-Host "Configuring..."
. $PSScriptRoot/Configure.ps1
Write-Host "Building..."
. $PSScriptRoot/Build.ps1 -CleanupRepository
Write-Host "Analyzing scripts..."
. $PSScriptRoot/AnalyzeScripts.ps1
Write-Host "Testing..."
. $PSScriptRoot/Test.ps1
Write-Host "Create Reporting..."
. $PSScriptRoot/Report.ps1
Write-Host "Done!"
