function HandleQuery()
{
	[OutputType('System.Array')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[string] $Query,

		[Parameter()]
		[string[]] $Arguments
	)

	if ($Query)
	{
		if ("--query" -in $Arguments)
		{
			throw "Both -Query and --query are provided as parameter. This is not allowed."
		}
		'--query', $Query
	}
}
