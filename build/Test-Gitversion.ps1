[cmdletbinding()]
param(
	[Parameter()]
	$GitVersion
)

Write-Host $GitVersion[0]
Write-Host $GitVersion[1]
Write-Host $GitVersion[2]
Write-Host $GitVersion[3]
Write-Host $GitVersion[4]

$GitVersion | ConvertFrom-Json

throw "Quit now :-)"

