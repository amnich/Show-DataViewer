# Dynamic Data Viewer (WPF)

A highly interactive, dynamic, and generic WPF-based user interface for visualizing, filtering, grouping, and analyzing any collection of PowerShell objects (`PSCustomObject`). 

Whether you are parsing event logs, monitoring active processes, or analyzing CSV data, this tool instantly spins up a feature-rich, modern dashboard without requiring you to write custom UI code.

## Key Features

- **Automatic Data Grid**: Automatically generates columns based on the properties of the objects you pass to it. Supports interactive sorting, reordering, and resizing. When no column list is supplied, the viewer prefers the object's built-in default display properties (similar to Format-Table) and only falls back to all discovered fields when needed.
- **Inline Editing**: Use the `-AllowEdit` switch to allow modifying data directly within the grid. Changes instantly synchronize with the underlying objects, dynamic filter options, and group-by counts.
- **Dynamic Filter Panel**: Automatically detects data types (e.g., `DateTime`, low-cardinality strings, high-cardinality values) and provisions appropriate filter controls (DatePickers, ComboBoxes, TextBoxes). Correctly handles and groups `null` or empty values under an `(Empty)` label.
- **Details Pane**: Displays the full details of the currently selected row in a scrollable view. Perfect for reading long string values (like stack traces or event log messages).
- **Group By Analysis**: Group your data by any column, calculate item counts, and display the Top N results dynamically.
- **Built-in Charts**: Generate Bar and Pie charts directly from your data properties without any external dependencies. Export charts directly to PNG.
- **Asynchronous Refresh**: Supports an asynchronous refresh scriptblock (`-RefreshScript`). Pull fresh data in the background using `Start-Job` while keeping the UI completely responsive.
- **Color Mapping**: Color-code rows based on specific property values (e.g., Red for "Error", Yellow for "Warning").
- **Modern Themes**: Fully implemented dynamic Light and Dark mode, complete with native Windows DWM dark title bars. Theme preferences and column configurations are automatically saved to your user profile (`%APPDATA%\DynamicDataViewer`).

## Prerequisites

- **PowerShell 5.1** or higher.
- **Windows OS** (relies on WPF / `PresentationFramework`).

## Basic Usage

The easiest way to use the viewer is to pipe an array of custom objects directly into the `Show-DataViewer` function.

```powershell
# 1. Dot-source the script to load the function
. .\Dynamic_DataViewer_WPF.ps1

# 2. Gather some data
$data = Get-Process | Select-Object Name, Id, WorkingSet, Handles, CPU

# 3. Launch the viewer
$data | Show-DataViewer -Title "Process Monitor"
```

## Advanced Usage

For more complex scenarios, you can provide an asynchronous refresh script, configure column visibility, and apply custom color mappings. Check examples below.

```powershell
# Define how to fetch new data
$refreshScript = { 
    Get-EventLog -LogName System -Newest 500 | 
    Select-Object EventID, EntryType, Source, TimeGenerated, Message 
}

# Define color rules
$colorMapping = @{
    EntryType = @{
        'Error'    = '#FECACA'  
        'Warning'  = '#FEF3C7'  
        'Critical' = '#FCA5A5'
    }
}

# Define initial columns
$columns = @('TimeGenerated', 'EntryType', 'Source', 'EventID', 'Message')

# Launch
Show-DataViewer -Data (& $refreshScript) `
                -Title "System Event Logs" `
                -RefreshScript $refreshScript `
                -ColorMapping $colorMapping `
                -Columns $columns `
                -GroupByTopN 15
