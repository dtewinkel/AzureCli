[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', "Modules", "AzureCli")).Path
)

$modulePath = (Resolve-Path (Join-Path $ModuleFolder '..')).Path
if(-not ($env:PSModulePath.Contains($modulePath)))
{
	$env:PSModulePath = $modulePath + ";" + $env:PSModulePath
}

Remove-Module AzureCli -Force -ErrorAction SilentlyContinue
Import-Module AzureCli -Force
