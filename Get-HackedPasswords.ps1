function Get-HackedPasswords {
    <#
        .SYNOPSIS
        This script returns the count of hacks for the supplied passwords.

        .DESCRIPTION
        This script is designed to produce a table of supplied passwords
        and returns how many times the supplied passwords are hacked.

        .PARAMETER secureStringList
        Provide the passwords to find how many times it has been hacked.

        .EXAMPLE
        Get-HackedPasswords `
            -secureStringList "Hello", "hello", `
            "Password123", "test", "eoir3rewjdkj,sdnliewu","hhe" `
            -Verbose

        .NOTES
        Author						Version			   Date			Notes
        --------------------------------------------------------------------------------------------------
        harish.karthic		        v1.0			27/01/2020		Initial script
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)]        
        [String[]]$secureStringList
    )
    
    begin {
        #initialize function variables
        if (!($PSBoundParameters.ContainsKey("secureStringList"))) {
            $Params = @{
                Exception         = "secureStringList argument cannot be null or empty."
                Message           = "Enter 1 or more arguments an retry."
                Category          = "NullArgument"
                ErrorId           = "GP02"
                RecommendedAction = "Re-run the script after passing one or more arguments"
            }
            Write-Error @Params
            exit 0
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        $LogFile = "$env:TMP\Hacked_Password_Counts_$(Get-Date -Format ddMMyyyy).log"
        $encoding = [System.Text.Encoding]::UTF8
        $result = @()
        $hackedCount = @()

        $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Begin function"
        Write-Verbose $Message ; $Message | Out-File -Append $LogFile
    }
    
    process {
        
        try {

            $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Retrieving hacked counts for supplied strings"
            Write-Verbose $Message ; $Message | Out-File -Append $LogFile

            foreach ($string in $secureStringList) {
                
                $SHA1Hash = New-Object -TypeName "System.Security.Cryptography.SHA1CryptoServiceProvider"
                $Hashcode = ($SHA1Hash.ComputeHash($encoding.GetBytes($string)) | `
                        ForEach-Object { "{0:X2}" -f $_ }) -join ""
                
                $Start, $Tail = $Hashcode.Substring(0, 5), $Hashcode.Substring(5)

                $Url = "https://api.pwnedpasswords.com/range/" + $Start
                $Request = Invoke-RestMethod -Uri $Url -UseBasicParsing -Method Get
                
                $hashedArray = $Request.Split()

                foreach ($item in $hashedArray) {

                    if (!([string]::IsNullOrEmpty($item))) {
                        $encodedPassword = $item.Split(":")[0]
                        $count = $item.Split(":")[1]
                        $Hash = [PSCustomObject]@{
                            "HackedPassword" = $encodedPassword.Trim()
                            "Count"          = $count.Trim()
                        }
                        $result += $Hash
                    }  
                }

                foreach ($pass in $result) {
                    if($pass.HackedPassword -eq $Tail) {
                        $newHash = [PSCustomObject]@{
                            Name = $string
                            Count = $pass.Count
                        }
                        $hackedCount += $newHash
                    }
                }

                if ($string -notin $hackedCount.Name) {
                    $finalHash = [PSCustomObject]@{
                        Name = $string
                        Count = 0
                    }
                    $hackedCount += $finalHash
                }
            }

            $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Successfully retrieved the results"
            Write-Verbose $Message ; $Message | Out-File -Append $LogFile          
        }
        catch {
            Write-Host " [$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Error at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)" -ForegroundColor Red
            " [$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : Error at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)" | Out-File $LogFile -Append
        }
    }
    
    end {
        $Message = "[$(Get-Date -UFormat %Y/%m/%d_%H:%M:%S)] $functionName : End function"
        Write-Verbose $Message ; $Message | Out-File -Append $LogFile

        return $hackedCount
    }
}
#EOF