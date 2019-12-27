Function Save-Password {
    <#
        .SYNOPSIS
        This script saves the credentials in a secured xml file.

        .DESCRIPTION
        This script is designed to save the credentials to a xml file as a secure string.
        This way the person who encrypted the credentials can only decrypt it. It is more
        secure that saving the credentials as a plain text.

        This script accepts the credentials as PSCustomObject with username and password
        as inputs and saves it in the desired location. By default this script creates
        a folder under C:\Windows(System root) and name it as SimplePasswordGenerator
        and save the file as Username_Today'sDate.xml.

        .PARAMETER Credentials
        Provide the username and password.

        .PARAMETER Filepath
        Provide the path to save the file.
        Eg., C:\Windows

        .PARAMETER FileName
        Provide the name of the file to save the credentials.
        Eg., MyPasswordFile

        .EXAMPLE
        Save-Password -Credentials @{Username="MyUsername";Password="Password"}

        .EXAMPLE
        Save-Password -Credentials @{Username="MyUsername";Password="Password"} -Verbose

        .EXAMPLE
        Save-Password -Credentials @{Username="MyUsername";Password="Password"} -FilePath "C:\TEMP" -FileName "MyPasswordFile" -Verbose

        .EXAMPLE
        Save-Password -Credentials (Get-Password)

        .EXAMPLE
        Save-Password -Credentials (Get-Password -PasswordLength 10) -Verbose

        .EXAMPLE
        Save-Password -Credentials (Get-Password -PasswordLength 10)

        .EXAMPLE
        Get-Password | Save-Password

        .NOTES
        Author						Version			    Date			Notes
        --------------------------------------------------------------------------------------------------
        harish.karthic		        v1.0.0.1			27/12/2019		Initial script
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [PSCustomObject]$Credentials,

        [Parameter(Mandatory=$false)]
        [String]$FilePath,

        [Parameter(Mandatory=$false)]
        [String]$FileName
    )
    
    begin {
        # initialize function variables
        $functionName = $MyInvocation.MyCommand.Name
        $Directory = "$env:SystemRoot\SimplePasswordGenerator"

        If(!(Test-Path -Path $Directory)) {
            New-Item -ItemType Directory -Path $Directory | Out-Null
        }

        # region declare file location
        If($FileName -eq "") {
            $FileName = $env:USERNAME
        }

        If($FilePath -eq "") {            
            $FilePath = "$Directory\$($FileName)_$(Get-Date -Format ddMMyyyy).xml"
        }
        else {
            $FilePath = $FilePath.TrimEnd("\") + "\$($FileName)_$(Get-Date -Format ddMMyyyy).xml"
        }        
        # endregion declare file location

        $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Begin function"
        Write-Verbose $Message
    }
    
    process {        
        try {
            # region save credentials
            $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Converting the provided credentials to secure string"
            Write-Verbose $Message

            $SecurePassword = [PSCredential]::new($Credentials.Username,($Credentials.Password | ConvertTo-SecureString -AsPlainText -Force))
            
            $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Saving the file in $($FilePath)"
            Write-Verbose $Message

            $SecurePassword | Export-Clixml -Path $FilePath
            # endregion save credentials
        }
        catch {
            Write-Host " [$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Error at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message).." -ForegroundColor Red
        }            
    }
    
    end {
        $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : End function"
        Write-Verbose $Message
    }
}
Export-ModuleMember -Function Save-Password