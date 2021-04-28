function AssertAzPresent()
{
	$azCmd = Get-Command az -ErrorAction SilentlyContinue
	if (-not $azCmd)
	{
		throw "The 'az' Azure CLI command is not found. Please go to https://docs.microsoft.com/en-us/cli/azure/install-azure-cli to install it."
	}
}
