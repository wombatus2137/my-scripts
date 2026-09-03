#Requires -RunAsAdministrator
<#
.SYNOPSIS
Installs Oh My Posh with default configuration
#>
param ( $Reset )
if ( $Reset -eq $true ) {
    Remove-Item -Path "${env:LOCALAPPDATA}\Microsoft\Windows Terminal\Fragments\custom_prompt" -Recurse
    New-Item -Path "${PROFILE}" -Type File -Force
    exit
}

#Install a Nerd Font
$FontDestination = "${env:LOCALAPPDATA}\Microsoft\Windows\Fonts\CascadiaCodeNF.ttf"
$ArchiveDestination = "${PSScriptRoot}\CascadiaCode.zip"
if ( !( Test-Path -Path "${FontDestination}" ) ) {
    if ( !( Test-Path -Path "${$ArchiveDestination}" ) ) {
        Invoke-WebRequest -Uri https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip -OutFile "${ArchiveDestination}"
    }
    Expand-Archive -Path "${ArchiveDestination}"
    Get-ChildItem -Path "${PSScriptRoot}\CascadiaCode\ttf\Cascadia*NF*.ttf" | ForEach-Object -Process {
        ( ( New-Object -ComObject Shell.Application ).Namespace( 0x14 ) ).CopyHere( $_.FullName )
    }
    Write-Warning -Message 'Reboot to complete font installation'
}

#Disable telemetry
[Environment]::SetEnvironmentVariable( 'POWERSHELL_TELEMETRY_OPTOUT', 'true', 'Machine' )

#Create Windows Terminal JSON fragment to set font
$FragmentJson = @'
{
  "profiles": [
    {
      "updates": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
      "font": 
      {
        "face": "Cascadia Code NF"
      },
      "opacity": 70,
      "useAcrylic": true
    },
    {
      "updates": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
      "font": 
      {
        "face": "Cascadia Code NF"
      },
      "opacity": 70,
      "useAcrylic": true
    }
  ]
}
'@
New-Item -Path "${env:LOCALAPPDATA}\Microsoft\Windows Terminal\Fragments\custom_prompt" -Type Directory
Write-Output $FragmentJson | Out-File "${env:LOCALAPPDATA}\Microsoft\Windows Terminal\Fragments\custom_prompt\custom_prompt.json" -Encoding Utf8

#Setup Oh My Posh
winget install --id JanDeDobbeleer.OhMyPosh -e -s winget
#*Other good themes are: jandedobbeleer and paradox
Invoke-WebRequest -Uri https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json -OutFile "${env:USERPROFILE}\cobalt2.omp.json"
$RunOhMyPosh = 'oh-my-posh init pwsh --config "${env:USERPROFILE}\cobalt2.omp.json" | Invoke-Expression'
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

#Setup Terminal-Icons
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Terminal-Icons -Repository PSGallery
Set-TerminalIconsTheme -IconTheme devblackops -ColorTheme devblackops
$RunTerminalIcons = 'Import-Module -Name Terminal-Icons'

#Import Chocolatey Profile
$ChocolateyProfile = "${env:ChocolateyInstall}\helpers\chocolateyProfile.psm1"
if ( Test-Path -Path "${ChocolateyProfile}" ) {
    $ImportChocolateyProfile = @'
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "${env:ChocolateyInstall}\helpers\chocolateyProfile.psm1"
if ( Test-Path -Path "${ChocolateyProfile}" ) {
  Import-Module "${ChocolateyProfile}"
}
'@
}

#Setup pipx completion
$pipxPath = "${env:APPDATA}\Python\Python314\Scripts\pipx.exe"
if ( Test-Path -Path "${pipxPath}" ) {
    register-python-argcomplete -s powershell pipx | Out-File -FilePath "${env:USERPROFILE}\pipx.psm1"
    $ImportpipxCompletion = 'Import-Module "${env:USERPROFILE}\pipx.psm1"'
}

#Write PowerShell profile
if ( !( Test-Path -Path "${PROFILE}" ) ) {
    New-Item -Path "${PROFILE}" -Type File -Force
}
$Aliases = @'
function ipa { ipconfig /all }
function gs { git status }
function gf { git fetch }
function gpu {
    git fetch
    git pull 
}
function lazyg {
    git add .
    cz
    git push
}
function touch { New-Item -Path $args }
function reboot { shutdown /r /t 0 }
'@
Add-Content -Path "${PROFILE}" -Value "${RunTerminalIcons}", "${RunOhMyPosh}", "${ImportChocolateyProfile}", "${ImportpipxCompletion}", "${Aliases}"
