# CondenseCSV.ps1 Summary!
#
# This sample script...
# 1. Loads an input.csv
# 2. Concatenates all BugIds and Comments, per TaskID into a Summary Object Array
# 3. Filters input.csv for each of the last row of each unique TaskID
# 4. Added BugId and Comment Summary data to each row
# 5. Creates output.csv



$Input_All = Import-Csv ".\input.csv"

# Get all unique Task IDs.

$TaskIds_Unique = ($Input_All | Group-Object -Property TaskId).Name


# Loop on Unique TaskIDs, Filter on a single TaskID, Contactinatecreate array of $TaskID_Summary

$TaskID_Summary = @()

foreach ($TaskID in $TaskIds_Unique) {
    Write-Host "TaskID = $($TaskID)"
    $TaskRows = $Input_All | Where-Object {$_.TaskID -eq $TaskID  }

    # Start with BugIDs, Save as BugIds_All

    $BugIds_All = (($TaskRows | Group-Object -Property BugId).Name | Where-Object {$_ -ne ""}) -join ","
    $BugIds_All

    # Next are Comments, Save ans Comments_All
    $Comments_All = (($TaskRows | Group-Object -Property Comment).Name | Where-Object {$_ -ne ""}) -join ","
    $Comments_All

    $Props = @{
        TaskID = $TaskID
        BugIds_All = $BugIds_All
        Comments_All = $Comments_All
    }

    # Create Object with Summary Data
    $TaskRow_Result = New-Object psobject -Property $Props | Select-Object -Property TaskID,BugIds_All,Comments_All
    
    # Add Row Summary to Summary Array
    $TaskID_Summary += $TaskRow_Result

}

#$TaskID_Summary

# Filter Input file for only one row for each TaskID

$InputRows_Unique = @()

foreach ($TaskID in $TaskIds_Unique) {
    # Grab one row
    $InputRow_Unique = $Input_All | Where-Object {$_.TaskID -eq $TaskID } | Select-Object -Last 1   
    
    # Add to Array
    $InputRows_Unique += $InputRow_Unique    

}

#$InputRows_Unique

# Join with Summary Data

$InputRowsWithSummary = @()

foreach ($Row in $InputRows_Unique) {
    # Get Summary Row
    $TaskID_Summary_Row = $TaskID_Summary | Where-Object {$Row.TaskID -eq $_.TaskID}

    $InputRowWithSummary = $Row | Select-Object *,
                                    @{N='BugIds_All';E={
                                        ($TaskID_Summary_Row.BugIds_All)
                                        }
                                    },
                                    @{N='Comments_All';E={
                                        ($TaskID_Summary_Row.Comments_All)
                                        }
                                    }
    $InputRowsWithSummary += $InputRowWithSummary
}

#$InputRowsWithSummary

# Export to CSV
$InputRowsWithSummary | Export-Csv -Path ".\output.csv" -Force -NoTypeInformation

ii ".\output.csv"

