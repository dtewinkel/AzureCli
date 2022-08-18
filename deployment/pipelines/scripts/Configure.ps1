[cmdletbinding()]
param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..'))
)

$toolsPath = Join-Path $RootPath tools
$reportGenerator = Join-Path $toolsPath reportgenerator.exe

@("PSScriptAnalyzer", "Pester@5.3.3") | ForEach-Object {
	$moduleSpec = $_ -split '@'
	$moduleName = $moduleSpec[0]
	switch ($moduleSpec.Length)
	{
		1 {
			$getParams = @{
				Name = $moduleName
			}
			$installParams = @{
				Name = $moduleName
			}
			$importParams = @{
				Name = $moduleName
			}
		}

		2 {
			$fullVersion = $moduleSpec[1]
			$versionSpec = $fullVersion -split '-'
			$version = $versionSpec[0]
			$getParams = @{
				FullyQualifiedName = @{
					ModuleName = $moduleName
					ModuleVersion = $version
				}
			}
			$installParams = @{
				Name = $moduleName
				MinimumVersion = $fullVersion
				AllowPrerelease = $versionSpec.Length -gt 1
				}
			$importParams = @{
				FullyQualifiedName = @{
					ModuleName = $moduleName
					ModuleVersion = $version
				}
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
