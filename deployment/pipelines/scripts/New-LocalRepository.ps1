[CmdletBinding()]
param(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string] $RepositoryName,

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string] $RepositoryDir
)

if(-not (Test-Path $RepositoryDir))
{
	mkdir $RepositoryDir
}

$repo = Get-PSRepository -Name $RepositoryName -ErrorAction SilentlyContinue

if(-not $repo)
{
 	Register-PSRepository -Name $RepositoryName -SourceLocation $RepositoryDir -InstallationPolicy Trusted
	Write-Host "Registered repository '${RepositoryName}' to directory '${RepositoryDir}'."
}
