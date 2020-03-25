

Function New-Function {
<#
.SYNOPSIS
Create a new skeletal function with some basics prefilled

.DESCRIPTION
New-Function creates a new skeletal function with all of the basic parts,
such as Begin/Process/End, parameters, and comment-based help.

.PARAMETER Name
The full name of the function being created, in Verb-Noun format containing
letters, numbers, and underscores. Additionally, the Verb portion must be a
valid verb as defined by the results of Get-Verb function.

.PARAMETER Verb
The verb portion of the name of the function being created. It must be a valid
verb as defined by the results of Get-Verb function.

.PARAMETER Noun
The noun portion of the name of the function being created, containing
letters, numbers, and underscores.

.PARAMETER Prefix
A string that prepends the Noun in a function name, often used when creating
module functions. Must consist of only letters and numbers.

.PARAMETER Path
The file path where the function file will be written. Default value is the
current directory.

.PARAMETER Parameters
A list of one or more parameters to include in the function. Each parameter
name must consist only of letters and numbers.

.PARAMETER UsingModule
A list of modules required for the function. These will be added to the top of
the file as "Using Module" clauses.

.PARAMETER Synopsis
The Synopsis within the comment-based help for the new function.

.PARAMETER Description
The Description within the comment-based help for the new function.

.PARAMETER Inputs
The Inputs within the comment-based help for the new function.

.PARAMETER Outputs
The Outputs within the comment-based help for the new function.

.PARAMETER Notes
The Notes within the comment-based help for the new function.

.PARAMETER SupportsShouldProcess
Set the SupportsShouldProcess parameter of CmdletBinding to $True for the new function.

.PARAMETER SupportsPaging
Set the SupportsPaging parameter of CmdletBinding to $True for the new function.

.PARAMETER PositionalBindingOff
Set the PositionalBinding parameter of CmdletBinding to $False for the new function.

.EXAMPLE
PS> New-Function -Verb "Get" -Noun "Widget"

Creates a skeletal function called Get-Widget with no parameters in a file
named Get-Widget.ps1 located in the current directory.

.EXAMPLE
PS> New-Function -Name "Get-Widget" -Parameter "Name","Type"

Creates a skeletal function called "Get-Widget" with two parameters (Name
and Type) in a file named Get-Widget.ps1 located in the current directory.

.EXAMPLE
PS> New-Function -Name "Get-Widget" -Parameter "Name" -SupportsShouldProcess

Creates a skeletal function called "Get-Widget" with one parameter (Name)
that supports ShouldProcess in a file named Get-Widget.ps1 located in the
current directory.

.INPUTS
Insert inputs here

.OUTPUTS
Insert outputs here

.NOTES
Insert notes here

#>
[CmdletBinding(SupportsShouldProcess,DefaultParameterSetName="FullName")]
param(
    [Parameter(Mandatory=$True,Position=0,ValueFromPipeline,ParameterSetName="FullName")]
    [ValidateScript({
        If($_ -cmatch '^[^-]+-[A-Z][A-Za-z0-9_]*[A-Za-z]?$') {
            If($($_ -split "-")[0] -in (Get-Verb).Verb) {
                $True
            } Else {
                Throw "The verb portion of the name must be an approved verb."
            }
        } Else {
            Throw "`"$_`" is not a valid value for parameter name. It must be in Verb-Noun format, consisting of only letters, numbers, underscores, and one hyphen."
        }
    })]
    [Alias('FunctionName')]
    [string]
    $Name,

    [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName,ParameterSetName="SplitName")]
    [ValidateScript({
        If($_ -in (Get-Verb).Verb) {
            $True
        } Else {
            Throw "The verb portion of the name must be an approved verb."
        }
    })]
    [Alias('FunctionVerb')]
    [string]
    $Verb,

    [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName,ParameterSetName="SplitName")]
    [ValidateScript({
        If($_ -cmatch '^[A-Z][A-Za-z0-9_]*[A-Za-z]?$') {
            $True
        } Else {
            Throw "`"$_`" is not a valid value for the noun portion of the function name. It must consist of only letters, numbers and underscores."
        }
    })]
    [Alias('FunctionNoun')]
    [string]
    $Noun,

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [ValidateScript({
        If($_ -imatch '^[a-z0-9]*$') {
            $True
        } Else {
            Throw "`"$_`" is not a valid value for the noun portion of the function name. It must consist of only letters, numbers and underscores."
        }
    })]
    [Alias('Module','NounPrefix')]
    [string]
    $Prefix = "",

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [ValidateScript({
        If(Test-Path -Path $_ -PathType Container) {
            $True
        } Else {

        }
    })]
    [Alias('FilePath')]
    [string]
    $Path = $PWD,

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [ValidateScript({
        ForEach($param in [Array]$_) {
            If($param -imatch '^[a-z0-9]+$') {
                $True
            } Else {
                Throw "`"$_`" is not a valid parameter name. Parameters must be named with only letters and numbers."
            }
        }
    })]
    [Alias("Params")]
    [string[]]
    $Parameters,

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [string[]]
    $UsingModule,

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [string]
    $Synopsis = "Insert synopsis here",

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [string]
    $Description = "Insert description here",

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [string]
    $Inputs = "Insert inputs here",

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [string]
    $Outputs = "Insert outputs here",

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [string]
    $Notes = "Insert notes here",

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [Alias("ShouldProcess")]
    [switch]
    $SupportsShouldProcess,

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [Alias("Paging")]
    [switch]
    $SupportsPaging,

    [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName)]
    [switch]
    $PositionalBindingOff
)

