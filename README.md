# AzureCli

Cmdlet to support invoking the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) from PowerShell.

Master branch: [![maste rBuild Status](https://dev.azure.com/twia/AzureCli/_apis/build/status/dtewinkel.AzureCli?branchName=master)](https://dev.azure.com/twia/AzureCli/_build/latest?definitionId=15&branchName=master)

## Introduction

This PowerShell module provide a cmdlet and an alias to call the Azure CLI tool `az` in a more PowerShell friendly way. 

## Included cmdlets and aliases

### Invoke-AzCli

Invoke the Azure CLI (`az`) from PowerShell and make dealing with the output easier in PowerSehll.

Unless specified otherwise, converts the output from JSON to a custom object. This makes further processing the output in PowerShell much easier.

It provides better error handling, so that script fails if the Azure CLI fails.

Fixes the console colors back to what they were before calling Azure CLI, as it tends to screw up the colors on errors, verbose output, and other cases.

Allows to set most of the common Azure CLI parameters through PowerShell parameters:

- `-Output` for `--output`.
- `-Help` for `--help`.
- `-Query` for `--query`.
- `-Subscription` for `--subscription`.

In most cases only the PowerShell or the Azure CLI version of a parameter can be used. Specifying both is an error.

### iaz

`iaz` is the alias to `Invoke-AzCli`.
