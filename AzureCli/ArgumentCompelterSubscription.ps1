$SubscriptionsCompleter = {
	param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

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
		$id = $account.id
		if ($name -like "${wordToComplete}*")
		{
			$description = "Subscription with name '${name}' (ID = '${id}')."
			if ($name -match '\s')
			{
				$name = "'${name}'"
			}
			$names += [System.Management.Automation.CompletionResult]::new($name, $name, "ParameterValue", $description)
		}
		if ($id -like "${wordToComplete}*")
		{
			$description = "Subscription with ID '${id}' (name = '${name}')."
			$ids += [System.Management.Automation.CompletionResult]::new($id, $id, "ParameterValue", $description)
		}
	}
	$all = @($names + $ids)
	if($all.Length -eq 0)
	{
		return $null
	}
	return $all
}

Register-ArgumentCompleter -CommandName Invoke-AzCli -ParameterName Subscription -ScriptBlock $SubscriptionsCompleter
