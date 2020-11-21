[cmdletbinding()]
param(
	[Parameter()]
	$GitVersion
)

Write-Host $GitVersion.Major

