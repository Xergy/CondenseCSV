
$Input_All = Import-Csv ".\input.csv"

$Rows = @() 

foreach ($Row in $Input_All) {
    $Props = @{
        NewTaskId = $Row.TaskID
        NewBugId = $Row.BugId
        NewComment = $Row.Comment
    }

    # Create Object with Summary Data
    # NOTE:  The select-object -Property statement "orders" the columns!!!
    $NewRow = New-Object psobject -Property $Props | Select-Object -Property NewTaskId,NewBugId,NewComment

    # Add Row Summary to Summary Array
    $Rows += $NewRow

}

#$Rows

# Export to CSV
$Rows | Export-Csv -Path ".\Output_RenameColumns.csv" -Force -NoTypeInformation

ii ".\Output_RenameColumns.csv"




