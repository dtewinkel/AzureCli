[cmdletbinding()]
param()

Write-Host "Configuring..."
& $PSScriptRoot/Configure.ps1
Write-Host "Building..."
& $PSScriptRoot/Build.ps1 -CleanupRepository
Write-Host "Analyzing scripts..."
& $PSScriptRoot/AnalyzeScripts.ps1
Write-Host "Done!"
