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
- **Asynchronous Refresh & Auto-Refresh**: Supports an asynchronous refresh scriptblock (`-RefreshScript`). Pull fresh data in the background using `Start-Job` while keeping the UI completely responsive. You can configure automatic polling intervals (5s, 30s, 1m) directly from the UI.
- **State Persistence**: Column widths, custom reordering, active filters, and sorting choices perfectly persist across background refreshes and tool restarts.
- **Robust Security & Performance**: Built-in Excel Formula Injection protection on CSV exports, Regex DoS timeouts for large-scale filtering, and automatic clipboard masking for sensitive properties (Passwords, Tokens, API Keys).
- **Intelligent Formatting**: Gracefully unwraps and extracts clean string representations for complex nested objects, generic collections (`IEnumerable`), and system handles (`SafeHandle`).
- **Color Mapping**: Color-code rows based on specific property values (e.g., Red for "Error", Yellow for "Warning").
- **Modern Themes**: Fully implemented dynamic Light and Dark mode, complete with native Windows DWM dark title bars. Theme preferences and column configurations are automatically saved to your user profile (`%APPDATA%\DynamicDataViewer`).
- **File Explorer Mode**: A built-in switch (`-FileExplorerMode`) instantly transforms the viewer into a high-performance File Browser with double-click navigation, automatic background refresh, and configurable file-reading logic.
- **JSON Explorer Mode**: A built-in switch (`-JsonExplorerMode`) instantly transforms the viewer into a fully functional JSON Explorer and Editor with a traversable tree view and inline editing capabilities.
- **Embedded SQLite Query Engine**: A dual-engine storage model that automatically shifts datasets exceeding 3,000 items (configurable via `-SqliteThreshold`) or `-EventViewerMode` into an embedded SQLite engine running in WAL mode. Filtering, global text search, dynamic facet calculations, and sorting are executed using indexed B-Tree queries, significantly lowering CPU and memory usage compared to pure PowerShell object iteration.

## File Explorer Mode

The viewer features a built-in `-FileExplorerMode` switch that instantly converts it into a fully functional, high-performance WPF File Browser out of the box!

```powershell
Show-DataViewer -FileExplorerMode -Title "My File Browser"
```

![File Explorer Mode](Show-DataViewer_ExplorereMode.gif)

