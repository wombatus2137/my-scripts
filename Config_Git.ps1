<#
.SYNOPSIS
Configures Git with GPG and SSH
#>
param ( $Email, $UserName, $KeyID )
$EmailTest = $null -eq $Email
$UserNameTest = $null -eq $UserName
if ( $EmailTest -or $UserNameTest ) {
    throw 'No email or username provided, input them as an argument'
}
if ( $null -eq $KeyID ) {
    $KeyID = '$KeyID'
}
if ( !( [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator" ) ) {
    Write-Warning -Message "Administrator rights recommended"
}
function RefreshPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable( 'Path', 'Machine' ) + ';' + [System.Environment]::GetEnvironmentVariable( 'Path', 'User' )
}

#Install Git
winget install --id Git.Git -e --source winget -i
RefreshPath

#Configure GH CLI
winget install --id GitHub.cli
RefreshPath
gh auth login -s write:gpg_key,admin:ssh_signing_key
gh extension install github/gh-copilot

#!GPG provided by Git is partially broken, so this is a workaround
#Export script to bash
$BashPart = @"
#!/bin/bash
#Prepare GPG key
if [ -z "$KeyID" ]; then
    gpg --full-generate-key
    gpg --list-secret-keys --keyid-format=long
    read -p 'Enter enter key ID you want to use: ' KeyID
fi

#Prepare SSH key
ssh-keygen -t ed25519 -C "$Email"

#Upload keys to GitHub
gpg --armor --export $KeyID | gh gpg-key add
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing

#Configure Git
git config --global user.email "$Email"
git config --global user.name "$UserName"
git config --global --unset gpg.format
git config --global user.signingkey $KeyID
git config --global commit.gpgsign true
git config --global tag.gpgSign true
"@
Write-Output $BashPart | Out-File BashPart.sh
& $env:ProgramFiles'\Git\usr\bin\bash.exe' -l BashPart.sh
Remove-Item -Path BashPart.sh

#Configure Commitizen
#? Is winget NodeJS packege officially supported?
winget install -e OpenJS.NodeJS.LTS
RefreshPath
npm install -g commitizen
npm install -g cz-conventional-changelog
Write-Output -InputObject '{ "path": "cz-conventional-changelog" }' > ~/.czrc
