<#
#>

########
# Global settings
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"
Set-StrictMode -Version 2

# Sources for reading script vars
$script:Source = $("azauto", "environment")

<#
#>
Function Set-ScriptVarSource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("azauto", "environment")]
        [string[]]$Source
    )

    process
    {
        # Set the script sources to input, but make a new container for
        # these strings
        $script:Source = $Source | ForEach-Object { $_ }
    }
}

<#
#>
Function Get-ScriptVar
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        $DefaultValue,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("azauto", "environment")]
        [string[]]$Source = $script:Source
    )

    process
    {
        if ($Source -contains "azauto")
        {
            # Attempt to get the variable from Azure Automation
            try {
                Get-AutomationVariable -Name $Name
                return
            } catch {
                # Couldn't get the variable from Azure Automation
            }
        }

        if ($Source -contains "environment")
        {
            # Attempt to get the variable from the environment
            try {
                (Get-Item Env:\$Name).Value
                return
            } catch {
                # Couldn't get the variable from the environment
            }
        }

        # Can't get the variable from any of the script sources - Do we have a default value
        if ($PSBoundParameters.Keys -contains "DefaultValue")
        {
            $DefaultValue
        } else {
            Write-Error "Empty or missing environment variable: $Name"
        }
    }
}
