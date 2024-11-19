#Requires -RunAsAdministrator
<#
.SYNOPSIS
Lists all programs installed on a sysytem
#>
Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName | Out-File -FilePath .\All_Appx_packages.txt
Get-WmiObject -Class Win32_Product | Select-Object Name | Out-File -FilePath .\All_apps.txt
