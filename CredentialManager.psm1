## Root Module file
Get-ChildItem -Path "$($PSScriptRoot)\*.ps1" | ForEach-Object {.$_.FullName}