function HandleSubscription()
{
	[OutputType('System.Array')]
	[CmdletBinding()]
	param(
		[Parameter()]
		[string] $Subscription,

		[Parameter()]
		[object[]] $Arguments
	)

	if ($Subscription)
	{
		if ($Arguments -contains "--subscription")
		{
			throw "Both -Subscription and --subscription are provided as parameter. This is not allowed."
		}
		'--subscription', $Subscription
	}
}
