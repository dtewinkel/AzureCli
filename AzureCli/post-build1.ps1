[CmdletBinding()]
param(
	# The name of the current project configuration, for example, "Debug".
	[Parameter()] $ConfigurationName,

	# Path to the output file directory, relative to the project directory. This resolves to the value for the Output Directory property. It includes the trailing backslash '\'.
	[Parameter()] $OutDir,

	# The installation directory of Visual Studio (defined with drive and path; includes the trailing backslash '\'.
	[Parameter()] $DevEnvDir,

	# The name of the currently targeted platform. For example, "AnyCPU".
	[Parameter()] $PlatformName,

	# The directory of the project (defined with drive and path; includes the trailing backslash '\'.
	[Parameter()] $ProjectDir,

	# The absolute path name of the project (defined with drive, path, base name, and file extension.
	[Parameter()] $ProjectPath,

	# The base name of the project.
	[Parameter()] $ProjectName,

	# The file name of the project (defined with base name and file extension.
	[Parameter()] $ProjectFileName,

	# The file extension of the project. It includes the '.' before the file extension.
	[Parameter()] $ProjectExt,

	# The directory of the solution (defined with drive and path; includes the trailing backslash '\'.
	[Parameter()] $SolutionDir,

	# The absolute path name of the solution (defined with drive, path, base name, and file extension.
	[Parameter()] $SolutionPath,

	# The base name of the solution.
	[Parameter()] $SolutionName,

	# The file name of the solution (defined with base name and file extension.
	[Parameter()] $SolutionFileName,

	# The file extension of the solution. It includes the '.' before the file extension.
	[Parameter()] $SolutionExt,

	# The directory of the primary output file for the build (defined with drive and path. It includes the trailing backslash '\'.
	[Parameter()] $TargetDir,

	# The absolute path name of the primary output file for the build (defined with drive, path, base name, and file extension.
	[Parameter()] $TargetPath,

	# The base name of the primary output file for the build.
	[Parameter()] $TargetName,

	# The file name of the primary output file for the build (defined as base name and file extension.
	[Parameter()] $TargetFileName,

	# The file extension of the primary output file for the build. It includes the '.' before the file extension.
	[Parameter()] $TargetExt
)

<#
After building the project, this script will build the module. This validates the settins in the *.psd1 file.
If building the module fails, then buiding the project fails.

To test building the module, a temporary local repository is created. To keep the repositoy, set $removeRepo to $false.
#>

$removeRepo = $true

$version = '0.0.1'
$preRelease = 'LocalBuild'
$repositoryName  = "Local${ProjectName}PowerShell"
$repositoryPath = (Join-Path $SolutionDir $repositoryName)
$nugetPath = (join-Path $repositoryPath "${ProjectName}.${version}-${preRelease}.nupkg")
$moduleDir = (Join-Path $TargetDir ${ProjectName})

$scriptDir = (Join-Path $SolutionDir deployment pipelines, scripts)
$repositoryScript = (Join-Path $scriptDir New-LocalRepository.ps1)
$updateScript = (Join-Path $scriptDir Update-PowerShellModule.ps1)
$publishScript = (Join-Path $scriptDir Publish-PowerShellModule.ps1)

try
{
	& $repositoryScript -RepositoryName $repositoryName -RepositoryDir $repositoryPath
	if (Test-Path $nugetPath)
	{
		rm $nugetPath
	}

	& $updateScript -ProjectName $ProjectName -ProjectDir $moduleDir -Version $version -Prerelease $preRelease
	& $publishScript -ProjectDir $moduleDir -Repository $repositoryName
}
finally
{
	if($removeRepo)
	{
		$repo = Get-PSRepository -Name $repositoryName -ErrorAction SilentlyContinue

		if($repo)
		{
 			Unregister-PSRepository -Name $repositoryName
			Write-Host "Unregistered repository '${repositoryName}'."
		}
	}
}

if (-not (Test-Path $nugetPath))
{
	throw "${nugetPath} was not created!"
}
