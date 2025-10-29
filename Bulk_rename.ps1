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
        $ProposedName = $OriginalProposedName + ' (' + $i + ')'
    }
    $script:UsedDates += "$ProposedName"
    return $ProposedName
}

Get-ChildItem -File | Sort-Object -Property CreationTime | ForEach-Object -Process {
    if ( $_.LastWriteTime -le $_.CreationTime ) {
        $CreationDate = $_.LastWriteTime.ToString( 'dd-MM-yyyy' )
    }
    else {
        $CreationDate = $_.CreationTime.ToString( 'dd-MM-yyyy' )
    }
    $Extension = $_.Extension
    $FinalName = CheckName -ProposedName $CreationDate
    Rename-Item -Path $_.Name -NewName $FinalName$Extension
}
