$moduleNames = @("PSScriptAnalyzer", "Pester")
foreach($moduleName in $moduleNames)
{
	$module = Get-Module $moduleName -ListAvailable
	if(-not $module)
	{
		Install-Module $moduleName -Scope CurrentUser -Force -PassThru
	}
} | Format-Table -AutoSize
