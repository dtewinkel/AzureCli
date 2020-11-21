[cmdletbinding()]
param(
	[Parameter()]
	$GitVersion
)

Write-Host $GitVersion[0]

throw "Quit now :-)"

