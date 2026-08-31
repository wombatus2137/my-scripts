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
    $EditorPath = Read-Host -Prompt 'Input editor path in Windows variables format like (%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe)'
}

[Environment]::SetEnvironmentVariable('EDITOR', "${EditorPath}", 'User')
New-Item -Path 'HKCU:\Software\Classes\batfile\shell\edit\command' -Value '%EDITOR% %1' -ItemType ExpandString -Force
New-Item -Path 'HKCU:\Software\Classes\cmdfile\shell\edit\command' -Value '%EDITOR% %1' -ItemType ExpandString -Force
New-Item -Path 'HKCU:\Software\Classes\SystemFileAssociations\.ps1\shell\edit\command' -Value '%EDITOR% %1' -ItemType ExpandString -Force
Write-Warning -Message 'Reboot recommended'
