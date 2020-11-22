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
	$GitVersionJson
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

$modulePath = Join-Path $ModuleRootPath $ModuleName
if(-not (Test-Path $ModuleRootPath))
{
	mkdir $ModuleRootPath
}

if(Test-Path $modulePath)
{
	Remove-Item $modulePath -Recurse -Force
}

Copy-Item $SourcePath $ModuleRootPath -Recurse

$moduleData = Join-Path $modulePath "${ModuleName}.psd1"

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
}
Update-ModuleManifest @updateParameters
# make sure the ModuleManifest is in the right encoding.
$manifest = Get-Content $moduleData
$manifest | Out-File -Encoding utf8BOM $moduleData
