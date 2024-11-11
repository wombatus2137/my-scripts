#Requires -RunAsAdministrator
<#
.SYNOPSIS
Installs Oh My Posh with default configuration
#>
#Install a Nerd Font
$FontTest = Test-Path -Path $env:LOCALAPPDATA'\Microsoft\Windows\Fonts\CaskaydiaCoveNerdFont-Regular.ttf'
$ArchiveTest = Test-Path -Path .\CascadiaCode.zip
if ( !$FontTest )
{
    if ( !$ArchiveTest )
    {
        Invoke-WebRequest -Uri https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip -OutFile .\CascadiaCode.zip
    }
    Expand-Archive -Path .\CascadiaCode.zip
    Get-ChildItem *.ttf | ForEach-Object -Process {
        ( ( New-Object -ComObject Shell.Application ).Namespace( 0x14 ) ).CopyHere( $_.FullName )
    }
}

#Set Terminal font
$SourceJSONTest = Test-Path -Path .\custom_prompt.json
if ( $SourceJSONTest )
{
    New-Item -Path $env:LOCALAPPDATA'\Microsoft\Windows Terminal\Fragments\custom_prompt' -Type Directory
    Copy-Item -Path .\custom_prompt.json -Destination $env:LOCALAPPDATA'\Microsoft\Windows Terminal\Fragments\custom_prompt\custom_prompt.json'
}
else
{
    Write-Error -Message 'Cannot find custom_prompt.json' -Category ObjectNotFound -RecommendedAction 'Download custom_prompt.json from the script source to script''s directory, then rerun the script.'
}

#Setup Oh My Posh
winget install JanDeDobbeleer.OhMyPosh -s winget
#*Other good themes are: paradox and cobalt2
$RunOhMyPosh = 'oh-my-posh init pwsh --config ~/jandedobbeleer.omp.json | Invoke-Expression'
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#Setup Terminal-Icons
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Terminal-Icons -Repository PSGallery
Set-TerminalIconsTheme -IconTheme devblackops -ColorTheme devblackops
$RunTerminalIcons = 'Import-Module -Name Terminal-Icons'

#Write PowerShell profile
$PROFILETest = Test-Path -Path $PROFILE
if ( !$PROFILETest )
{
    New-Item -Path $PROFILE -Type File -Force
}
Add-Content -Path $PROFILE -Value $RunTerminalIcons, $RunOhMyPosh
