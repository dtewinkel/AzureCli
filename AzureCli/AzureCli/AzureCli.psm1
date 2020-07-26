Get-ChildItem (Join-Path $PSScriptRoot *.ps1) | ForEach-Object Name | Resolve-Path | Import-Module

Export-ModuleMember -Function 'Invoke-AzCli'
Export-ModuleMember -Alias 'iaz'
