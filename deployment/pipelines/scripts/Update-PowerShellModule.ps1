[CmdletBinding()]
param(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string] $ProjectName,

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string] $ProjectDir,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[Version] $Version = 0.0.1,

	[Parameter()]
	[string] $Prerelease,

	[Parameter()]
	[string] $CopyrightYear = [DateTime]::Now.Year,

	[Parameter()]
	[string] $Author = "Daniël te Winkel",

	[Parameter()]
	[string] $CompanyName = "Daniël te Winkel"
)

$modulePath = (Join-Path $ProjectDir "${ProjectName}.psd1")

$copyright = "Copyright © ${$CopyrightYear}, ${CompanyName}. All rights reserved."

$updateParameters = @{
	Path = $modulePath
	ModuleVersion = $Version
	Copyright = $copyright
	Author = $Author
	CompanyName = $CompanyName
}

if($PreRelease)
{
	$updateParameters.Add("Prerelease", $Prerelease)
}

Update-ModuleManifest @updateParameters
