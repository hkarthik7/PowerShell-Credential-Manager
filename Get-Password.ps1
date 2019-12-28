Function Get-Password {
    <#
        .SYNOPSIS
        This script generates random password with the given password length.

        .DESCRIPTION
        This script is designed to generate random and strong password for
        the given password length. This helps to adhere to the organisation's
        strong password suggestion/standards by helping the users to create a random and
        strong password.

        .PARAMETER PasswordLength
        Provide the length of your password.
        Example : 10 
        NOTE : The Maximum allowed value is 90.

        .EXAMPLE
        Get-Password

        Name12h)tU

        .EXAMPLE
        Get-Password -PasswordLength 10

        (=:y&!$^4O

        .EXAMPLE
        Get-Password -PasswordLength 8 -Verbose

        VERBOSE: [2019/12/22_08:47:44]  : Begin function
        VERBOSE: [2019/12/22_08:47:44]  : Generating password of length 8
        VERBOSE: [2019/12/22_08:47:44]  : Generated Password : +;onIV%%
        VERBOSE: [2019/12/22_08:47:44]  : End function
        +;onIV%%
        
        .NOTES
        Author						Version			    Date			Notes
        --------------------------------------------------------------------------------------------------
        harish.karthic		        v1.0.0.0			23/12/2019		Initial script
        harish.karthic		        v1.0.0.1			23/12/2019		Converted to advanced function
        harish.karthic		        v1.0.0.2			27/12/2019		Added logging functionality
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [Int]$PasswordLength,

        [Parameter(Mandatory=$false)]
        [String]$LogPath
    )

    begin {
        # initialize function variables
        $functionName = $MyInvocation.MyCommand.Name
        $Char = [char[]](33..122)
        $Name = $env:USERNAME
        $Domain = $env:USERDOMAIN
        $NewChar = @()
        $DefaultPassLength = 4
        
        If($LogPath -eq "") {
            $LogPath = $env:SystemRoot
        }

        $LogFile = "$LogPath\GetPassword_$(Get-Date -Format ddMMyyyy).log"

        $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Begin function"
        Write-Verbose $Message | Out-File $LogFile -Append
    }

    process {
        
        If($PasswordLength -ne "") {

            # Validating if the given password length is within 90
            $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Validating given length $($PasswordLength)"
            Write-Verbose $Message | Out-File $LogFile -Append

            If($PasswordLength -gt 90) {
                $Params = @{
                    Exception = "Entered Value is more than the allowed limit 90"
                    Message = "Enter the correct value and retry"
                    Category = "InvalidArgument"
                    ErrorId = "GP1"
                    RecommendedAction = "Re-run the script with correct argument"
                }
                Write-Error @Params
                exit 0
            }

            else {
                try {
                    $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Generating password of length $($PasswordLength)"
                    Write-Verbose $Message | Out-File $LogFile -Append

                    # region generating password

                    For($i=0; $i -lt $Char.Count; $i++) {
                        $NewChar += $Char[$i]
                    }
                    
                    [String]$Password = Get-Random -InputObject $NewChar -Count $PasswordLength
                    $Password = $Password.Replace(" ","")
                    
                    $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Generated Password"
                    Write-Verbose $Message | Out-File $LogFile -Append

                    # endregion generating password

                    # region display results

                    $Passwordresults = [PSCustomObject]@{
                        Username = "$Domain\$Name"
                        Password = $Password
                    }

                    # endregion display results
                }
                Catch {
                    Write-Host " [$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Error at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message).." -ForegroundColor Red | Out-File $LogFile -Append
                }
            }
        }

        else {

            $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Generating default password"
            Write-Verbose $Message | Out-File $LogFile -Append
            try {

                # region generate default password

                For($i=0; $i -lt $Char.Count; $i++) {
                    $NewChar += $Char[$i]
                }

                # Trim the length of Name if it is more than 6 chars
                If($Name.Length -gt 6) {
                    $Name = $Name.Substring(0,6)
                }

                # Set default password
                [String]$DefaultPassword = $Name + (Get-Random -InputObject $NewChar -Count $DefaultPassLength)
                $DefaultPassword = $DefaultPassword.Replace(" ","")

                # endregion generate default password
                
                # region display results

                $Passwordresults = [PSCustomObject]@{
                    Username = "$Domain\$Name"
                    Password = $DefaultPassword
                }

                # endregion display results
            }
            catch {
                Write-Host " [$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Error at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message).." -ForegroundColor Red | Out-File $LogFile -Append
            }
        }
    }

    end {
        $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : End function"
        Write-Verbose $Message | Out-File $LogFile -Append
        
        return $Passwordresults
    }
}
Export-ModuleMember -Function Get-Password