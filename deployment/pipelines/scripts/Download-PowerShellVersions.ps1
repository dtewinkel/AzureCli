[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	[string] $TargetPath,

	[Parameter()]
	[string[]] $Version = @(
		"6.1.0"
		"6.1.6"
		"6.2.0"
		"6.2.7"

		"7.0.0"
		"7.0.12"
		"7.1.0"
		"7.1.7"
		"7.2.0"
		"7.2.6"

		"7.3.0-preview.7"
	),

	[Parameter()]
	[Switch] $Force
)

foreach ($psVersion in $Version)
{
	$targetFolder = Join-Path $TargetPath PowerShell $psVersion
	Write-Verbose "Processing PowerShell $psVersion."
	if ((-not (Test-Path $targetFolder)) -or $Force.IsPresent)
	{
		$file = "PowerShell-${psVersion}-win-x64.zip"
		$filePath = Join-Path temp: $file
		$uri = "https://github.com/PowerShell/PowerShell/releases/download/v${psVersion}/${file}"
		try
		{
			Write-Verbose "Downloading [${file}] to [${filePath}] from [${uri}]."
			Invoke-WebRequest $uri -OutFile $filePath
			Write-Verbose "Extracting [${filePath}] to [${targetFolder}]."
			$dir = mkdir $targetFolder -Force
			Expand-Archive -Path $filePath -DestinationPath $targetFolder -Force
		}
		finally
		{
			Write-Verbose "Removing [${filePath}]."
			Remove-Item $filePath
		}
	}
}
