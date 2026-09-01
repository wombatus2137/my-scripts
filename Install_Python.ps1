<#
.SYNOPSIS
Installs Python with pipx
#>
function RefreshPath {
    $env:PATH = [Environment]::GetEnvironmentVariable( 'Path', 'Machine' ) + ';' + [Environment]::GetEnvironmentVariable( 'Path', 'User' )
}

#Install Python
winget install --id 9NQ7512CXL7T -e
RefreshPath
pymanager install --configure
RefreshPath

#Install pipx
python3 -m pip install -U --user pipx setuptools
[Environment]::SetEnvironmentVariable( 'Path', "${env:PATH};${env:APPDATA}\Python\Python314\Scripts", 'User' )
RefreshPath
python3 -m pipx ensurepath
