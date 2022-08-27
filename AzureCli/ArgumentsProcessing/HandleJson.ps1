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
		if ($PSVersionTable.PSVersion.Major -ge 7)
		{
			$additionalArguments.Add("NoEnumerate", $true)
		}
		else
		{
			throw "-AsHashtable can only be used on PowerShell 7.0.0 or newer"
		}
	}

	if ($AsHashtable.IsPresent)
	{
		$additionalArguments.Add("AsHashtable", $true)
	}

	$additionalArguments
}
