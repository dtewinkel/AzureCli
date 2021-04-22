function HandleResourceGroup()
{
	[OutputType('System.Array')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[string] $ResourceGroup,

		[Parameter()]
		[object[]] $Arguments
	)

	if ($ResourceGroup)
	{
		if ($Arguments -contains "--resource-group")
		{
			throw "Both -ResourceGroup and --resource-group are provided as parameter. This is not allowed."
		}
		'--resource-group', $ResourceGroup
	}
}
