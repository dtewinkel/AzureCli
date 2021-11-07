[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', "Modules", "AzureCli")).Path
)

Get-ChildItem (Join-Path $ModuleFolder ArgumentCompleters *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
Get-ChildItem (Join-Path $ModuleFolder ArgumentsProcessing *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
Get-ChildItem (Join-Path $ModuleFolder Validation *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
