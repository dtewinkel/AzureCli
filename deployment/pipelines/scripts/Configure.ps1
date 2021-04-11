[cmdletbinding()]
param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..'))
)

$toolsPath = Join-Path $RootPath tools
$reportGenerator = Join-Path $toolsPath reportgenerator.exe

@("PSScriptAnalyzer", "Pester@5.1.0") | ForEach-Object {
	$moduleSpec = $_ -split '@'
	switch ($moduleSpec.Length)
	{
		1 {
			$getParams = @{
				Name = $moduleSpec[0]
			}
			$installParams = @{
				Name = $moduleSpec[0]
			}
			$importParams = @{
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
			$importParams = @{
				Name = $moduleSpec[0];
				MinimumVersion = $moduleSpec[1]
				Scope = 'Local'
			}
		}

		Default {
			throw "Illegal module spec '$moduleSpec'. Can only contain one @."
		}

	}
	$moduleDefinition = Get-Module @getParams -ListAvailable
	if (-not $moduleDefinition)
	{
		Install-Module @installParams -Scope CurrentUser -Force -Verbose:$false
	}
	Import-Module @importParams
} | Format-Table -AutoSize

if (-not (Test-Path $reportGenerator))
{
	dotnet tool install dotnet-reportgenerator-globaltool --tool-path $toolsPath
}
