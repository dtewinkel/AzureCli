$ResourceGroupCompleter = {
    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $subscriptionParameters = @()
    if($fakeBoundParameters.Subscription)
    {
        $subscriptionParameters = @('--subscription', $fakeBoundParameters.Subscription)
    }
    $resourceGroups = az group list --query '[].name' @subscriptionParameters | ConvertFrom-Json
		if (-not $resourceGroups -or $resourceGroups.Length -eq 0)
		{
			return $null
		}
		$results = foreach($resourceGroup in $resourceGroups)
		{
			if ($resourceGroup -like "${wordToComplete}*")
			{
				$description = "Resource Group '${resourceGroup}'."
				[System.Management.Automation.CompletionResult]::new($resourceGroup, $resourceGroup, "ParameterValue", $description)
			}
		}
		if($results.Length -eq 0)
		{
			return $null
		}
		return $results
}

Register-ArgumentCompleter -CommandName Invoke-AzCli -ParameterName ResourceGroup -ScriptBlock $ResourceGroupCompleter
