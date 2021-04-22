function AssertAzPresent()
{
	$azCmd = Get-Command az -ErrorAction SilentlyContinue
	if (-not $azCmd)
	{
		throw "The az CLI is not found. Please go to https://docs.microsoft.com/en-us/cli/azure/install-azure-cli to install it."
	}
}
