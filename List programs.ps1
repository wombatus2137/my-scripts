Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName | Out-File -FilePath .\All Appx packages.txt
Get-WmiObject -Class Win32_Product | Select-Object Name | Out-File -FilePath .\All apps.txt
