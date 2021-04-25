# AzureCli

Get it from the PowerShell gallery: [AzureCli](https://www.powershellgallery.com/packages/AzureCli):

```powershell
Install-Module -Name AzureCli
```

CmdLet to support invoking the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) from PowerShell.

Master branch: ![master Build Status](https://dev.azure.com/twia/AzureCli/_apis/build/status/AzureCli?branchName=master)

## Introduction

This PowerShell module provide a CmdLet and an alias to call the Azure CLI tool `az` in a more PowerShell friendly way.

## Included CmdLets and aliases

### Invoke-AzCli

Invoke the Azure CLI (`az`) from PowerShell and make processing the output easier in PowerShell.

Unless specified otherwise, converts the output from JSON to a custom object. This makes further processing the output in PowerShell much easier.

It provides better error handling, so that script fails if the Azure CLI fails.

In some scenarios the Azure CLI changes console output colors, but does not change them back to what they were. This may happen for errors, verbose output, and in some other cases. `Invoke-AzCli` fixes the console colors back to what they were before calling Azure CLI.

Allows to set most of the common or often used Azure CLI parameters through PowerShell parameters:

- `-Output` for `--output`. Setting `-Output`, `--output`, or `-Raw` stops `Invoke-AzCli` from converting the output of Azure CLI to custom objects.
- `-Help` for `--help`.
- `-Query` for `--query`.
- `-Subscription` for `--subscription`. `-Subscription` provides argument completion for subscription names and subscription IDs for the logged-in account.
- `-ResourceGroup` for `--resource-group` `-ResourceGroup` provides argument completion for resource group names for the active subscription, or the subscription provides with `-Subscription`.
- `-CliVerbosity NoWarnings` for `--only-show-errors`
- `-CliVerbosity Verbose` for `--verbose`.
- `-CliVerbosity Debug` for `--debug`.

In most cases only the PowerShell or the Azure CLI version of a parameter can be used. Specifying both is an error.

### iaz

`iaz` is the alias to `Invoke-AzCli`.
