# Show-DataViewer: AI Development Context

> **Note to AI Assistants:** If you have been provided this document, you are being asked to help extend, implement, or create usage examples for the `Show-DataViewer` PowerShell function. Read the architecture and schemas below to understand how the viewer operates.

## What is Show-DataViewer?

`Show-DataViewer` is an advanced, highly dynamic WPF-based PowerShell GUI tool. It functions as a modern replacement for `Out-GridView`, but it supports async data refreshing, custom row-level and dataset-level actions (buttons), inline editing, live filtering, and color-coded rows. 

It is designed as a single PowerShell function (`Show-DataViewer.ps1`) that accepts pipeline input or a set of parameters to define how data is gathered, displayed, and manipulated.

## Core Parameters

When calling `Show-DataViewer`, the following parameters dictate its behavior:

- **`Data`** `[PSCustomObject[]]`: The initial array of objects to display.
- **`RefreshScript`** `[scriptblock]`: A scriptblock that executes asynchronously when the "Refresh" button is clicked. It must output an array of `PSCustomObject`.
- **`Columns`** `[string[]]`: An array defining the exact order and visibility of columns.
- **`ColorMapping`** `[hashtable]`: Maps specific string values of properties to WPF hex colors.
- **`Actions`** `[hashtable[]]`: Defines custom buttons/operations.
- **`Configuration`** `[hashtable]`: A flexible dictionary to pass state, overrides, or variables into your actions and refresh scripts.

## The Action Schema (Custom Buttons)

Actions are the core extensibility mechanism. They appear as buttons in the UI. When defining actions (either passing them via `-Actions` or embedding them in a built-in mode), they must follow this schema:

```powershell
@{
    Name         = 'Action Name'        # (Required) The label on the button.
    Scope        = 'Row'                # (Required) 'Row', 'Dataset', 'Both', or 'DoubleClick'.
    Icon         = '⚙️'                 # (Optional) Emoji or text to prepend to the button.
    ReturnToGrid = $true                # (Optional) If $true, automatically re-runs RefreshScript after execution.
    Script       = {                    # (Required) The logic to execute.
        param($Data, $Context)
        # $Data is the selected PSCustomObject (Row scope) or array of filtered objects (Dataset scope).
        # $Context contains $Context.Configuration and $Context.DataViewer.
        
        # If ReturnToGrid is $false, any returned string is shown in a MessageBox.
        # If ReturnToGrid is $true, any returned string is flashed on the status bar.
    }
}
```

### Scopes Explained:
- **`Row`**: Button appears in the side panel. Executes once for the currently selected row. `$Data` is a single object.
- **`Dataset`**: Button appears at the bottom. Executes against all currently *filtered/visible* rows. `$Data` is an array.
- **`Both`**: Appears in both places. `$Data` dynamically changes based on where it was clicked.
- **`DoubleClick`**: Invisible action triggered when a user double-clicks a row.

## Color Mapping Schema

Allows conditional formatting based on exact string matches of a property.
```powershell
$ColorMapping = @{
    Status = @{
        'Running' = '#D1FAE5' # Light Green
        'Stopped' = '#FECACA' # Light Red
    }
}
```

## Built-in "Explorer" Modes

`Show-DataViewer` can be instantly transformed into dedicated tools using switch parameters (e.g., `-ProcessExplorerMode`, `-ServiceManagerMode`, `-EventViewerMode`, `-FileExplorerMode`, `-NetStatMode`).

### How to Implement a New Built-in Mode:

If asked to create a new built-in mode directly inside `Show-DataViewer.ps1`, you must:
1. Add a `[switch]$MyNewMode` to the `param()` block.
2. In the `process` block, before the main WPF rendering, add an `if ($MyNewMode)` block.
3. Inside the block, define default values for `$ColorMapping`, `$Columns`, `$RefreshScript`, and `$Actions` **only if they are `$null`** (this allows users to override them).
4. If `$inputData` is null, invoke the `$RefreshScript` to get initial data.

