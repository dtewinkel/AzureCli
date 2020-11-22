[cmdletbinding()]
param(
	[Parameter()]
	$GitVersion
)

$GitVersion | ConvertFrom-Json

throw "Quit now :-)"

