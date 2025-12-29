#Requires -RunAsAdministrator
<#
.SYNOPSIS
Configures SSH client
#>
param ( $RemoteUser, $Server = 'localhost' )
Write-Warning -Message 'Configure server first'
if ( $null -eq $RemoteUser ) {
    throw 'No remote user provided, input remote username as an argument'
}
if ( $null -eq $Server ) {
    Write-Warning -Message 'No server provided - using localhost'
}

#Generate SSH key
$KeyTest = Test-Path -Path $env:USERPROFILE'\.ssh\id_ed25519'
if ( !$KeyTest ) {
    $Email = Read-Host -Prompt 'Email for SSH key'
    ssh-keygen -t ed25519 -C "$Email"
}

#Set the ssh-agent service to be started automatically
Get-Service -Name ssh-agent | Set-Service -StartupType Automatic

#Start the service
Start-Service -Name ssh-agent

#This should return a status of Running
Get-Service -Name ssh-agent

#Load your key files into ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519

#Copy public key to the server
scp $env:USERPROFILE\.ssh\id_ed25519.pub $RemoteUser@"$Server":C:\ProgramData\ssh\
