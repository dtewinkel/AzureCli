Get-ChildItem (Join-Path $PSScriptRoot ArgumentCompleters *.ps1) | ForEach-Object FullName | Resolve-Path | Import-Module
Get-ChildItem (Join-Path $PSScriptRoot ArgumentsProcessing *.ps1) | ForEach-Object FullName | Resolve-Path | Import-Module
Get-ChildItem (Join-Path $PSScriptRoot Validation *.ps1) | ForEach-Object FullName | Resolve-Path | Import-Module
Get-ChildItem (Join-Path $PSScriptRoot *.ps1) | ForEach-Object FullName | Resolve-Path | Import-Module

$moduleData = Import-PowerShellDataFile (Join-Path $PSScriptRoot AzureCLi.psd1)

$moduleData.FunctionsToExport | ForEach-Object { Export-ModuleMember -Function $PSItem }
$moduleData.AliasesToExport | ForEach-Object { Export-ModuleMember -Alias $PSItem }
