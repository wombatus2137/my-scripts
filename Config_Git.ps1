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

#!GPG provided by Git is partially broken, so this is a workaround
#Export script to bash to prepare GPG key
$BashPart = @'
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
read -p 'Enter enter key ID you want to use: ' KeyID
gpg --armor --export $KeyID
'@
Write-Output $BashPart | Out-File BashPart.sh
& $env:ProgramFiles'\Git\usr\bin\bash.exe' BashPart.sh
Remove-Item -Path BashPart.sh

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
