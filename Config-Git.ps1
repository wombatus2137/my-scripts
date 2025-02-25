#Requires -RunAsAdministrator
<#
.SYNOPSIS
Configures Git with GPG signing
#>
param ( $Email, $UserName )
$EmailTest = $null -eq $Email
$UserNameTest = $null -eq $UserName
if ( $EmailTest -or $UserNameTest ) {
    throw 'No email or username provided, input them as an argument'
}

#Install programs
winget install --id Git.Git -e --source winget -i
winget install --id GitHub.cli

#Refresh the PATH environment variable
$env:Path = [System.Environment]::GetEnvironmentVariable( 'Path', 'Machine' ) + ';' + [System.Environment]::GetEnvironmentVariable( 'Path', 'User' ) 

#Make sure the gpg command can be run even if gpg is not in the PATH
function gpg {
    & 'C:\Program Files\Git\usr\bin\gpg.exe' $args
}

#Prepare GPG key
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
$KeyID= Read-Host 'Enter enter key ID you want to use'

#Prints the GPG key ID, in ASCII armor format
gpg --armor --export $KeyID

#Configure Git
git config --global user.email "$Email"
git config --global user.name "$UserName"
git config --global --unset gpg.format
git config --global user.signingkey $KeyID
git config --global commit.gpgsign true
git config --global tag.gpgSign true

#Prepare GH CLI
gh auth login
gh extension install github/gh-copilot
