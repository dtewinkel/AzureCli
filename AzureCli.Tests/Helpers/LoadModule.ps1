$modulePath = (Resolve-Path .).Path
if(-not ($env:PSModulePath.Contains($modulePath)))
{
	$env:PSModulePath = $modulePath + ";" + $env:PSModulePath
}
Remove-Module AzureCLi -Force -ErrorAction SilentlyContinue

Import-Module AzureCLi -Force
