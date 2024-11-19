<#
.SYNOPSIS
Updates all programs and PowerShell modules installed on a sysytem
#>
winget upgrade -r -u --accept-package-agreements --accept-source-agreements
Update-Module
