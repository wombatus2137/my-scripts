<#
.SYNOPSIS
Renames all files in current directory to their creation dates
#>
$UsedDates = @()
function CheckName {
    param ( $ProposedName )
    $i = 0
    $OriginalProposedName = $ProposedName
    while ( $UsedDates -contains $ProposedName) {
        $i++
        $ProposedName = $OriginalProposedName + ' (' + $i + ")"
    }
    return $ProposedName
}

Get-ChildItem | ForEach-Object -Process {
    $CreationDate = $_.CreationTime.ToString( ( Get-Culture ) )
    $Extension = $_.Extension
    $FinalName = CheckName -ProposedName $CreationDate
    Rename-Item -Path $_.Name -NewName $FinalName$Extension
}