```

## Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| **`Data`** | `[PSCustomObject[]]` | The array of objects to display. Accepts pipeline input. |
| **`RefreshScript`** | `[scriptblock]` | Optional scriptblock executed asynchronously when the "Refresh" button is clicked. It must return an array of objects. |
| **`Configuration`** | `[hashtable]` | Optional hashtable for passing additional internal configurations. |
| **`Columns`** | `[string[]]` | Array of property names defining the initial order and visibility of columns. If omitted, the viewer initially shows the source object's default display properties (for example, the columns PowerShell would show in Format-Table) when available; otherwise it falls back to all discovered properties. |
| **`ColorMapping`** | `[hashtable]` | A hashtable mapping specific cell string values to WPF brush colors (e.g., `@{ "Error" = "Red" }`). |
| **`Title`** | `[string]` | The title displayed in the window header. Default is "Data Viewer". |
| **`GroupByTopN`** | `[int]` | The default number of top values to display in the Group By analysis tab. Default is `10`. |
| **`Actions`** | `[hashtable[]]` | Optional array of action definitions. Each action is a hashtable with keys described below. |
| **`AllowEdit`** | `[switch]` | Enables inline editing directly within the DataGrid. Edited values update the underlying custom object and instantly reflect in filter controls and group-by counts. |

## Custom Actions

Custom Actions allow you to extend the viewer with your own operations that work on individual rows or the entire filtered dataset. Actions appear as buttons in the UI and their results are shown back to you.

### Action Hashtable Schema

Each action is defined as a hashtable with the following keys:

| Key | Type | Required | Description |
|---|---|---|---|
| `Name` | `string` | ✅ | Display label for the button (e.g. `"Kill Process"`, `"Export to CSV"`) |
| `Script` | `scriptblock` | ✅ | The code to execute. Receives two parameters: `$ActionData` (the selected row or filtered array) and `$ActionContext` (a hashtable with `SelectedRow`, `AllData`, `FilteredData`, `Window`) |
| `Scope` | `string` | ✅ | `"Row"` — button appears near Copy Row and is enabled only when a row is selected. `"Dataset"` — button appears in the header toolbar and operates on all filtered items. `"Both"` — button appears in both locations. |
| `Icon` | `string` | ❌ | Optional emoji/unicode prefix for the button (e.g. `"⚡"`, `"📋"`) |
| `ReturnToGrid` | `bool` | ❌ | If `$true`, the grid is refreshed after execution to reflect any property changes or additions made by the scriptblock. Default: `$false` |

### Example 

```powershell
    $refreshScript = {
        Get-Process | Select-Object Name, Id, CPU, Handles
    }

    $actions = @(
        @{
            Name = 'Kill Process'
            Scope = 'Row'
            ReturnToGrid = $true
            Script = {
                param($ActionData, $ActionContext)
                Stop-Process -Id $ActionData.Id -Force -ErrorAction SilentlyContinue
                'Stopped {0}' -f $ActionData.Name
            }
        },
        @{
            Name = 'Mark Reviewed'
            Scope = 'Row'
            ReturnToGrid = $true
            Script = {
                param($ActionData, $ActionContext)
                $ActionData | Add-Member -NotePropertyName Reviewed -NotePropertyValue $true -Force
                'Marked {0} as reviewed.' -f $ActionData.Name
            }
        }
    )

    Show-DataViewer -Data (& $refreshScript) `
        -RefreshScript $refreshScript `
        -Title 'Process Viewer' `
        -Actions $actions
```

### Where Action Buttons Appear

- **Row actions** (`Scope = "Row"`) appear next to the **Copy Row** / **Copy Details** buttons in the details pane area. They are disabled when no row is selected.
- **Dataset actions** (`Scope = "Dataset"`) appear in the header toolbar, next to the Export buttons.
- **Both** (`Scope = "Both"`) creates a button in both locations.

### Result Handling

- If the scriptblock returns a **string**, it is shown in a MessageBox (for Row/Dataset) or in the status bar (for ReturnToGrid actions).
- If the scriptblock returns **objects**, they are formatted and displayed in a MessageBox.
- If `ReturnToGrid` is `$true`, the grid is refreshed after execution. If the scriptblock added new properties (via `Add-Member`), the viewer automatically discovers them, adds new columns, generates dynamic filter controls, and makes them available for Pivot and Group By analysis.
- Errors are caught and displayed in an error dialog.

### Example 1

```powershell
    $categories = @('Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon')
    $levels = @('Info', 'Warning', 'Error', 'Critical')
    $users = @('admin', 'john.doe', 'jane.smith', 'bob.jones', 'alice.wang', 'dev.test')
    $servers = @('SRV01', 'SRV02', 'SRV03')

    $data = 1..200 | ForEach-Object {
        [PSCustomObject]@{
            ID       = $_
            Name     = "Item-$($_.ToString('D4'))"
            Category = $categories[$_ % $categories.Count]
            Level    = $levels[$_ % $levels.Count]
            User     = $users[$_ % $users.Count]
            Server   = $servers[$_ % $servers.Count]
            Created  = (Get-Date).AddDays( - ($_ * 0.5)).AddHours( - (Get-Random -Max 24))
            Value    = [math]::Round((Get-Random -Minimum 1 -Maximum 10000) / 100, 2)
            Message  = "This is a sample message for item $_ with some searchable text content."
            IsActive = ($_ % 3 -ne 0)
        }
    }
    $colorMapping = @{
        Level = @{
            Error = '#FECACA'
            Warning = '#FEF3C7'
        }
    }

    Show-DataViewer -Data $data -ColorMapping $colorMapping -Title 'Colored Events'
    
    #or 
    $colorMapping = @{
         Level = @{
             Error = [System.ConsoleColor]::DarkRed
             Warning = 'Yellow'
         }
     }
    Show-DataViewer -Data $data -ColorMapping $colorMapping -Title 'Colored Events'
```

### Example 2

