#Requires -RunAsAdministrator
<#
.SYNOPSIS
Configures SSH client
#>
param ( $RemoteUser, $Server = 'localhost' )
$RemoteUserTest = $null -eq $RemoteUser
if ( $RemoteUserTest )
{
    throw 'No remote user provided, input remote username as an argument'
}
if ( $Server -eq $null )
{
    Write-Warning -Message 'No server provided - using localhost'
}
Write-Warning -Message 'Configure server first'

#Generate new SSH key
ssh-keygen -t ecdsa

#Set the ssh-agent service to be started automatically
Get-Service -Name ssh-agent | Set-Service -StartupType Automatic

#Start the service
Start-Service -Name ssh-agent

#This should return a status of Running
Get-Service -Name ssh-agent

#Load your key files into ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ecdsa

#Copy public key to the server
scp $env:USERPROFILE/.ssh/id_ecdsa.pub $RemoteUser@"$Server":C:\ProgramData\ssh\