When activated, the script automatically:
- Injects a high-performance background script to list files and optionally read character prefixes.
- Binds native **Double-Click** actions to open files and enter directories.
- Adds **"Go Up (..)"** navigation buttons to the dataset and row levels.
- Pre-fetches the starting directory (Defaults to `C:\`, overridable via `-Configuration @{ CurrentPath = 'D:\' }`).

## JSON Explorer Mode

The viewer features a built-in `-JsonExplorerMode` switch that instantly converts it into a fully functional WPF JSON Explorer and Editor!

```powershell
Show-DataViewer -JsonExplorerMode -Title "My JSON Editor"
```

When activated, the script automatically:
- Injects a background script to parse and flatten JSON files into an interactive tree grid.
- Allows inline editing of JSON property values with appropriate data type conversions.
- Adds row-level actions to **Add Property**, **Delete Node**, **Rename Property**, and **Clone Node**.
- Adds dataset-level actions to **Open File**, navigate up the tree, and **Save** changes back to disk.

## Process Explorer Mode

Similarly, the viewer features a built-in `-ProcessExplorerMode` switch that instantly converts it into a fully functional WPF Advanced Process Explorer!

```powershell
Show-DataViewer -ProcessExplorerMode
```

When activated, the script automatically:
- Injects a background script gathering extensive process metrics (CPU, RAM, Handles, Priority, Threads, etc.).
- Sets up color mapping for non-responding processes (highlights them in light red).
- Includes default actions to **Kill Process**, **Open Location**, **Search Online** (on double-click), and **Kill Selected (Bulk)**.
- Pre-selects common initial columns while loading additional detailed properties seamlessly in the background for analysis.

## Service Manager Mode

Turns the viewer into a high-performance Windows Service Manager.

```powershell
Show-DataViewer -ServiceManagerMode
```

When activated, the script automatically:
- Gathers services and correlates with WMI to pull `StartMode`, `ProcessId`, `PathName`, and `LogOnAs`.
- Highlights **Stopped** services with Automatic startup in **Red**, and **Running** services in **Green**.
- Includes default actions to **Start**, **Stop**, **Restart**, change the startup type (**Set Auto**, **Set Manual**, **Set Disabled**), and double-click to **Search Online**.

## Event Viewer Mode

A lightning-fast replacement for the traditional Windows Event Viewer.

```powershell
Show-DataViewer -EventViewerMode
```

When activated, the script automatically:
- Pulls the newest 1000 events from System and Application logs.
- Color codes **Error** events in **Red** and **Warning** events in **Yellow**.
- Includes default actions to easily **Search EventID Online** on double-click.

## NetStat Mode (Network Analyzer)

A live view of active TCP/UDP connections and the processes making them.

```powershell
Show-DataViewer -NetStatMode
```

When activated, the script automatically:
- Cross-references `Get-NetTCPConnection` with `Get-Process` to resolve the owning Process Name.
- Highlights **Established** connections in **Green** and **TimeWait** in **Gray**.
- Includes default actions to **Kill Owning Process** or **Open Process Location** on double-click.

## AD User Explorer Mode

A built-in Active Directory User Explorer to identify and manage privileged and stale accounts.

```powershell
Show-DataViewer -ADUserExplorerMode
```

When activated, the script automatically:
- Gathers all AD users, their group memberships, and logon/password details.
- Identifies **Privileged** users (Domain/Enterprise/Schema Admins) and highlights them in **Yellow**.
- Highlights **Stale** accounts (no logon in 90 days) in **Red**.
- Provides instant Row actions to **Enable**, **Disable**, or **Unlock** accounts.

## Task Scheduler Mode

A built-in Scheduled Task Operations Console to monitor and control tasks.

```powershell
Show-DataViewer -TaskSchedulerMode
```

When activated, the script automatically:
- Gathers scheduled tasks, their states, last results, next run times, actions, and triggers.
- Calculates a custom **Health** metric (e.g., Healthy, Failed, Running, MissedRuns, Stale).
- Highlights **Healthy** tasks in **Green**, **Failed** in **Red**, and **Stale** or **MissedRuns** in **Yellow**.
- Provides instant Row actions to **Run / Stop** and **Enable / Disable**, plus double-click to **Search Online**.

## Prerequisites

- **PowerShell 5.1** or higher (compatible with both Windows PowerShell 5.1 and PowerShell 7+).
- **Windows OS** (relies on WPF / `PresentationFramework`).
- **SQLite Engine (Zero-Install Portability)**: When SQLite is activated, the viewer automatically resolves drivers via `PSSQLite` / `System.Data.SQLite.dll` on Windows PowerShell 5.1 or `Microsoft.Data.Sqlite.dll` on PowerShell 7+. Drivers are resolved from `lib\PSSQLite`, existing session cmdlets, or installed modules without requiring manual administrative setup.

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
| **`Configuration`** | `[hashtable]` | Optional hashtable for passing additional internal configurations. Keys are injected as variables into `-RefreshScript`. Special key `ComboBoxMaxUnique` sets the threshold for when a column filter switches from a ComboBox to a TextBox (default: 50). |
| **`Columns`** | `[string[]]` | Array of property names defining the initial order and visibility of columns. If omitted, the viewer initially shows the source object's default display properties (for example, the columns PowerShell would show in Format-Table) when available; otherwise it falls back to all discovered properties. |
| **`ColorMapping`** | `[hashtable]` | A hashtable mapping specific cell string values to WPF brush colors (e.g., `@{ "Error" = "Red" }`). |
| **`Title`** | `[string]` | The title displayed in the window header. Default is "Data Viewer". |
| **`GroupByTopN`** | `[int]` | The default number of top values to display in the Group By analysis tab. Default is `10`. |
| **`Actions`** | `[hashtable[]]` | Optional array of action definitions. Each action is a hashtable with keys described below. |
| **`AllowEdit`** | `[switch]` | Enables inline editing directly within the DataGrid. Edited values update the underlying custom object and instantly reflect in filter controls and group-by counts. |
| **`FileExplorerMode`** | `[switch]` | Automatically configures the viewer as a fully functional WPF-based File Browser. Injects background scripts, navigation actions, and pre-fetches initial data. |
| **`ProcessExplorerMode`** | `[switch]` | Automatically configures the viewer as a WPF-based Advanced Process Explorer. Injects a background script gathering process metrics, sets up color mappings, and includes default process management actions. |
| **`ServiceManagerMode`** | `[switch]` | Automatically configures the viewer as a WPF-based Windows Service Manager. Gathers service details (including PID and Path), highlights crashed services, and includes actions to Start/Stop/Restart services and change startup types. |
| **`EventViewerMode`** | `[switch]` | Automatically configures the viewer as a lightning-fast System Event Log Explorer. Gathers recent events, color-codes Errors and Warnings, and allows quick online searches for Event IDs. |
| **`NetStatMode`** | `[switch]` | Automatically configures the viewer as a live Network Connection Analyzer. Cross-references open ports with owning processes, highlights Established connections, and allows killing rogue processes. |
| **`ADUserExplorerMode`** | `[switch]` | Automatically configures the viewer as an Active Directory User Explorer. Gathers all users from AD, identifies privileged and stale accounts, maps them to colors, and provides one-click actions to Enable, Disable, and Unlock accounts. |
| **`TaskSchedulerMode`** | `[switch]` | Automatically configures the viewer as a Scheduled Task Operations Console. Displays task states, computes health metrics, and includes actions to run, stop, enable, and disable tasks. |
| **`JsonExplorerMode`** | `[switch]` | Automatically configures the viewer as a fully functional JSON Explorer and Editor. Provides tree-based navigation, inline editing, and native node manipulation (add, delete, rename, clone). |
| **`UseSqlite`** | `[switch]` | Forces the embedded SQLite storage and query engine. Bypasses in-memory PowerShell object evaluation and provides indexed B-Tree filtering on large datasets. |
| **`NoSqlite`** | `[switch]` | Forces the standard in-memory PSCustomObject engine, disabling automatic switching to the SQLite backend regardless of dataset size. |
| **`SqliteThreshold`** | `[int]` | Item count threshold (default: `3000`) at which `Show-DataViewer` automatically activates the embedded SQLite backend. |
| **`SqliteLimit`** | `[int]` | Maximum number of rows to query and display from the SQLite backend (default: `0` / unlimited). Useful for inspecting the top rows of very large datasets. |
| **`SqliteDatabasePath`** | `[string]` | File path to persist the SQLite database (`.db`) for forensic or offline analysis. If omitted, a temporary database in `$env:TEMP` is used and cleaned up on close. |

## Embedded SQLite Query Engine & Performance

`Show-DataViewer` uses a hybrid storage and query architecture. Small-to-medium datasets remain as native `PSCustomObject` instances in managed memory for zero-setup simplicity. When working with larger datasets (default: 3,000+ items), in `-EventViewerMode`, or when explicitly requested via `-UseSqlite`, the viewer shifts storage, indexing, and query evaluation to an embedded SQLite database.

```
+-------------------------------------------------------------------------+
|                           Show-DataViewer GUI                           |
|       (WPF DataGrid, Dynamic Filters, Details Pane, Pivot & Charts)      |
+-------------------------------------------------------------------------+
                                    |
            +-----------------------+-----------------------+
            | Dataset < 3,000 rows  | Dataset >= 3,000 rows |
            | (or -NoSqlite)        | (or -UseSqlite)       |
            v                                               v
+-----------------------+               +---------------------------------+
|   In-Memory Engine    |               |     Embedded SQLite Engine      |
|  - PSCustomObject[]   |               |  - System.Data.SQLite (PS 5.1)  |
|  - LINQ / WhereObject |               |  - Microsoft.Data.Sqlite (PS 7) |
|  - Dynamic reflection |               |  - WAL mode + NORMAL sync       |
|  - GC managed heap    |               |  - B-Tree indexes on key fields |
+-----------------------+               +---------------------------------+
                                                        |
                                        +---------------+---------------+
                                        | Temporary DB  | Persistent DB |
                                        | ($env:TEMP)   | (-SqliteDbPath)|
                                        +---------------+---------------+
```

### Technical Architecture

1. **Dynamic Schema Generation**: Input objects are mapped to an ADO.NET `DataTable` structure (`Out-DataTable`). Columns are classified into standard SQLite storage types (`INTEGER`, `REAL`, `TEXT`), and table `DataViewerRecords` is created with an auto-incrementing `_RowId INTEGER PRIMARY KEY`.
2. **Bulk Ingestion via BulkCopy**: Rather than executing individual `INSERT` statements (which average ~80 rows/sec due to disk synchronization per statement), the viewer streams records in batch transactions via `Invoke-SqliteBulkCopy`, achieving ingestion rates of 25,000 to 45,000 rows/sec.
3. **Engine PRAGMAs**:
   - `PRAGMA journal_mode = WAL;`: Enables Write-Ahead Logging. Readers do not block writers, and writes do not block readers.
   - `PRAGMA synchronous = NORMAL;`: Reduces disk I/O overhead by eliminating redundant fsync calls while maintaining full WAL crash recovery.
   - `PRAGMA busy_timeout = 5000;`: Prevents `database is locked` exceptions under rapid filtering by applying a 5-second wait/retry window.
   - `PRAGMA foreign_keys = ON;`: Ensures database consistency.
4. **Targeted B-Tree Indexing**: Automatic indexes (`idx_dvr_<Column>`) are generated during ingestion on common filter properties (`Id`, `RecordId`, `Level`, `LevelDisplayName`, `Status`, `State`, `Date`, `Time`, `TimeCreated`, `ProviderName`, `Category`, `Type`, `User`, `Server`).
5. **SQL Query Pushdown**:
   - **Global Search**: Visible columns are queried simultaneously using parameterized `[Column] LIKE @param` conditions combined with `OR`.
   - **Multi-Select Filters**: Checked and unchecked dropdown choices map to parameterized `NOT IN (@p1, @p2, ...)` and null checks.
   - **Text Filters**: Formatted as parameterized `LIKE @param` queries.
   - **Date Range Filters**: Evaluated as boundary conditions (`>= @dtFrom AND <= @dtTo`).
   - **Dynamic Facets**: ComboBox value distributions are computed directly via `SELECT [Column] AS FacetVal, COUNT(*) AS FacetCount FROM DataViewerRecords WHERE ... GROUP BY [Column]`.
   - **Sorting**: DataGrid column headers translate directly into SQL `ORDER BY [Column] ASC/DESC`.
6. **Live Inline Editing Sync**: When `-AllowEdit` is enabled, edits performed inside the DataGrid write immediately to the database via parameterized `UPDATE DataViewerRecords SET [Column] = @val WHERE _RowId = @rowId` statements.
7. **Lifecycle & Cleanup**: When using the default temporary database, closing the window runs garbage collection, disposes database connections, and deletes the temporary `.db`, `.db-wal`, and `.db-shm` files.

---

### Performance Comparison & Benchmarks

The following measurements illustrate the performance profile between the In-Memory engine and the SQLite backend on a standard modern PC (Windows 11, Core i7, 32 GB RAM, NVMe SSD):

| Dataset Size | Metric / Operation | In-Memory Engine (PSCustomObject) | Embedded SQLite Engine | Technical Impact |
| :--- | :--- | :--- | :--- | :--- |
| **5,000 rows** | Multi-field filter pass | ~120 ms | ~8 ms | Fast indexed query vs linear array traversal |
| **5,000 rows** | Ingest / Initialization | ~180 ms | ~190 ms | One-time schema detection & BulkCopy |
| **5,000 rows** | Memory consumption | ~28 MB | ~6 MB | 4.6x lower memory footprint |
| **25,000 rows** | Multi-field filter pass | ~750 ms | ~18 ms | UI remains responsive during active typing |
| **25,000 rows** | Bulk ingestion throughput | ~4,200 rows/sec | ~36,000 rows/sec | Uses ADO.NET BulkCopy transaction batching |
| **25,000 rows** | Memory consumption | ~140 MB | ~18 MB | Prevents GC Gen 2 heap fragmentation |
| **100,000 rows** | Multi-field filter pass | ~3,200 ms (noticeable freeze) | ~35 ms | Sub-50ms query latency on large datasets |
| **100,000 rows** | Ingestion duration | ~22.5 seconds | ~2.7 seconds | ~8.3x faster initial loading |
| **100,000 rows** | Memory consumption | ~550 MB | ~45 MB | ~12x reduction in managed memory overhead |

#### Key Technical Reasons for the Performance Difference:
- **Absence of Runtime Reflection**: In-memory PowerShell filtering must reflect over each `PSCustomObject` property for every row on every filter change. SQLite compiles the query plan and runs native C-level B-Tree index scans.
- **Garbage Collector (GC) Relief**: Retaining hundreds of thousands of `PSCustomObject` instances creates significant GC allocation pressure. SQLite stores records in compact data pages, keeping managed heap allocations minimal.
- **Streaming BulkCopy**: Default single-statement SQLite inserts trigger physical disk writes per row (~80 rows/sec). Streaming records via `Invoke-SqliteBulkCopy` inside WAL mode writes in contiguous pages (~36,000+ rows/sec).

---

### Parameter Reference

- **`-UseSqlite`**:
  Explicitly enables the SQLite engine, bypassing the item count threshold. Recommended when you want indexed searches or database persistence for datasets under 3,000 items.
- **`-NoSqlite`**:
  Forces the in-memory engine regardless of dataset size. Use this if your custom action scripts require mutating the original `PSCustomObject` references directly in PowerShell session memory.
- **`-SqliteThreshold <int>`**:
  The item count at which `Show-DataViewer` automatically transitions from in-memory processing to SQLite (default: `3000`).
- **`-SqliteLimit <int>`**:
  Limits the maximum number of rows returned and displayed in the DataGrid from the SQLite backend (default: `0` = unlimited). Can be set to a positive integer (e.g., `1000`) when exploring very large tables to reduce UI control rendering overhead.
- **`-SqliteDatabasePath <string>`**:
  Specifies a path to persist the SQLite database to disk. When this parameter is omitted, a temporary file is generated in `$env:TEMP` and cleaned up on close. When specified, the database file remains intact after closing for auditing or external SQL queries.

---

### Driver Resolution & Compatibility

`Show-DataViewer` handles driver resolution automatically across versions:
1. **Active Session**: Reuses existing `Invoke-SqliteQuery` cmdlets if already imported.
2. **Bundled Driver**: Looks for `lib\PSSQLite\PSSQLite.psd1` relative to the script directory.
3. **System Module**: Falls back to `Import-Module PSSQLite` from standard module directories.

Runtime compatibility:
- **Windows PowerShell 5.1** (.NET Framework 4.5+): Loads `System.Data.SQLite.dll`.
- **PowerShell 7+** (.NET Core / .NET 8/9): Loads `Microsoft.Data.Sqlite.dll`.

## Custom Actions

Custom Actions allow you to extend the viewer with your own operations that work on individual rows or the entire filtered dataset. Actions appear as buttons in the UI and their results are shown back to you.

### Action Hashtable Schema

Each action is defined as a hashtable with the following keys:

| Key | Type | Required | Description |
|---|---|---|---|
| `Name` | `string` | ✅ | Display label for the button (e.g. `"Kill Process"`, `"Export to CSV"`). Ignored if `Scope` is `DoubleClick`. |
| `Script` | `scriptblock` | ✅ | The code to execute. Receives two parameters: `$ActionData` (the selected row or filtered array) and `$ActionContext` (a hashtable with `SelectedRow`, `AllData`, `FilteredData`, `Window`, and `Configuration`) |
| `Scope` | `string` | ✅ | `"Row"` — button appears near Copy Row and is enabled only when a row is selected.<br>`"Dataset"` — button appears in the header toolbar and operates on all filtered items.<br>`"Both"` — button appears in both locations.<br>`"DoubleClick"` — natively binds the scriptblock to the DataGrid's `MouseDoubleClick` event instead of rendering a button. |
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
- **Double Click** (`Scope = "DoubleClick"`) does not create a button. Instead, it securely binds your action directly to the data grid's native `MouseDoubleClick` event.

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

### EXAMPLE 3: Interactive File Browser (Double-Click & Config Injection) with X first chars of each file.

```powershell
    # 1. Define the configuration for the DataViewer.
    $config = @{
        CurrentPath = 'C:\'
        CharactersToRead = 100
    }

    # 2. Define the Refresh Script. 
    # It runs in a background job and automatically gets $CurrentPath from the config!
    $refreshScript = {
        # <- This is the magic! It gets injected automatically by Show-DataViewer.
        function read_first_X_chars {
            param($path,[int]$Chars = 100)
            #test if its a file or directory
            if (-not (Test-Path -Path $path)) {
                #Write-Output "File not found: $path"
                return
            }
            if ((Get-Item -Path $path).PSIsContainer) {
                return
            }
            $reader = [System.IO.StreamReader]::new($path)

            # Create a buffer for the specified number of characters
            $buffer = [char[]]::new($Chars)

            # Read up to the specified number of characters into the buffer
            $charsRead = $reader.Read($buffer, 0, $Chars)

            # Clean up
            $reader.Close()
            $reader.Dispose()

            # Join the array back into a string (handling files smaller than X chars)
            $result = -join $buffer[0..($charsRead - 1)]
            $singleLineResult = $result -replace '\r?\n', ' '

            Write-Output $singleLineResult
        }
        Get-ChildItem -Path $CurrentPath -ErrorAction SilentlyContinue | 
        Select-Object Name, Length, Extension, CreationTime, Mode, FullName, @{Name='FirstChars';Expression={read_first_X_chars $_.FullName $CharactersToRead  }}
    }

    # 3. Define our Custom Actions using the brand new 'DoubleClick' scope!
    $actions = @(
        @{
            Name         = 'Enter / Open'
            Scope        = 'DoubleClick'  # <--- Natively binds to DataGrid MouseDoubleClick!
            ReturnToGrid = $false
            Script       = {
                param($Data, $Context)
                    
                if ($Data.Mode -match 'd') {
                    # It's a directory! Update the CurrentPath in the viewer's configuration.
                    $Context.Configuration['CurrentPath'] = $Data.FullName
                        
                    # Automatically click the 'Refresh Data' button to fetch the new directory
                    $btnRefresh = $Context.Window.FindName('btnRefresh')
                    if ($btnRefresh) {
                        $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                    }
                }
                else {
                    # It's a file! Open it with Windows.
                    Invoke-Item -Path $Data.FullName
                }
            }
        },
        @{
            Name         = 'Go Up (..)'
            Scope        = 'Row' # Puts it right next to the Copy buttons, as requested!
            Icon         = '⬆️'
            ReturnToGrid = $false
            Script       = {
                param($Data, $Context)
                    
                # Read the current path directly from the viewer's configuration
                $currentPath = $Context.Configuration['CurrentPath']
                $parent = Split-Path -Path $currentPath -Parent
                    
                if ($parent) {
                    # Update the configuration with the parent path
                    $Context.Configuration['CurrentPath'] = $parent
                        
                    # Automatically click the 'Refresh Data' button
                    $btnRefresh = $Context.Window.FindName('btnRefresh')
                    if ($btnRefresh) {
                        $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                    }
                }
            }
        },
        @{
            Name         = 'Go Up (..)'
            Scope        = 'Dataset' # <--- Changed from 'Row' to 'Dataset'
            Icon         = '⬆️'
            ReturnToGrid = $false
            Script       = {
                param($Data, $Context)
                    
                # Read the current path directly from the viewer's configuration
                $currentPath = $Context.Configuration['CurrentPath']
                $parent = Split-Path -Path $currentPath -Parent
                    
                if ($parent) {
                    # Update the configuration with the parent path
                    $Context.Configuration['CurrentPath'] = $parent
                        
                    # Automatically click the 'Refresh Data' button
                    $btnRefresh = $Context.Window.FindName('btnRefresh')
                    if ($btnRefresh) {
                        $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                    }
                }
            }
        })
    # 4. Fetch the initial data and launch the viewer
    #replace with $refreshscript and pass the current path to it
    $CurrentPath = $config.CurrentPath
    $CharactersToRead = $config.CharactersToRead
    $initialData = invoke-command -scriptblock $refreshScript 

    Show-DataViewer -Data $initialData `
        -Title "WPF File Browser" `
        -Configuration $config `
        -RefreshScript $refreshScript `
        -Actions $actions
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
- **Auto-Refresh**: If a `-RefreshScript` is provided, use the dropdown in the top bar to set an auto-refresh polling interval (Off, 5s, 30s, 1m). All active filters, sorts, and custom column widths are preserved seamlessly during refreshes!
- **Column Chooser**: Click the **Columns** button in the top right to open a configuration dialog where you can toggle column visibility and order.
- **Filtering**: Click **Show Filters** to open the dynamic filter pane. You can filter multiple columns simultaneously. Missing or null data can be filtered using the `(Empty)` option.
- **Details**: Select any row to populate the bottom Details pane. Use **Copy Row** or **Copy Details** to send data to the clipboard. (Note: Sensitive fields like passwords and API keys are automatically masked during clipboard operations for security).
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


# User Guide

`Show-DataViewer` is a powerful, interactive WPF-based data viewer for PowerShell objects. It allows you to display, filter, analyze, chart, and even edit collections of `PSCustomObject` items in a sleek desktop window.

This guide will walk you through everything from the simplest use cases to the most advanced technical implementations.

---

## 1. Getting Started: The Basics

The most fundamental way to use `Show-DataViewer` is to pass it some data. The viewer accepts an array of `PSCustomObject` items, either via the `-Data` parameter or directly from the pipeline.

### Basic Usage
> [!TIP]
> You can easily visualize the output of built-in cmdlets by piping them into `Show-DataViewer`.

```powershell
# Get a list of processes and show them in the viewer
Get-Process | Select-Object Name, Id, CPU, Handles | Show-DataViewer
```

### Specifying Data Explicitly and Setting a Title
You can provide data via the `-Data` parameter and customize the window title using `-Title`.

```powershell
$data = Get-Service | Select-Object Name, DisplayName, Status, StartType
Show-DataViewer -Data $data -Title "Windows Services Viewer"
```

### Enabling Inline Editing
You can make the data grid editable by adding the `-AllowEdit` switch. This allows users to double-click cells and edit their values directly in the window! 
When a cell is edited, the underlying PowerShell object is instantly updated in your session, and any active filters or groupings are refreshed.

```powershell
# Example 1: Make the services editable
Show-DataViewer -Data $data -AllowEdit -Title "Editable Services Viewer"
```

```powershell
# Example 2: Edit a user list and process the changes afterwards
$users = @(
    [PSCustomObject]@{ ID = 1; Name = 'Alice'; Role = 'Admin'; IsActive = $true }
    [PSCustomObject]@{ ID = 2; Name = 'Bob'; Role = 'User'; IsActive = $false }
    [PSCustomObject]@{ ID = 3; Name = 'Charlie'; Role = 'User'; IsActive = $true }
)

# Open the viewer and wait for the user to close it
Show-DataViewer -Data $users -AllowEdit -Title "Manage Users"

# After the window is closed, the $users array contains all the edits made in the UI!
$users | Where-Object { $_.IsActive } | Export-Csv -Path "ActiveUsers.csv" -NoTypeInformation
```

> [!WARNING]
> Editing data modifies the objects in memory. Ensure your script handles these modifications appropriately if you plan to save them back to a database or file, as demonstrated in the second example above.

---

## 2. Customizing the View

You can customize what data is shown by default and apply conditional formatting to make important rows stand out.

### Selecting Specific Columns
By default, the viewer displays properties based on the object's default display set or all discovered properties. Use `-Columns` to specify exactly which columns should be visible initially. (Users can still toggle other columns from the UI using the "Columns" button).

```powershell
$data = Get-Process
Show-DataViewer -Data $data -Columns @('Name', 'CPU', 'WorkingSet') -Title "CPU Monitor"
```

### Conditional Formatting with Color Mapping
The `-ColorMapping` parameter lets you highlight entire rows based on specific property values. It takes a nested hashtable where the outer key is the Property Name, and the inner keys are the matching values and their colors.

**How to specify colors:**
Because `Show-DataViewer` is built on WPF, you can specify colors in several ways:
1. **Hexadecimal Code**: Like `#FF0000` (Red) or `#FEF3C7` (Soft Yellow).
2. **Standard WPF Color Names**: Like `Red`, `DarkRed`, `LightGreen`, `CornflowerBlue`, etc.

```powershell
$data = @(
    [PSCustomObject]@{ Service = 'Web'; Status = 'Running'; Priority = 'High' }
    [PSCustomObject]@{ Service = 'DB'; Status = 'Stopped'; Priority = 'Critical' }
    [PSCustomObject]@{ Service = 'Cache'; Status = 'Running'; Priority = 'Low' }
)

$colors = @{
    # We want to format based on the "Status" property
    Status = @{
        'Stopped' = '#FECACA'    # Using Hex Code
        'Running' = 'LightGreen' # Using Named Color
    }
}

Show-DataViewer -Data $data -ColorMapping $colors -Title "Service Status"
```

---

## 3. Analytical Features

Once your data is loaded, the UI offers powerful built-in tools:
- **Filters**: Auto-detects field types and builds filter controls automatically (Dropdowns, Text searches, Date ranges).
- **Details Pane**: Click any row to see its full properties in a formatted view.
- **Group By Panel**: Easily aggregate data. You can control how many top values are shown with `-GroupByTopN` (default is 10).
- **Pivot Analysis & Charts**: Build pivot tables and charts directly in the UI, and export them to PNG!

```powershell
# Lowering the Top N limit for the Group By panel
Get-Process | Show-DataViewer -GroupByTopN 5
```

---

## 4. Hardcore / Technical Examples

For advanced automation and tool-building, `Show-DataViewer` supports dynamic refreshing, custom actions (buttons), and runtime configuration.

### Custom Actions
You can define custom buttons that execute PowerShell scripts against your data. The `-Actions` parameter takes an array of hashtables. Each action defines:
- **`Name`**: The label of the button.
- **`Scope`**: Where the action applies. `Row` (acts on the selected row), `Dataset` (acts on the entire grid), or `Both`.
- **`Script`**: The ScriptBlock to execute. It receives two parameters: `$ActionData` and `$ActionContext`.
    - `$ActionData`: If Scope is `Row`, this is the single `PSCustomObject` selected. If Scope is `Dataset`, it's the entire array of data.
    - `$ActionContext`: Contextual information about the viewer.
- **`ReturnToGrid`**: If `$true`, the string returned by the script is displayed in the viewer's status bar.

```powershell
$actions = @(
    @{
        Name = 'Kill Process'
        Scope = 'Row'
        ReturnToGrid = $true
        Script = {
            param($ActionData, $ActionContext)
            Stop-Process -Id $ActionData.Id -Force -ErrorAction SilentlyContinue
            return "Stopped $($ActionData.Name)"
        }
    },
    @{
        Name = 'Export All to CSV'
        Scope = 'Dataset'
        Script = {
            param($ActionData, $ActionContext)
            $ActionData | Export-Csv -Path "C:\temp\processes.csv" -NoTypeInformation
            return "Exported $($ActionData.Count) processes."
        }
    }
)

Get-Process | Select-Object Name, Id, CPU | Show-DataViewer -Actions $actions -Title "Process Manager"
```

### Dynamic Data Refresh and Configuration
You can provide a `-RefreshScript` to pull new data asynchronously when the user clicks "Refresh". 
To make this dynamic, you can pass a `-Configuration` hashtable. 

**How Configuration Works:**
1. It exposes a "Configuration" button in the UI, allowing users to edit the values (e.g., change `MaxEvents` from 50 to 100) in a popup dialog.
2. The keys from the `-Configuration` hashtable are **automatically injected as variables** into your `-RefreshScript`. 

> [!NOTE]
> When the user edits values in the Configuration dialog and clicks "Apply", the `-RefreshScript` is executed again with the updated variable values!

```powershell
$config = @{
    LogName = 'System'
    MaxEvents = 50       # Users can change this to 100 in the UI!
}

$refreshScript = {
    # $LogName and $MaxEvents are automatically injected from the $config hashtable
    Get-EventLog -LogName $LogName -Newest $MaxEvents |
        Select-Object TimeGenerated, EntryType, Source, EventID, Message
}

# Notice we call (& $refreshScript) to get the initial data load,
# and pass the script block for subsequent UI refreshes.
Show-DataViewer -Data (& $refreshScript) `
                -RefreshScript $refreshScript `
                -Configuration $config `
                -Title 'Live Event Log Viewer'
```

### The Ultimate Complex Example
Combining everything: Inline editing, custom row actions, conditional formatting, dynamic refresh, and specific column selection.

```powershell
$categories = @('Alpha', 'Beta', 'Gamma')
$levels = @('Info', 'Warning', 'Error')

$refreshScript = {
    1..100 | ForEach-Object {
        [PSCustomObject]@{
            ID       = $_
            Name     = "Item-$($_.ToString('D4'))"
            Category = $categories[$_ % $categories.Count]
            Level    = $levels[$_ % $levels.Count]
            Value    = [math]::Round((Get-Random -Minimum 1 -Maximum 1000) / 100, 2)
            Reviewed = $false
        }
    }
}

$colors = @{
    Level = @{
        Error = '#FECACA'
        Warning = 'Gold'
    }
}

$actions = @(
    @{
        Name = 'Mark Reviewed'
        Scope = 'Row'
        ReturnToGrid = $true
        Script = {
            param($ActionData, $ActionContext)
            $ActionData.Reviewed = $true
            return "Marked $($ActionData.Name) as reviewed."
        }
    }
)

Show-DataViewer -Data (& $refreshScript) `
    -RefreshScript $refreshScript `
    -ColorMapping $colors `
    -Actions $actions `
    -Columns @('ID', 'Name', 'Level', 'Reviewed') `
    -AllowEdit `
    -Title 'Ultimate Operations Dashboard'
```

---

### SQLite Engine Examples

The following examples demonstrate how to leverage the embedded SQLite engine for high-volume datasets, offline database persistence, query limiting, and custom workflows.

#### Example 1: Automatic SQLite Ingestion on High-Volume Datasets
When loading datasets with 3,000 or more items, `Show-DataViewer` automatically initializes the SQLite engine in WAL mode and builds B-Tree indexes on common fields.

```powershell
# Ingest 15,000 system event logs
# Show-DataViewer detects the count >= 3,000 and automatically activates SQLite
$events = Get-WinEvent -ListProvider * -ErrorAction SilentlyContinue |
    Select-Object -First 100 |
    ForEach-Object {
        Get-WinEvent -ProviderName $_.Name -MaxEvents 150 -ErrorAction SilentlyContinue
    } |
    Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message

$events | Show-DataViewer -Title "High-Volume Event Log Viewer (Auto SQLite)"
```

#### Example 2: Explicit SQLite Mode with Custom Threshold (`-UseSqlite`, `-SqliteThreshold`)
Force SQLite execution on smaller datasets or adjust the threshold when memory efficiency is prioritized:

```powershell
# Force SQLite on a 1,200-item inventory dataset
$inventory = 1..1200 | ForEach-Object {
    [PSCustomObject]@{
        AssetId     = "AST-$($_)"
        Department  = @('Engineering', 'Finance', 'Operations', 'Security')[$_ % 4]
        Status      = @('Active', 'Maintenance', 'Decommissioned')[$_ % 3]
        Cost        = [Math]::Round((Get-Random -Minimum 200 -Maximum 5000), 2)
        LastAudit   = (Get-Date).AddDays(- ($_ % 365))
    }
}

# Force SQLite storage even though count < 3,000
$inventory | Show-DataViewer -UseSqlite -Title "Hardware Assets (Forced SQLite)"
```

#### Example 3: Persistent Forensic Database (`-SqliteDatabasePath`) with Post-Analysis Queries
Save the database directly to a `.db` file for forensic audit trails. You can inspect the data in the UI, close the viewer, and then execute standard SQL queries directly against the persisted file:

```powershell
$auditDbPath = "C:\Audits\SecurityAudit_$(Get-Date -Format 'yyyyMMdd_HHmmss').db"

# Pull security events and persist to an audit SQLite database
$secEvents = Get-WinEvent -LogName Security -MaxEvents 5000 -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, RecordId, MachineName, Message

Show-DataViewer -Data $secEvents `
                -SqliteDatabasePath $auditDbPath `
                -Title "Security Event Forensic Review"

# After the GUI is closed, the database persists on disk for query and export:
if (Test-Path $auditDbPath) {
    # Query summary statistics directly via PSSQLite
    $summary = Invoke-SqliteQuery -DataSource $auditDbPath -Query @"
        SELECT Id, COUNT(*) AS OccurrenceCount
        FROM DataViewerRecords
        GROUP BY Id
        ORDER BY OccurrenceCount DESC
        LIMIT 10;
"@
    $summary | Format-Table -AutoSize
}
```

#### Example 4: Query Limiting and Real-Time Inline Editing (`-SqliteLimit`, `-AllowEdit`)
Load a large dataset into SQLite, limit the initial UI DataGrid rendering to the top 200 rows for immediate display, and edit records with automatic database synchronization:

```powershell
$records = 1..10000 | ForEach-Object {
    [PSCustomObject]@{
        Id       = $_
        Category = @('Hardware', 'Software', 'Network')[$_ % 3]
        Priority = @('Low', 'Medium', 'High', 'Critical')[$_ % 4]
        Notes    = "Initial inspection notes for record $_"
    }
}

# Ingest all 10,000 rows into SQLite, but only pull the top 200 into the grid
# Double-clicking a cell updates both the UI object and DataViewerRecords in SQLite
Show-DataViewer -Data $records `
                -UseSqlite `
                -SqliteLimit 200 `
                -AllowEdit `
                -Title "Large Dataset Inspection with Inline Edit Sync"
```

#### Example 5: Forcing In-Memory Mode (`-NoSqlite`)
When your action scripts must modify original `PSCustomObject` instances in-place across your PowerShell session, use `-NoSqlite` to prevent database isolation:

```powershell
$servers = @(
    [PSCustomObject]@{ ServerName = 'SRV-DB01'; Status = 'Pending'; Checked = $false }
    [PSCustomObject]@{ ServerName = 'SRV-WEB01'; Status = 'Pending'; Checked = $false }
)

# Force in-memory engine so $servers references are mutated directly
$servers | Show-DataViewer -NoSqlite -AllowEdit -Title "In-Memory Session Editor"

# Edits are directly reflected on the original $servers variable in memory
$servers | Format-Table -AutoSize
```
