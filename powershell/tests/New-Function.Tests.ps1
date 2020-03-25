Describe "New-Function" -Tag "CI" {
    # Create a new folder to hold all the files we're creating during the test
    $NewFunctionTestPath = "$Env:TEMP\vigilant-memory-newfunction"
    New-Item -Path $NewFunctionTestPath -ItemType Directory -Force
    It "creates a function in a file named after the function" {
        New-Function -Name "Test-FunctionCreation" -Path $NewFunctionTestPath
        "$NewFunctionTestPath\Test-FunctionCreation.ps1" | Should -Exist
        "$NewFunctionTestPath\Test-FunctionCreation.ps1" | Should -FileContentMatch 'Function Test-FunctionCreation {'
    }
    It "creates a function in a file named after the function with separate Verb and Noun specified" {
        New-Function -Verb "Test" -Noun "FunctionCreationSplit" -Path $NewFunctionTestPath
        "$NewFunctionTestPath\Test-FunctionCreationSplit.ps1" | Should -Exist
        "$NewFunctionTestPath\Test-FunctionCreationSplit.ps1" | Should -FileContentMatch 'Function Test-FunctionCreationSplit {'
    }
    It "creates a function in a file named after the function with a prefix" {
        New-Function -Name "Test-FunctionCreation" -Prefix "Prefix" -Path $NewFunctionTestPath
        "$NewFunctionTestPath\Test-PrefixFunctionCreation.ps1" | Should -Exist
        "$NewFunctionTestPath\Test-PrefixFunctionCreation.ps1" | Should -FileContentMatch 'Function Test-PrefixFunctionCreation {'
    }
    It "creates a function in a file named after the function with separate Verb and Noun specified with a prefix" {
        New-Function -Verb "Test" -Noun "FunctionCreationSplit" -Prefix "Prefix" -Path $NewFunctionTestPath
        "$NewFunctionTestPath\Test-PrefixFunctionCreationSplit.ps1" | Should -Exist
        "$NewFunctionTestPath\Test-PrefixFunctionCreationSplit.ps1" | Should -FileContentMatch 'Function Test-PrefixFunctionCreationSplit {'
    }
    It "creates a function with parameters when parameters are specified" {
        New-Function -Name "Test-FunctionParameters" -Path $NewFunctionTestPath -Parameters "Param1","Param2"
        "$NewFunctionTestPath\Test-FunctionParameters.ps1" | Should -Exist
        $FileContent = Get-Content -Raw "$NewFunctionTestPath\Test-FunctionParameters.ps1"
        $FileContent | Should -Match "\[Parameter\(\)]\r?\n\s*\`$Param1"
        $FileContent | Should -Match "\[Parameter\(\)]\r?\n\s*\`$Param2"
    }
    It "creates a function with synopsis, description, input, output, and notes" {
        New-Function -Name "Test-FunctionCommentBasedHelp" -Path $NewFunctionTestPath -Synopsis "Synopsis Test 123" -Description "Description Test 456" -Inputs "Inputs Test 789" -Outputs "Outputs Test 0AB" -Notes "Notes Test CDE"
        "$NewFunctionTestPath\Test-FunctionCommentBasedHelp.ps1" | Should -Exist
        $FileContent = Get-Content -Raw "$NewFunctionTestPath\Test-FunctionCommentBasedHelp.ps1"
        $FileContent | Should -Match "\.SYNOPSIS\r?\nSynopsis Test 123"
        $FileContent | Should -Match "\.DESCRIPTION\r?\nDescription Test 456"
        $FileContent | Should -Match "\.INPUTS\r?\nInputs Test 789"
        $FileContent | Should -Match "\.OUTPUTS\r?\nOutputs Test 0AB"
        $FileContent | Should -Match "\.NOTES\r?\nNotes Test CDE"
    }
    It "creates a function with SupportsShouldProcess, SupportsPaging, and/or PositionalBinding=`$False" {
        New-Function -Name "Test-ShouldProcess" -Path $NewFunctionTestPath -SupportsShouldProcess
        New-Function -Name "Test-Paging" -Path $NewFunctionTestPath -SupportsPaging
        New-Function -Name "Test-PositionalBinding" -Path $NewFunctionTestPath -PositionalBindingOff
        New-Function -Name "Test-ShouldProcessAndPaging" -Path $NewFunctionTestPath -SupportsShouldProcess -SupportsPaging
        New-Function -Name "Test-ShouldProcessAndPositionalBinding" -Path $NewFunctionTestPath -SupportsShouldProcess -PositionalBindingOff
        New-Function -Name "Test-PagingAndPositionalBinding" -Path $NewFunctionTestPath -SupportsPaging -PositionalBindingOff
        New-Function -Name "Test-ShouldProcessPagingAndPositionalBinding" -Path $NewFunctionTestPath -SupportsShouldProcess -SupportsPaging -PositionalBindingOff
        "$NewFunctionTestPath\Test-ShouldProcess.ps1" | Should -FileContentMatch ([regex]::Escape('[CmdletBinding(SupportsShouldProcess)]'))
        "$NewFunctionTestPath\Test-Paging.ps1" | Should -FileContentMatch ([regex]::Escape('[CmdletBinding(SupportsPaging)]'))
        "$NewFunctionTestPath\Test-PositionalBinding.ps1" | Should -FileContentMatch ([regex]::Escape('[CmdletBinding(PositionalBinding=$False)]'))
        "$NewFunctionTestPath\Test-ShouldProcessAndPaging.ps1" | Should -FileContentMatch ([regex]::Escape('[CmdletBinding(SupportsShouldProcess,SupportsPaging)]'))
        "$NewFunctionTestPath\Test-ShouldProcessAndPositionalBinding.ps1" | Should -FileContentMatch ([regex]::Escape('[CmdletBinding(SupportsShouldProcess,PositionalBinding=$False)]'))
        "$NewFunctionTestPath\Test-PagingAndPositionalBinding.ps1" | Should -FileContentMatch ([regex]::Escape('[CmdletBinding(SupportsPaging,PositionalBinding=$False)]'))
        "$NewFunctionTestPath\Test-ShouldProcessPagingAndPositionalBinding.ps1" | Should -FileContentMatch ([regex]::Escape('[CmdletBinding(SupportsShouldProcess,SupportsPaging,PositionalBinding=$False)]'))
    }
    It "Adds the Using Module clause when -UsingModule parameter is used" {
        New-Function -Name "Test-UsingModule" -Path $NewFunctionTestPath -UsingModule "ExternalModule"
        Get-Content -Raw "$NewFunctionTestPath\Test-UsingModule.ps1" | Should -Match "^Using Module ExternalModule\r?\n"
    }
    It "throws an error when an unapproved verb is used" {
        { New-Function -Name "Trash-ThisPlace" -Path $NewFunctionTestPath } | Should -Throw
        { New-Function -Verb "Pretend" -Noun "MakeBelieveCastle" -Path $NewFunctionTestPath } | Should -Throw
    }
    It "throws an error when an approved verb is used, but an invalid noun is used" {
        { New-Function -Name "Test-Garbage9&#" -Path $NewFunctionTestPath } | Should -Throw
        { New-Function -Verb "Test" -Noun "9999999999999@" -Path $NewFunctionTestPath } | Should -Throw
        { New-Function -Name "Test-All-The-Things" -Path $NewFunctionTestPath } | Should -Throw
    }
    It "throws an error when an approved verb and a valid noun is used, but an invalid prefix is used" {
        { New-Function -Name "Test-Everything" -Prefix "@#&" -Path $NewFunctionTestPath } | Should -Throw
        { New-Function -Verb "Test" -Noun "EverythingAgain" -Prefix "///" -Path $NewFunctionTestPath } | Should -Throw
    }
    It "throws when an invalid parameter name is specified" {
        { New-Function -Name "Test-AllTheThings" -Parameters "_-_" -Path $NewFunctionTestPath } | Should -Throw
    }
    # Clean up after ourselves
    Remove-Item -Path $NewFunctionTestPath -Recurse -Force
}