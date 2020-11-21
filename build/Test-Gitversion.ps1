[cmdletbinding()]
param(
	[Parameter()]
	$GitVersion
)

Write-Host ($GitVersion.GetType())

Write-Host $GitVersion