Begin {
    Switch($PSCmdlet.ParameterSetName) {
        "FullName" {
            $Verb = ($Name -split '-')[0]
            $Noun = ($Name -split '-')[1] -replace $Prefix,""
            $Name = $Name -replace "-","-$Prefix"
            Break
        }
        "SplitName" {
            $Name = "${Verb}-${Prefix}${Noun}"
            Break
        }
    }

    # Process the CmdletBinding elements
    $CmdletBinding = @()
    If($SupportsShouldProcess.IsPresent) {
        $CmdletBinding += "SupportsShouldProcess"
    }
    If($SupportsPaging.IsPresent) {
        $CmdletBinding += "SupportsPaging"
    }
    If($PositionalBindingOff.IsPresent) {
        $CmdletBinding += "PositionalBinding=`$False"
    }
} # Begin

Process {
    $FunctionContent = @()
    If("UsingModule" -in $PSBoundParameters.Keys) {
        $UsingModule | ForEach-Object {
            $FunctionContent += "Using Module $_"
        }
    }
    $FunctionContent += "Function $Name {"
    $FunctionContent += "<#"
    $FunctionContent += ".SYNOPSIS"
    $FunctionContent += $Synopsis
    $FunctionContent += ""
    $FunctionContent += ".DESCRIPTION"
    $FunctionContent += $Description
    $FunctionContent += ""
    If("Parameters" -in $PSBoundParameters.Keys) {
        $Parameters | ForEach-Object {
            $FunctionContent += ".PARAMETER $_"
            $FunctionContent += "Insert description for parameter $_ here"
            $FunctionContent += ""
        }
    }
    $FunctionContent += ".EXAMPLE"
    $FunctionContent += "PS> $Name"
    $FunctionContent += ""
    $FunctionContent += "Describe example here"
    $FunctionContent += ""
    If("Parameters" -in $PSBoundParameters.Keys) {
        $FunctionContent += ".EXAMPLE"
        $FunctionContent += "PS> $Name -$($Parameters[0])"
        $FunctionContent += ""
        $FunctionContent += "Describe example here"
        $FunctionContent += ""
    }
    $FunctionContent += ".INPUTS"
    $FunctionContent += $Inputs
    $FunctionContent += ""
    $FunctionContent += ".OUTPUTS"
    $FunctionContent += $Outputs
    $FunctionContent += ""
    $FunctionContent += ".NOTES"
    $FunctionContent += $Notes
    $FunctionContent += ""
    $FunctionContent += "#>"
    $FunctionContent += "[CmdletBinding($($CmdletBinding -join ","))]"
    If("Parameters" -in $PSBoundParameters.Keys) {
        $FunctionContent += "param("
        $i = 1
        $Parameters | ForEach-Object {
            $FunctionContent += "    [Parameter()]"
            If($i -lt $Parameters.Count) {
                $FunctionContent += "    `$$_,"
            } Else {
                $FunctionContent += "    `$$_"
            }
            $FunctionContent += ""
            $i++
        }
        $FunctionContent += ") # param"
    } Else {
        $FunctionContent += "param()"
        $FunctionContent += ""
    }
    $FunctionContent += "Begin {"
    $FunctionContent += ""
    $FunctionContent += "} # Begin"
    $FunctionContent += ""
    $FunctionContent += "Process {"
    $FunctionContent += ""
    $FunctionContent += "} # Process"
    $FunctionContent += ""
    $FunctionContent += "End {"
    $FunctionContent += ""
    $FunctionContent += "} # End"
    $FunctionContent += ""
    $FunctionContent += "} # Function"
} # Process

End {
    If($PSCmdlet.ShouldProcess($Path)) {
        $FunctionContent | Out-File -FilePath "$Path\$Name.ps1" -Force
    }
}

} # Function