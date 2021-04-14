# AzureCli

Get it from the PowerShell gallery: [AzureCli](https://www.powershellgallery.com/packages/AzureCli):
```powershell
Install-Module -Name AzureCli
```

Cmdlet to support invoking the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) from PowerShell.

Master branch: ![master Build Status](https://dev.azure.com/twia/AzureCli/_apis/build/status/AzureCli?branchName=master)

## Introduction

This PowerShell module provide a cmdlet and an alias to call the Azure CLI tool `az` in a more PowerShell friendly way. 

## Included cmdlets and aliases

### Invoke-AzCli

Invoke the Azure CLI (`az`) from PowerShell and make dealing with the output easier in PowerShell.

Unless specified otherwise, converts the output from JSON to a custom object. This makes further processing the output in PowerShell much easier.

It provides better error handling, so that script fails if the Azure CLI fails.

Fixes the console colors back to what they were before calling Azure CLI, as the colors sometimes get screwed up on errors, verbose output, and some other cases.

Allows to set most of the common or often used Azure CLI parameters through PowerShell parameters:

- `-Output` for `--output`
- `-Help` for `--help`
- `-Query` for `--query`
- `-Subscription` for `--subscription`
- `-ResourceGroup` for `--resource-group`
- `-SuppressCliWarnings` or `-CliVerbosity NoWarnings` for `--only-show-errors`
- `-CliVerbosity Verbose` for `--verbose`
- `-CliVerbosity Debug` for `--debug`

In most cases only the PowerShell or the Azure CLI version of a parameter can be used. Specifying both is an error.

### iaz

`iaz` is the alias to `Invoke-AzCli`.
