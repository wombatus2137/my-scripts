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
        Write-Warning -Message 'Reboot to complete font installation'
    }
}

#Create Windows Terminal JSON fragment to set font
$fragmentJson=@'
{
  "profiles": [
    {
      "updates": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
      "font": 
      {
        "face": "CaskaydiaCove Nerd Font"
      },
      "opacity": 70,
      "useAcrylic": true
    },
    {
      "updates": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
      "font": 
      {
        "face": "CaskaydiaCove Nerd Font"
      },
      "opacity": 70,
      "useAcrylic": true
    }
  ]
}
'@
New-Item -Path $env:LOCALAPPDATA'\Microsoft\Windows Terminal\Fragments\custom_prompt' -Type Directory
Write-Output $fragmentJson | Out-File $env:LOCALAPPDATA'\Microsoft\Windows Terminal\Fragments\custom_prompt\custom_prompt.json' -Encoding Utf8

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
$IPAAlias = 'function ipa {ipconfig /all}'
Add-Content -Path $PROFILE -Value $RunTerminalIcons, $RunOhMyPosh, $IPAAlias
