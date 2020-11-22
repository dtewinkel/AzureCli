[cmdletbinding()]
param(
	[Parameter()]
	[String] $ModuleName = "AzureCli",

	[Parameter()]
	[String] $CompanyName = "Daniël te Winkel",

	[Parameter()]
	[String] $Author = "Daniël te Winkel",

	[Parameter()]
	[String] $SourcePath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..', $ModuleName)),

	[Parameter()]
	[String] $ModuleRootPath = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..')) "Modules"),

	[Parameter()]
	[String] $RepositoryName = "Local${ModuleName}PowerShell",

	[Parameter()]
	[String] $RepositoryPath = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..')) "Repositories" $RepositoryName),

	[Parameter()]
	$GitVersionJson,

	[Parameter()]
	[Switch] $CleanupRepository
)

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
	if(-not (Test-Path $RepositoryPath))
	{
		$null = mkdir $RepositoryPath
	}

	$repo = Get-PSRepository -Name $RepositoryName -ErrorAction SilentlyContinue

	if(-not $repo)
	{
		Register-PSRepository -Name $RepositoryName -SourceLocation $RepositoryPath -InstallationPolicy Trusted
		Write-Verbose "Registered repository '${RepositoryName}' to directory '${RepositoryPath}'."
	}

	$modulePath = Join-Path $ModuleRootPath $ModuleName
	if(-not (Test-Path $ModuleRootPath))
	{
		$null = mkdir $ModuleRootPath
	}

	if(Test-Path $modulePath)
	{
		Remove-Item $modulePath -Recurse -Force
	}

	Copy-Item $SourcePath $ModuleRootPath -Recurse

	$moduleData = Join-Path $modulePath "${ModuleName}.psd1"

	$version = $Gitversion.MajorMinorPatch
	$nugetPath = (join-Path $repositoryPath "${ModuleName}.${version}.nupkg")
	$year = ([DateTime]($GitVersion.CommitDate)).Year
	$copyright = "Copyright © ${year}, ${CompanyName}. All rights reserved."
	$updateParameters = @{
		Path = $moduleData
		ModuleVersion = $GitVersion.MajorMinorPatch
		Copyright = $copyright
		Author = $Author
		CompanyName = $CompanyName
	}
	if($GitVersion.NuGetPreReleaseTagV2 -ne "")
	{
		$preReleaseTag = $GitVersion.NuGetPreReleaseTagV2 -replace '[^a-zA-Z0-9]', ''
		$updateParameters.Add("Prerelease", $preReleaseTag)
		$nugetPath = (join-Path $repositoryPath "${ModuleName}.${version}-${preReleaseTag}.nupkg")
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
	if($removeRepo)
	{
		$repo = Get-PSRepository -Name $repositoryName -ErrorAction SilentlyContinue

		if($repo)
		{
			Unregister-PSRepository -Name $repositoryName
			Write-Verbose "Unregistered repository '${repositoryName}'."
		}
	}
}
