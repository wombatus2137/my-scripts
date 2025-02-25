#Requires -RunAsAdministrator
<#
.SYNOPSIS
Configures SSH server
#>
#Set current shell as default for SSH
$ShellExecPath = ( Get-Process -Id $PID ).Path
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value $ShellExecPath -PropertyType String -Force

#Set the sshd service to be started automatically
Get-Service -Name sshd | Set-Service -StartupType Automatic

#Start the sshd service
Start-Service -Name sshd
