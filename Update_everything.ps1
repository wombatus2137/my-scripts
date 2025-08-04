<#
.SYNOPSIS
Updates all programs and PowerShell modules installed on a sysytem
#>
if ( !( [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator" ) ) {
    Write-Warning -Message "Administrator rights recommended"
}
winget upgrade -r --accept-package-agreements --accept-source-agreements
Update-Module
gh extension upgrade --all
python.exe -m pip install --upgrade pip
