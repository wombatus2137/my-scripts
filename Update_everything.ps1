<#
.SYNOPSIS
Updates all programs and PowerShell modules installed on a sysytem
#>
winget upgrade -r -u --accept-package-agreements --accept-source-agreements
Update-Module
gh extension upgrade --all
python.exe -m pip install --upgrade pip
