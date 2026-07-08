#Requires -RunAsAdministrator
<#
.SYNOPSIS
Set default editor for .bat, .cmd and .ps1 "Edit" context menu option
#>
param ( $EditorPath, $Reset )
if ( $Reset -eq $true ) {
    Remove-Item -Path 'HKCU:\Software\Classes\batfile\shell\edit' -Recurse
    Remove-Item -Path 'HKCU:\Software\Classes\cmdfile\shell\edit' -Recurse
    Remove-Item -Path 'HKCU:\Software\Classes\SystemFileAssociations\.ps1\shell\edit' -Recurse
    exit
}
if ( $null -eq $EditorPath ) {
    throw 'No editor path provided, input it as an argument'
}

#Set the Editor environment variable and add it to registry
[Environment]::SetEnvironmentVariable('Editor', "$EditorPath", 'User')
New-Item -Path 'HKCU:\Software\Classes\batfile\shell\edit\command' -Value '%EDITOR% %1' -ItemType ExpandString -Force
New-Item -Path 'HKCU:\Software\Classes\cmdfile\shell\edit\command' -Value '%EDITOR% %1' -ItemType ExpandString -Force
New-Item -Path 'HKCU:\Software\Classes\SystemFileAssociations\.ps1\shell\edit\command' -Value '%EDITOR% %1' -ItemType ExpandString -Force
Write-Warning -Message 'Reboot recommended'
