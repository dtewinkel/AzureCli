[cmdletbinding()]
param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..')),

	[Parameter()]
	$GitVersionJson,

	[Parameter()]
	[Switch] $CleanupRepository
)

$companyName = "Daniël te Winkel"
$author = "Daniël te Winkel"

$moduleName = "AzureCli"
$repositoryName = "Local${moduleName}Repo"
$sourcePath = Join-Path $RootPath $moduleName
$moduleRootPath = Join-Path $RootPath "Modules"
$repositoryPath = Join-Path $RootPath "Repositories" $repositoryName

if($GitVersionJson)
{
	$Gitversion = $GitVersionJson | ConvertFrom-Json
}
else
{
	$Gitversion = [PSCustomObject]@{
		CommitDate = [DateTime]::Today.ToString("yyyy-MM-dd")
		MajorMinorPatch = "0.0.1"
		NuGetPreReleaseTagV2 = "local-build"
	}
}

try
{
	if(-not (Test-Path $repositoryPath))
	{
		$null = New-Item -ItemType directory -Path $repositoryPath
	}

	$repo = Get-PSRepository -Name $repositoryName -ErrorAction SilentlyContinue

	if(-not $repo)
	{
		Register-PSRepository -Name $repositoryName -SourceLocation $repositoryPath -InstallationPolicy Trusted
		Write-Verbose "Registered repository '${repositoryName}' to directory '${repositoryPath}'."
	}

	$modulePath = Join-Path $moduleRootPath $moduleName
	if(-not (Test-Path $moduleRootPath))
	{
		$null = New-Item -ItemType directory -Path $moduleRootPath
	}

	if(Test-Path $modulePath)
	{
		Remove-Item $modulePath -Recurse -Force
	}

	Copy-Item $sourcePath $moduleRootPath -Recurse

	$moduleData = Join-Path $modulePath "${moduleName}.psd1"

	$version = $Gitversion.MajorMinorPatch
	$nugetPath = (join-Path $repositoryPath "${moduleName}.${version}.nupkg")
	$year = ([DateTime]($GitVersion.CommitDate)).Year
	$copyright = "Copyright © ${year}, ${companyName}. All rights reserved."
	$updateParameters = @{
		Path = $moduleData
		ModuleVersion = $GitVersion.MajorMinorPatch
		Copyright = $copyright
		Author = $author
		CompanyName = $companyName
	}
	if($GitVersion.NuGetPreReleaseTagV2 -ne "")
	{
		$preReleaseTag = $GitVersion.NuGetPreReleaseTagV2 -replace '[^a-zA-Z0-9]', ''
		$updateParameters.Add("Prerelease", $preReleaseTag)
		$nugetPath = (join-Path $repositoryPath "${moduleName}.${version}-${preReleaseTag}.nupkg")
	}
	Update-ModuleManifest @updateParameters
	# make sure the ModuleManifest is in the right encoding.
	$manifest = Get-Content $moduleData
	$manifest | Out-File -Encoding utf8BOM $moduleData

	if (Test-Path $nugetPath)
	{
		Remove-Item $nugetPath -Force
	}

	Publish-Module -Path $modulePath -Repository $repositoryName -Force

	if (-not (Test-Path $nugetPath))
	{
		throw "${nugetPath} was not created!"
	}
}
finally
{
	if($CleanupRepository.IsPresent)
	{
		$repo = Get-PSRepository -Name $repositoryName -ErrorAction SilentlyContinue

		if($repo)
		{
			Unregister-PSRepository -Name $repositoryName
			Write-Verbose "Unregistered repository '${repositoryName}'."
		}
	}
}
