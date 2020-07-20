Set-Location $PSScriptRoot

Get-ChildItem *.ps1 | ForEach-Object Name | Resolve-Path | Import-Module

Export-ModuleMember -Function 'Invoke-AzCli'
Export-ModuleMember -Alias 'iaz'
