<#
.SYNOPSIS
Configures Git with GPG and SSH
#>
param ( $Email, $UserName, $KeyID = '$KeyID' )
$EmailTest = $null -eq $Email
$UserNameTest = $null -eq $UserName
if ( $EmailTest -or $UserNameTest ) {
    throw 'No email or username provided, input them as an argument'
}
if ( !( [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator" ) ) {
    Write-Warning -Message "Administrator rights recommended"
}
function RefreshPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable( 'Path', 'Machine' ) + ';' + [System.Environment]::GetEnvironmentVariable( 'Path', 'User' )
}

#Install Git
winget install --id Git.Git -e -s winget -i
RefreshPath

#Configure GH CLI
winget install GitHub.GitHubDesktop GitHub.cli -e -s winget
RefreshPath
gh auth login -s admin:gpg_key,admin:public_key

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
gh ssh-key add ~/.ssh/id_ed25519.pub

#Configure Git
git config --global user.email "$Email"
git config --global user.name "$UserName"
git config --global --unset gpg.format
git config --global user.signingkey $KeyID
git config --global commit.gpgsign true
git config --global tag.gpgSign true
#!Line bellow is a workaround for GitHub Desktop
git config --global gpg.program "C:\Program Files\Git\usr\bin\gpg.exe"
"@
Write-Output $BashPart | Out-File BashPart.sh
& $env:ProgramFiles'\Git\usr\bin\bash.exe' -l BashPart.sh
Remove-Item -Path BashPart.sh

#Configure Commitizen
#?Is winget NodeJS packege officially supported?
winget install --id OpenJS.NodeJS.LTS -e -s winget
RefreshPath
npx get-pnpm
RefreshPath
pnpm install -g commitizen cz-conventional-changelog
Write-Output -InputObject '{ "path": "cz-conventional-changelog" }' > ~\.czrc