```powershell
    $refreshScript = {
        Get-Process | Select-Object Name, Id, CPU, Handles
    }

    $actions = @(
        @{
            Name = 'Kill Process'
            Scope = 'Row'
            ReturnToGrid = $true
            Script = {
                param($ActionData, $ActionContext)
                Stop-Process -Id $ActionData.Id -Force -ErrorAction SilentlyContinue
                'Stopped {0}' -f $ActionData.Name
            }
        },
        @{
            Name = 'Mark Reviewed'
            Scope = 'Row'
            ReturnToGrid = $true
            Script = {
                param($ActionData, $ActionContext)
                $ActionData | Add-Member -NotePropertyName Reviewed -NotePropertyValue $true -Force
                'Marked {0} as reviewed.' -f $ActionData.Name
            }
        }
    )

    Show-DataViewer -Data (& $refreshScript) `
        -RefreshScript $refreshScript `
        -Title 'Process Viewer' `
        -Actions $actions
```

### EXAMPLE 3

```powershell
    $config = @{
        MaxEvents = 200
        Endpoint  = 'JEA01'
    }

    $refreshScript = {
        $resolvedMaxEvents = if ([string]::IsNullOrWhiteSpace([string]$MaxEvents)) { 200 }
                             elseif ([int]$MaxEvents -le 0) { 200 }
                             else { [int]$MaxEvents }

        Get-EventLog -LogName System -Newest $resolvedMaxEvents |
            Select-Object TimeGenerated, EntryType, Source, EventID, Message
    }

    Show-DataViewer -Data (& $refreshScript) `
        -RefreshScript $refreshScript `
        -Configuration $config `
        -Title 'System Event Log'
```

### EXAMPLE 4

```powershell
    $categories = @('Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon')
    $levels = @('Info', 'Warning', 'Error', 'Critical')
    $users = @('admin', 'john.doe', 'jane.smith', 'bob.jones', 'alice.wang', 'dev.test')
    $servers = @('SRV01', 'SRV02', 'SRV03')

    $data = 1..200 | ForEach-Object {
        [PSCustomObject]@{
            ID       = $_
            Name     = "Item-$($_.ToString('D4'))"
            Category = $categories[$_ % $categories.Count]
            Level    = $levels[$_ % $levels.Count]
            User     = $users[$_ % $users.Count]
            Server   = $servers[$_ % $servers.Count]
            Created  = (Get-Date).AddDays( - ($_ * 0.5)).AddHours( - (Get-Random -Max 24))
            Value    = [math]::Round((Get-Random -Minimum 1 -Maximum 10000) / 100, 2)
            Message  = "This is a sample message for item $_ with some searchable text content."
            IsActive = ($_ % 3 -ne 0)
        }
    }
    $actions = @(
        @{
            Name  = 'Show Details'
            Scope = 'Row'
            Script = {
                param($ActionData, $ActionContext)
                'Selected: ' + $ActionData.Name
            }
        }
    )

    Show-DataViewer -Data $data `
        -Title 'Interactive Viewer' `
        -Columns @('Name','Category','Level','Value') `
        -Actions $actions `
        -AllowEdit
```


## UI Guide

### 1. Data Grid Tab
The primary view of your data. 
- **Inline Editing**: If started with `-AllowEdit`, simply double-click any cell to edit its value.
- **Column Chooser**: Click the **Columns** button in the top right to open a configuration dialog where you can toggle column visibility and order.
- **Filtering**: Click **Show Filters** to open the dynamic filter pane. You can filter multiple columns simultaneously. Missing or null data can be filtered using the `(Empty)` option.
- **Details**: Select any row to populate the bottom Details pane. Use **Copy Row** or **Copy Details** to send data to the clipboard.
- **Custom Actions**: If actions were provided, Row-scoped action buttons appear next to the Copy buttons. Dataset-scoped action buttons appear in the header toolbar.

### 2. Group By Tab
Use this tab to aggregate your dataset.
- Select a field from the **GROUP BY** dropdown.
- Adjust the **TOP N VALUES** limit to truncate the list.
- Click **Analyze** to generate a frequency table.

### 3. Charts Tab
Visualize the distribution of your data.
- **FIELD**: The property you want to chart.
- **CHART TYPE**: Choose between **Bar** or **Pie**.
- **Group remaining as 'Other'**: Check this to collapse long-tail data (values beyond the Top N limit) into a single "Other" slice/bar.
- **Export**: Click **Export to PNG** to save the current chart directly to your hard drive.

### 4. Theming
Toggle the **☀️ / 🌙** button in the top-right corner to switch between Light and Dark modes. The viewer automatically remembers your preference across sessions by saving a configuration file in `$env:APPDATA\DynamicDataViewer\settings.json`.
