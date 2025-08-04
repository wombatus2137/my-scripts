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
function RefreshPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable( 'Path', 'Machine' ) + ';' + [System.Environment]::GetEnvironmentVariable( 'Path', 'User' )
}

#Install Git
winget install --id Git.Git -e --source winget -i
RefreshPath

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

#Configure GH CLI
winget install --id GitHub.cli
RefreshPath
gh auth login
gh extension install github/gh-copilot

#Configure Commitizen
choco install nodejs
RefreshPath
npm install -g @commitlint/prompt @commitlint/config-conventional commitizen
Write-Output -InputObject '{ "path": "@commitlint/prompt" }' > ~/.czrc
