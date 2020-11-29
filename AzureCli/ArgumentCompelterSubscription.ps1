$SubscriptionsCompleter = {
	param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	$accounts = az account list --query '[].{ name: name, id: id }' | ConvertFrom-Json
@( $accounts.name ) + @( $accounts.id ) |
Where-Object { $_ -like "${wordToComplete}*" } |
ForEach-Object {
			if($_ -match '\s')
			{
					"'${_}'"
			}
			else
			{
					$_
			}
	}
}

Register-ArgumentCompleter -CommandName Invoke-AzCli -ParameterName Subscription -ScriptBlock $SubscriptionsCompleter
