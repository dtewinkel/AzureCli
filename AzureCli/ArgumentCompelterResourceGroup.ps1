$ResourceGroupCompleter = {
    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $subscriptionParameters = @()
    if($fakeBoundParameters.Subscription)
    {
        $subscriptionParameters = @('--subscription', $fakeBoundParameters.Subscription)
    }
    az group list --query '[].name' @subscriptionParameters | ConvertFrom-Json | Where-Object { $_ -like "${wordToComplete}*" }
}

Register-ArgumentCompleter -CommandName Invoke-AzCli -ParameterName ResourceGroup -ScriptBlock $ResourceGroupCompleter
