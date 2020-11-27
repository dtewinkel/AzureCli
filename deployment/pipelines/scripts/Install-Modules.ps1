@("PSScriptAnalyzer", "Pester@5.1.0") | ForEach-Object {
	$moduleSpec = $_ -split '@'
	switch ($moduleSpec.Length) {
		1 {
			$getParams = @{
				Name = $moduleSpec[0]
			}
			$installParams = @{
				Name = $moduleSpec[0]
			}
		}
		2 {
			$getParams = @{
				FullyQualifiedName = @{
					ModuleName = $moduleSpec[0];
					ModuleVersion = $moduleSpec[1]
				}
			}
			$installParams = @{
				Name = $moduleSpec[0];
				MinimumVersion = $moduleSpec[1]
			}
		}

	}
	$module = Get-Module @getParams -ListAvailable
	if (-not $module) {
		Install-Module @installParams -Scope CurrentUser -Force -PassThru
	}
} | Format-Table -AutoSize
