function ArgumentCompleterSubscription($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]

	$accounts = az account list --query '[].{ name: name, id: id }' | ConvertFrom-Json
	if (-not $accounts -or $accounts.Length -eq 0)
	{
		return $null
	}
	$names = @()
	$ids = @()
	foreach ($account in $accounts)
	{
		$name = $account.name
		$plainName = $name
		if ($name -match '\s')
		{
			$name = "'${name}'"
		}
		$id = $account.id
		if ($plainName -like "${wordToComplete}*")
		{
			$description = "Subscription with name '${plainName}' (ID = '${id}')."
			$names += [System.Management.Automation.CompletionResult]::new($name, $plainName, "ParameterValue", $description)
		}
		if ($id -like "${wordToComplete}*")
		{
			$description = "Subscription with ID '${id}' (name = '${plainName}')."
			$ids += [System.Management.Automation.CompletionResult]::new($id, $id, "ParameterValue", $description)
		}
	}
	$all = @($names + $ids)
	if ($all.Length -eq 0)
	{
		return $null
	}
	return $all
}

Register-ArgumentCompleter -CommandName Invoke-AzCli -ParameterName Subscription -ScriptBlock $function:ArgumentCompleterSubscription
