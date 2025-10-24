<#
.SYNOPSIS
Renames all files in current directory to their creation dates
#>
Get-ChildItem | ForEach-Object -Process {
    $CreationDate = $_.CreationTime.ToString( ( Get-Culture ) )
    $Extension = $_.Extension
    Rename-Item -Path $_.Name -NewName $CreationDate$Extension
}
