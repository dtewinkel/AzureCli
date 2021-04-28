#
# Module manifest for module 'AzureCli'
#

@{

	# Script module or binary module file associated with this manifest.
	RootModule        = 'AzureCli.psm1'

	# Version number of this module.
	ModuleVersion     = '0.0.1'

	# Supported PSEditions
	# CompatiblePSEditions = @()

	# ID used to uniquely identify this module
	GUID              = 'dbe3fe96-136f-4fcb-b265-cd3b778d89b0'

	# Author of this module
	Author            = 'Daniël te Winkel'

	# Company or vendor of this module
	CompanyName       = 'Daniël te Winkel'

	# Copyright statement for this module
	Copyright         = 'Copyright © 2021, Daniël te Winkel. All rights reserved.'

	# Description of the functionality provided by this module
	Description       = 'Cmdlet and alias to make the use of Azure CLI a bit more PowerShell friendly. Process output of Azure CLI from JSON to custom objects.'

	# Minimum version of the PowerShell engine required by this module
	# PowerShellVersion = ''

	# Name of the PowerShell host required by this module
	# PowerShellHostName = ''

	# Minimum version of the PowerShell host required by this module
	# PowerShellHostVersion = ''

	# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
	# DotNetFrameworkVersion = ''

	# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
	# ClrVersion = ''

	# Processor architecture (None, X86, Amd64) required by this module
	# ProcessorArchitecture = ''

	# Modules that must be imported into the global environment prior to importing this module
	# RequiredModules = @()

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @()

	# Script files (.ps1) that are run in the caller's environment prior to importing this module.
	# ScriptsToProcess = @()

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @()

	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @()

	# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
	NestedModules     = @()

	# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
	FunctionsToExport = 'Invoke-AzCli'

	# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
	CmdletsToExport   = @()

	# Variables to export from this module
	# VariablesToExport = @()

	# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
	AliasesToExport   = 'iaz'

	# DSC resources to export from this module
	# DscResourcesToExport = @()

	# List of all modules packaged with this module
	# ModuleList = @()

	# List of all files packaged with this module
	# FileList = @()

	# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData       = @{

		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			Tags         = 'powershell', 'az', 'cli', 'azure'

			# A URL to the license for this module.
			# LicenseUri = ''

			# A URL to the main website for this project.
			ProjectUri   = 'https://github.com/dtewinkel/AzureCli'

			# A URL to an icon representing this module.
			IconUri      = 'http://www.twia.nl/resources/twia.ico'

			# ReleaseNotes of this module
			ReleaseNotes = @'
2.2.0

- Improved security by supporting SecureString as input for Auzure CLI parameter. The SecureString value will be passed
  on as plain text to Azure CLI, but will be printed as ******** on the Invoke-AzCli verbose output.
- Added -EscapeHandling parameter to set automatic escaping of strings on the command-line to Azure CLI. Set to Always
  to escape \ and " with the \ escape character. Do not set it, or set it to None, to not escape. This is the default
  behavior.
- Allow to set global CliVerbosity preference through the $AzCliVerbosityPreference variable.
- Deprecated -SuppressCliWarnings in favor of -CliVerbosity NoWarnings. Use of -SuppressCliWarnings will give a
  deprecation warning.
- Argument completers for -Subscription and -ResourceGroup provide a better description for each completion result.
- Documentation updates and fixes.

2.1.0

- Added argument -CliVerbosity to set verbosity of Azure CLI. This provides a single parameter to either set
  --only-show-errors, --verbose, or --debug.

2.0.0

- Added argument completion for -Subscription parameter.
- Added -ResourceGroup parameter, because the --resource-group parameter is needed so often. Supports argument completion.
- Added -NoEnumerate and -AsHashtable to have more control over the JSON to output conversion.
- Added parameter sets, to make clear which parameters can be used together. This may break existing scripts that use
  parameters together that are not allowed together anymore.
- Improved test coverage.

1.3.0

- Improved error handling. Now throws on error.
- Improved locality of restoring color output. Only restore it if we process the Auzure CLI output.

1.2.0

- Improved passing of parameters to az command line, preventing interpretation of parameters by PowerShell.
- Support more text output or interactive commands:
  - interactive.
  - feedback.
  - version.
  - upgrade.
- provide message where to install Auzure CLI from if az command is not found.

1.1.0

- Support raw output for a number of specific command groups and parameters:
  - Support --version.
  - Support find.
  - Support help.
- Better handle raw output for --output, -o, help and a number of other parameters.

1.0.2

- Fixed restoring color output in some error scenarios.

1.0.1

- Don't change directory to module path on invocation.
- Improve source project documentation.

1.0.0

- Initial version of this module providing Invoke-AzCli and alias iaz.
'@

			# Prerelease string of this module
			# Prerelease = ''

			# Flag to indicate whether the module requires explicit user acceptance for install/update/save
			# RequireLicenseAcceptance = $false

			# External dependent modules of this module
			# ExternalModuleDependencies = @()

		} # End of PSData hashtable

 } # End of PrivateData hashtable

	# HelpInfo URI of this module
	# HelpInfoURI = ''

	# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
	# DefaultCommandPrefix = ''

}

