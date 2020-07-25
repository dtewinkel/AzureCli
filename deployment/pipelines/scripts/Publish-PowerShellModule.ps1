[CmdletBinding()]
param(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string] $ProjectDir,

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string] $Repository
)

Publish-Module -Path $ProjectDir -Repository $repositoryName -Force
