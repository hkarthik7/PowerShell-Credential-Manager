Function Show-Password {
    <#
        .SYNOPSIS
        This script decryptes the credentials from a secured xml file.

        .DESCRIPTION
        This script is designed to show the credentials which are encrypted in a xml file.

        .PARAMETER FilePath
        Provide the location of encrypted file.
        Eg., C:\Windows\MyPasswordFile.xml

        .EXAMPLE
        Show-Password -FilePath C:\Windows\MyPasswordFile.xml -Verbose

        .EXAMPLE
        "C:\TEMP\MyPasswordFile.xml" | Show-Password

        .NOTES
        Author						Version			    Date			Notes
        --------------------------------------------------------------------------------------------------
        harish.karthic		        v1.0.0.0			27/12/2019		Initial script
        harish.karthic		        v1.0.0.1			27/12/2019		Added loggin functionality
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$FilePath,

        [Parameter(Mandatory=$false)]
        [String]$LogPath
    )
    
    begin {
        # initialize function variables
        $functionName = $MyInvocation.MyCommand.Name
        
        If($LogPath -eq "") {
            $LogPath = $env:SystemRoot
        }
        
        $LogFile = "$LogPath\ShowPassword_$(Get-Date -Format ddMMyyyy).log"

        $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Begin function"
        Write-Verbose $Message | Out-File $LogFile -Append
    }
    
    process {        
        try {
            # region show credentials
            $PasswordFileName = Split-Path $FilePath -Leaf

            $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Decrypting the password from $($PasswordFileName)"
            Write-Verbose $Message | Out-File $LogFile -Append

            $DecryptFile = Import-Clixml -Path $FilePath
            $DecryptPassword = $DecryptFile.GetNetworkCredential().Password

            $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Credentials are decrypted"
            Write-Verbose $Message | Out-File $LogFile -Append

            $DecryptedCredentials = [PSCustomObject]@{
                Username = $DecryptFile.UserName
                Password = $DecryptPassword
            }           
            # endregion show credentials
        }
        catch {
            Write-Host " [$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Error at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message).." -ForegroundColor Red | Out-File $LogFile -Append
        }            
    }
    
    end {
        $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : End function"
        Write-Verbose $Message | Out-File $LogFile -Append

        return $DecryptedCredentials
    }
}
Export-ModuleMember -Function Show-Password