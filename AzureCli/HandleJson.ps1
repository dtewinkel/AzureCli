function HandleJson()
{
	[OutputType('System.Collections.Hashtable')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[Switch] $NoEnumerate,

		[Parameter()]
		[Switch] $AsHashtable
	)

	$additionalArguments = @{}

	if ($NoEnumerate.IsPresent)
	{
		$additionalArguments.Add("NoEnumerate", $true)
	}

	if ($AsHashtable.IsPresent)
	{
		if ($PSVersionTable.PSVersion -ge [System.Management.Automation.SemanticVersion]"6.0.0")
		{
			$additionalArguments.Add("AsHashtable", $true)
		}
		else
		{
			throw "-AsHashtable can only be used on PowerShell 6.0 or newer"
		}
	}

	$additionalArguments
}