**Example Pattern for a New Built-in Mode:**
```powershell
if ($MyNewMode) {
    if ($null -eq $ColorMapping) {
        $ColorMapping = @{ State = @{ 'Failed' = '#FECACA' } }
    }
    
    if ($null -eq $Columns) {
        $Columns = @('Name', 'State', 'Details')
    }

    if ($null -eq $RefreshScript) {
        $RefreshScript = { Get-MyCustomData }
    }

    $defaultActions = @(
        @{
            Name = 'Fix Issue'
            Scope = 'Row'
            ReturnToGrid = $true
            Script = {
                param($Data, $Context)
                Repair-MyCustomData -Name $Data.Name
                "Repaired $($Data.Name)"
            }
        }
    )

    if ($null -eq $Actions) { $Actions = $defaultActions }
    else { $Actions = @($defaultActions) + @($Actions) }

    if ($null -eq $inputData -or $inputData.Count -eq 0) {
        $inputData = & $RefreshScript
    }
    
    if ($Title -eq 'Data Viewer') { $Title = 'My New Mode' }
}
```

## AI Instructions
When creating a new script or extending `Show-DataViewer`:
- Always return clean `[PSCustomObject]` arrays from the data generation or `RefreshScript`.
- If an action modifies system state (e.g., stopping a process, altering a file), recommend `ReturnToGrid = $true` so the user instantly sees the UI update.
- Do not use `Write-Host` in the action scripts; instead, return a string, which the UI will display natively.
- Catch errors in action scripts and return the error message as a string so the UI can show the failure gracefully.

## Custom Usage Example: AD Privileged Account Watchtower

A real-world example of how to wrap `Show-DataViewer` in a custom script without altering the source function.

```powershell
# Requires the ActiveDirectory module
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# 1. Define the Refresh Script
$adRefreshScript = {
    $privilegedGroups = @('Domain Admins', 'Enterprise Admins', 'Schema Admins', 'Administrators')
    $staleDate = (Get-Date).AddDays(-90)

    # Get all users with required properties
    Get-ADUser -Filter * -Properties MemberOf, LastLogonDate, PasswordLastSet, Enabled -ErrorAction SilentlyContinue | ForEach-Object {
        
        # Check if privileged
        $isPrivileged = $false
        foreach ($group in $_.MemberOf) {
            foreach ($privGroup in $privilegedGroups) {
                if ($group -match "CN=$privGroup,") {
                    $isPrivileged = $true
                    break
                }
            }
            if ($isPrivileged) { break }
        }

        # Determine Stale Status
        $staleStatus = "Active"
        if ($_.Enabled -eq $false) {
            $staleStatus = "Disabled"
        } elseif ($_.LastLogonDate -lt $staleDate -and $_.LastLogonDate -ne $null) {
            $staleStatus = "Stale"
        }

        # Return custom object
        [PSCustomObject]@{
            SamAccountName  = $_.SamAccountName
            Name            = $_.Name
            Enabled         = $_.Enabled
            IsPrivileged    = $isPrivileged
            Status          = $staleStatus
            LastLogonDate   = $_.LastLogonDate
            PasswordLastSet = $_.PasswordLastSet
        }
    }
}

# 2. Define Color Mapping (Reds-out stale privileged accounts)
$colorMapping = @{
    Status = @{
        'Stale'    = '#FECACA' # Light Red
        'Disabled' = '#F3F4F6' # Light Gray
        'Active'   = '#D1FAE5' # Light Green
    }
    IsPrivileged = @{
        'True'  = '#FDE047' # Yellow highlight for privileged
    }
}

# 3. Define Actions
$adActions = @(
    @{
        Name         = 'Disable Account'
        Scope        = 'Row'
        Icon         = '🚫'
        ReturnToGrid = $true
        Script       = {
            param($Data, $Context)
            if ($Data.Enabled) {
                Disable-ADAccount -Identity $Data.SamAccountName -ErrorAction Stop
                "Disabled account: $($Data.SamAccountName)"
            } else {
                "Account $($Data.SamAccountName) is already disabled."
            }
        }
    }
)

# 4. Launch Show-DataViewer
Show-DataViewer -Title "AD Privileged Account Watchtower" `
                -RefreshScript $adRefreshScript `
                -Actions $adActions `
                -ColorMapping $colorMapping `
                -Columns @('Status', 'IsPrivileged', 'SamAccountName', 'Name', 'Enabled', 'LastLogonDate', 'PasswordLastSet')
```
