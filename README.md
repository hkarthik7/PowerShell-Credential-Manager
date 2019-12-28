## POWERSHELL CREDENTIALS MANAGER
    This repository contains scripts to create random passwords and to manage it.

## MODULE EXPLANATION
    The entire project is developed as a PowerShell module and can be used as a tool. However, each script has its own
    functionality and can be used individually. 
    All the scripts are designed as advanced functions and meant to be used as a module.

## HOW TO USE
    1. Download the entire folder
    2. Create a folder called "CredentialManager" under C:\Users\<UserName>\Documents\WindowsPowerShell\Modules\CredentialManager
    and copy all the scripts inluding .psd1 and .psm1 script files.
    3. Now open PowerShell console as admin and run "Import-Module CredentialManager -Force" without double quotes.
    4. Now run Get-Password to generate the password and Save-Password to save it securely.

## TIPS
    1. To show the examles and full details of the scripts run "Get-Help Get-Password -Detailed" respectively for other
    scripts.
    2. To save the password that is generated run Get-Password | Save-Password

## TODO :
    Add functionality to update the generated passwords to user accounts locally and remotely.
    Add functionality to update the password in Active Directory for given accounts.