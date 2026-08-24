---
script_name: Show-DataViewer.ps1
relative_path: Show-DataViewer/Show-DataViewer.ps1
category: Show-DataViewer
webjea_enabled: true
parameters:
  - None
---

# Show-DataViewer.ps1

## Purpose
Show-DataViewer.ps1

## Parameters
| Parameter | Type | Mandatory | Default |
| :--- | :--- | :--- | :--- |
| None | N/A | N/A | N/A |

## Execution & Cmdlets Used
* `Add-Member`
* `Add-Type`
* `ConvertFrom-Json`
* `ConvertFrom-JsonEditedValue`
* `ConvertTo-Json`
* `Disable-ADAccount`
* `Disable-ScheduledTask`
* `Enable-ADAccount`
* `Enable-ScheduledTask`
* `explorer.exe`
* `Export-Csv`
* `ForEach-Object`
* `Format-List`
* `Get-ActionSummary`
* `Get-ADUser`
* `Get-ChildItem`
* `Get-CimInstance`
* `Get-Content`
* `Get-Date`
* `Get-Item`
* `Get-JsonNodeByPath`
* `Get-JsonRows`
* `Get-LastResultText`
* `Get-Module`
* `Get-NetTCPConnection`
* `Get-Process`
* `Get-ScheduledTask`
* `Get-ScheduledTaskInfo`
* `Get-Service`
* `Get-TaskHealth`
* `Get-TriggerSummary`
* `Get-WinEvent`
* `global:Apply-Filters`
* `Group-Object`
* `Import-Module`
* `Invoke-Item`
* `Join-Path`
* `Measure-Object`
* `New-Item`
* `New-Object`
* `Out-Null`
* `Out-String`
* `read_first_X_chars`
* `Restart-Service`
* `sc.exe`
* `script:Add-FieldToList`
* `script:Apply-Filters`
* `script:Apply-FilterState`
* `script:Apply-Theme`
* `script:Build-Chart`
* `script:Build-FilterControls`
* `script:Build-GridColumns`
* `script:Build-PivotData`
* `script:Copy-SelectedDetails`
* `script:Copy-SelectedRow`
* `script:Export-Collection`
* `script:Format-Value`
* `script:Get-CurrentFilterState`
* `script:Get-DefaultVisibleColumns`
* `script:Get-FilteredItems`
* `script:Get-RunspacePool`
* `script:Initialize-DynamicSchema`
* `script:Initialize-PivotFields`
* `script:Load-Data`
* `script:Load-Settings`
* `script:Move-ListBoxItem`
* `script:Refresh-SavedViewsList`
* `script:Reset-AllFilters`
* `script:Resolve-DatasetRefreshSource`
* `script:Resolve-OriginalItem`
* `script:Save-Settings`
* `script:Schedule-FilterApply`
* `script:Show-ColumnChooser`
* `script:Show-ConfigDialog`
* `script:Update-DetailPane`
* `script:Update-DynamicFilters`
* `script:Update-EmptyState`
* `script:Update-FilterControlVisibilities`
* `script:Update-FooterSummary`
* `script:Update-GroupByHighlight`
* `script:Update-GroupByPanel`
* `Select-Object`
* `Set-Clipboard`
* `Set-Content`
* `Set-JsonNodeByPath`
* `Set-Variable`
* `Sort-Object`
* `Split-Path`
* `Start-Process`
* `Start-ScheduledTask`
* `Start-Service`
* `Start-Sleep`
* `Stop-Process`
* `Stop-ScheduledTask`
* `Stop-Service`
* `Test-Path`
* `Unlock-ADAccount`
* `Update-StatusText`
* `Where-Object`
* `Write-Output`
* `Write-Verbose`
* `Write-Warning`
* WebJEA detection signals: HTML or JSON-oriented output; CmdletBinding attribute.

## Security & Impact Notes
* Impact level: High - potentially destructive, service-affecting, or remote execution operations detected.
* Delegation/permission guidance: No explicit permissions guidance was found in comment-based help; validate the WebJEA/JEA run identity and apply least privilege.

## Extracted Examples
```powershell
Process explorer mode - is a set of actions and configuration that allows you to browse running processes.
    Show-DataViewer -ProcessExplorerMode
```
```powershell
$data = Get-Process | Select-Object Name, Id, CPU, Handles
    Show-DataViewer -Data $data -Title 'Process Monitor'
```
```powershell
File explorer mode - is a set of actions and configuration that allows you to browse the file system.
    Show-DataViewer -FileExplorerMode
```
```powershell
File explorer mode with custom configuration overrides (start path and characters to read).
    $config = @{
        CurrentPath      = 'D:\'
        CharactersToRead = 200
        ReadContent      = $false
    }
    Show-DataViewer -FileExplorerMode -Configuration $config -Title "Custom File Browser"
```
```powershell
Advanced Process Explorer with list all running processes with advanced monitoring features.
    Show-DataViewer -ProcessExplorerMode -Configuration $config
```
```powershell
Windows Service Manager replacement. Lists services and allows starting/stopping.
    Show-DataViewer -ServiceManagerMode
```
```powershell
Fast Event Log Viewer. Gathers top 1000 application and system events.
    Show-DataViewer -EventViewerMode
```
```powershell
Network Connection Analyzer (Netstat). Finds what process is holding which port.
    Show-DataViewer -NetStatMode
```
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
```
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
```powershell
$config = @{
        MaxEvents = 200
        LogName = 'System'
    }

    $refreshScript = {
        $resolvedMaxEvents = if ([string]::IsNullOrWhiteSpace([string]$MaxEvents)) { 200 }
                             elseif ([int]$MaxEvents -le 0) { 200 }
                             else { [int]$MaxEvents }
        if([string]::IsNullOrWhiteSpace([string]$LogName)) { $LogName = 'System' }
        Get-EventLog -LogName $LogName -Newest $resolvedMaxEvents |
            Select-Object TimeGenerated, EntryType, Source, EventID, Message
    }

    Show-DataViewer -Data (& $refreshScript) `
        -RefreshScript $refreshScript `
        -Configuration $config `
        -Title 'System Event Log'
```
```powershell
File Browser Example: Launch a fully functional WPF-based file browser with double-click navigation.
    Show-DataViewer -FileExplorerMode -Title "My File Browser"
```
```powershell
File Browser Example with custom configuration overrides (start path and characters to read).
    $config = @{
        CurrentPath = 'D:\'
        CharactersToRead = 200
        ReadContent = $false
    }
    Show-DataViewer -FileExplorerMode -Configuration $config -Title "Custom File Browser"
```
```powershell
JSON Explorer Editor Example: Launch a fully functional WPF-based JSON explorer and editor.
    Show-DataViewer -JsonExplorerMode -Title "My JSON Editor"
```
```powershell
$config = @{
        Categories = @('Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon')
        Levels = @('Info', 'Warning', 'Error', 'Critical')
        Users = @('admin', 'john.doe', 'jane.smith', 'bob.jones', 'alice.wang', 'dev.test')
        Servers = @('SRV01', 'SRV02', 'SRV03')
        MaxElements = 5000
    }

    $data = 1..$config.MaxElements | ForEach-Object {
        [PSCustomObject]@{
            ID       = $_
            Name     = "Item-$($_.ToString('D4'))"
            Category = $config.Categories[$_ % $config.Categories.Count]
            Level    = $config.Levels[$_ % $config.Levels.Count]
            User     = $config.Users[$_ % $config.Users.Count]
            Server   = $config.Servers[$_ % $config.Servers.Count]
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

.AUTHOR
    Adam Mnich @2026
>
endregion

function Show-DataViewer {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [PSCustomObject[]]$Data,

        [scriptblock]$RefreshScript,

        [hashtable]$Configuration,

        [string[]]$Columns,

        [hashtable]$ColorMapping,

        [string]$Title = 'Data Viewer',

        [int]$GroupByTopN = 10,

        [hashtable[]]$Actions = @(),

        [switch]$AllowEdit,

        [switch]$FileExplorerMode,

        [switch]$ProcessExplorerMode,

        [switch]$ServiceManagerMode,

        [switch]$EventViewerMode,

        [switch]$NetStatMode,

        [switch]$ADUserExplorerMode,

        [switch]$TaskSchedulerMode,

        [switch]$JsonExplorerMode
    )

    begin {
        $collectedData = [System.Collections.Generic.List[PSCustomObject]]::new()
    }
    process {
        if ($Data) {
            foreach ($item in $Data) {
                $collectedData.Add($item)
            }
        }
    }
    end {
        if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
            Write-Warning "The WPF framework requires a Single-Threaded Apartment (STA) state. Please start PowerShell with the '-STA' parameter."
            return
        }
        $inputData = @($collectedData)
region Example Usage implemented into switches
region File Explorer Mode
        if ($FileExplorerMode) {
1. Configuration
            $defaultConfig = @{
                CurrentPath      = 'C:\'
                CharactersToRead = 100
                ReadContent      = $true
            }
            if ($null -eq $Configuration) {
                $Configuration = $defaultConfig
            }
            else {
                foreach ($key in $defaultConfig.Keys) {
                    if (-not $Configuration.ContainsKey($key)) {
                        $Configuration[$key] = $defaultConfig[$key]
                    }
                }
            }
2. RefreshScript
            if ($null -eq $RefreshScript) {
                $RefreshScript = {
                    function read_first_X_chars {
                        param($path, [int]$Chars = 100)
                        if (-not (Test-Path -Path $path)) { return }
                        if ((Get-Item -Path $path).PSIsContainer) { return }
                        $reader = [System.IO.StreamReader]::new($path)
                        $buffer = [char[]]::new($Chars)
                        $charsRead = $reader.Read($buffer, 0, $Chars)
                        $reader.Close()
                        $reader.Dispose()
                        $result = -join $buffer[0..($charsRead - 1)]
                        $singleLineResult = $result -replace '\r?\n', ' '
                        Write-Output $singleLineResult
                    }
                    if ($ReadContent) {
                        Get-ChildItem -Path $CurrentPath -ErrorAction SilentlyContinue | 
                        Select-Object Name, Length, Extension, CreationTime, LastWriteTime, Mode, FullName, @{Name = 'FirstChars'; Expression = { read_first_X_chars $_.FullName $CharactersToRead } }
                    }
                    else {
                        Get-ChildItem -Path $CurrentPath -ErrorAction SilentlyContinue | 
                        Select-Object Name, Length, Extension, CreationTime, LastWriteTime, Mode, FullName
                    }
                }
            }
3. Actions
            $defaultActions = @(
                @{
                    Name         = 'Enter / Open'
                    Scope        = 'DoubleClick'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        if ($Data.Mode -match 'd') {
                            $Context.Configuration['CurrentPath'] = $Data.FullName
                            $btnRefresh = $Context.Window.FindName('btnRefresh')
                            if ($btnRefresh) {
                                $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                            }
                        }
                        else {
                            Invoke-Item -Path $Data.FullName
                        }
                    }
                },
                @{
                    Name         = 'Go Up (..)'
                    Scope        = 'Row'
                    Icon         = '⬆️'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        $currentPath = $Context.Configuration['CurrentPath']
                        $parent = Split-Path -Path $currentPath -Parent
                        if ($parent) {
                            $Context.Configuration['CurrentPath'] = $parent
                            $btnRefresh = $Context.Window.FindName('btnRefresh')
                            if ($btnRefresh) {
                                $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                            }
                        }
                    }
                },
                @{
                    Name         = 'Go Up (..)'
                    Scope        = 'Dataset'
                    Icon         = '⬆️'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        $currentPath = $Context.Configuration['CurrentPath']
                        $parent = Split-Path -Path $currentPath -Parent
                        if ($parent) {
                            $Context.Configuration['CurrentPath'] = $parent
                            $btnRefresh = $Context.Window.FindName('btnRefresh')
                            if ($btnRefresh) {
                                $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                            }
                        }
                    }
                }
            )

            if ($null -eq $Actions) {
                $Actions = $defaultActions
            }
            else {
Add default actions to user actions (prepend)
                $Actions = @($defaultActions) + @($Actions)
            }
4. Initial Data
            if ($null -eq $inputData -or $inputData.Count -eq 0) {
                $inputData = & {
                    foreach ($key in $Configuration.Keys) {
                        Set-Variable -Name $key -Value $Configuration[$key] -Scope Local
                    }
                    & $RefreshScript
                }
            }
        }
endregion
region Process Explorer Mode
        if ($ProcessExplorerMode) {
1. ColorMapping
            if ($null -eq $ColorMapping) {
                $ColorMapping = @{
                    Responding = @{
                        'False' = '#FECACA' # Light Red
                    }
                }
            }
2. Columns
            if ($null -eq $Columns) {
                $Columns = @('Name', 'Id', 'CPU(s)', 'RAM(MB)', 'Responding', 'Company', 'StartTime', 'Path')
            }
3. RefreshScript
            if ($null -eq $RefreshScript) {
                $RefreshScript = {
                    Get-Process | Select-Object Name, Id, 
                    @{Name = 'CPU(s)'; Expression = { if ($_.CPU) { [double][math]::Round($_.CPU, 2) } else { [double]0.0 } } },
                    @{Name = 'RAM(MB)'; Expression = { [double][math]::Round($_.WorkingSet64 / 1MB, 2) } },
                    @{Name = 'Handles'; Expression = { if ($null -ne $_.Handles) { [int]$_.Handles } else { [int]0 } } }, 
                    @{Name = 'Path'; Expression = { if ($null -ne $_.Path) { [string]$_.Path } else { '' } } },
                    @{Name = 'Company'; Expression = { if ($null -ne $_.Company) { [string]$_.Company } else { '' } } },
                    Responding,
                    @{Name = 'StartTime'; Expression = { if ($_.StartTime) { $_.StartTime.ToString('yyyy-MM-dd HH:mm:ss') } else { '' } } },
                    @{Name = 'SessionId'; Expression = { if ($null -ne $_.SessionId) { [int]$_.SessionId } else { [int]0 } } },
                    @{Name = 'PriorityClass'; Expression = { if ($null -ne $_.PriorityClass) { $_.PriorityClass.ToString() } else { '' } } },
                    @{Name = 'BasePriority'; Expression = { if ($null -ne $_.BasePriority) { [int]$_.BasePriority } else { [int]0 } } },
                    @{Name = 'MainWindowTitle'; Expression = { if ($null -ne $_.MainWindowTitle) { [string]$_.MainWindowTitle } else { '' } } },
                    @{Name = 'MainWindowHandle'; Expression = { if ($null -ne $_.MainWindowHandle) { [long]$_.MainWindowHandle } else { [long]0 } } },
                    @{Name = 'Threads'; Expression = { if ($null -ne $_.Threads) { [int]$_.Threads.Count } else { [int]0 } } },
                    @{Name = 'Description'; Expression = { if ($null -ne $_.Description) { [string]$_.Description } else { '' } } },
                    @{Name = 'ProductVersion'; Expression = { if ($null -ne $_.ProductVersion) { [string]$_.ProductVersion } else { '' } } },
                    @{Name = 'FileVersion'; Expression = { if ($null -ne $_.FileVersion) { [string]$_.FileVersion } else { '' } } }
                }
            }
4. Actions
            $defaultProcessActions = @(
                @{
                    Name         = 'Kill Process'
                    Scope        = 'Row'
                    Icon         = '🛑'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        if ($Data.Id -gt 0) {
                            Stop-Process -Id $Data.Id -Force -ErrorAction SilentlyContinue
                            "Killed process: $($Data.Name) (ID: $($Data.Id))"
                        }
                    }
                },
                @{
                    Name         = 'Open Location'
                    Scope        = 'Row'
                    Icon         = '📂'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        if ([string]::IsNullOrWhiteSpace($Data.Path) -eq $false -and (Test-Path -Path $Data.Path)) {
                            explorer.exe /select, "$($Data.Path)"
                        }
                        else {
                            [System.Windows.MessageBox]::Show("Path not available or access denied.", "Info", 0, 64)
                        }
                    }
                },
                @{
                    Name         = 'Search Online'
                    Scope        = 'DoubleClick'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        $query = [uri]::EscapeDataString($Data.Name + ' process windows')
                        Start-Process "https://www.google.com/search?q=$query"
                    }
                }
            )

            if ($null -eq $Actions) {
                $Actions = $defaultProcessActions
            }
            else {
                $Actions = @($defaultProcessActions) + @($Actions)
            }
5. Initial Data
            if ($null -eq $inputData -or $inputData.Count -eq 0) {
                $inputData = & $RefreshScript
            }
            
            if ($Title -eq 'Data Viewer') {
                $Title = 'Advanced Process Explorer'
            }
        }
endregion
region Service Manager Mode    
        if ($ServiceManagerMode) {
1. ColorMapping
            if ($null -eq $ColorMapping) {
                $ColorMapping = @{
                    Status = @{
                        'Running' = '#D1FAE5' # Light Green
                        'Stopped' = '#FECACA' # Light Red
                    }
                }
            }
2. Columns
            if ($null -eq $Columns) {
                $Columns = @('Status', 'Name', 'DisplayName', 'StartType', 'ProcessId', 'LogOnAs', 'PathName')
            }
3. RefreshScript
            if ($null -eq $RefreshScript) {
                $RefreshScript = {
                    $cimServices = Get-CimInstance -ClassName Win32_Service -ErrorAction SilentlyContinue | Group-Object -Property Name -AsHashTable -AsString
                    Get-Service | ForEach-Object {
                        $cim = $cimServices[$_.Name]
                        $startMode = if ($cim) { $cim.StartMode } else { $_.StartType }
                        $logOnAs = if ($cim) { $cim.StartName } else { '' }
                        $description = if ($cim) { $cim.Description } else { '' }
                        $processId = if ($cim) { $cim.ProcessId } else { '' }
                        $pathName = if ($cim) { $cim.PathName } else { '' }
                        
                        [PSCustomObject]@{
                            Status              = $_.Status
                            Name                = $_.Name
                            DisplayName         = $_.DisplayName
                            StartType           = $startMode
                            ProcessId           = $processId
                            LogOnAs             = $logOnAs
                            PathName            = $pathName
                            Description         = $description
                            CanStop             = $_.CanStop
                            CanPauseAndContinue = $_.CanPauseAndContinue
                        }
                    }
                }
            }
4. Actions
            $defaultServiceActions = @(
                @{
                    Name         = 'Start'
                    Scope        = 'Row'
                    Icon         = '▶️'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        if ($Data.Status -ne 'Running') {
                            Start-Service -Name $Data.Name -ErrorAction SilentlyContinue
                            Start-Sleep -Milliseconds 500
                            "Started $($Data.Name)"
                        }
                    }
                },
                @{
                    Name         = 'Stop'
                    Scope        = 'Row'
                    Icon         = '⏹️'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        if ($Data.Status -ne 'Stopped' -and $Data.CanStop) {
                            Stop-Service -Name $Data.Name -Force -ErrorAction SilentlyContinue
                            Start-Sleep -Milliseconds 500
                            "Stopped $($Data.Name)"
                        }
                    }
                },
                @{
                    Name         = 'Restart'
                    Scope        = 'Row'
                    Icon         = '🔄'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        Restart-Service -Name $Data.Name -Force -ErrorAction SilentlyContinue
                        Start-Sleep -Milliseconds 500
                        "Restarted $($Data.Name)"
                    }
                },
                @{
                    Name         = 'Search Online'
                    Scope        = 'DoubleClick'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        $query = [uri]::EscapeDataString($Data.Name + ' windows service')
                        Start-Process "https://www.google.com/search?q=$query"
                    }
                },
                @{
                    Name         = 'Set Auto'
                    Scope        = 'Row'
                    Icon         = '⚙️'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        $out = sc.exe config "$($Data.Name)" start= auto 2>&1
                        if ($LASTEXITCODE -eq 0) { "Set $($Data.Name) to Automatic" } else { "Failed: $out" }
                    }
                },
                @{
                    Name         = 'Set Manual'
                    Scope        = 'Row'
                    Icon         = '⚙️'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        $out = sc.exe config "$($Data.Name)" start= demand 2>&1
                        if ($LASTEXITCODE -eq 0) { "Set $($Data.Name) to Manual" } else { "Failed: $out" }
                    }
                },
                @{
                    Name         = 'Set Disabled'
                    Scope        = 'Row'
                    Icon         = '🚫'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        $out = sc.exe config "$($Data.Name)" start= disabled 2>&1
                        if ($LASTEXITCODE -eq 0) { "Set $($Data.Name) to Disabled" } else { "Failed: $out" }
                    }
                }
            )

            if ($null -eq $Actions) {
                $Actions = $defaultServiceActions
            }
            else {
                $Actions = @($defaultServiceActions) + @($Actions)
            }
5. Initial Data
            if ($null -eq $inputData -or $inputData.Count -eq 0) {
                $inputData = & $RefreshScript
            }
            
            if ($Title -eq 'Data Viewer') {
                $Title = 'Service Manager'
            }
        }
endregion
region Event Viewer Mode
        if ($EventViewerMode) {
1. ColorMapping
            if ($null -eq $ColorMapping) {
                $ColorMapping = @{
                    LevelDisplayName = @{
                        'Error'   = '#FECACA'   # Light Red
                        'Warning' = '#FEF3C7' # Light Yellow
                    }
                }
            }
2. Columns
            if ($null -eq $Columns) {
                $Columns = @('TimeCreated', 'ProviderName', 'Id', 'LevelDisplayName', 'Message')
            }
3. Config
            if ($null -eq $Configuration) {
                $Configuration = @{}
            }
            if (-not $Configuration.ContainsKey('MaxEvents')) { $Configuration.MaxEvents = 1000 }
            if (-not $Configuration.ContainsKey('LogNames')) { $Configuration.LogNames = @('System', 'Application') }
            if (-not $Configuration.ContainsKey('ComboBoxMaxUnique')) { $Configuration.ComboBoxMaxUnique = 1000 }
4. RefreshScript
            if ($null -eq $RefreshScript) {
                $RefreshScript = {
$logs = @('System', 'Application')
if ($Configuration.LogNames) { $logs = $Configuration.LogNames }
if ($Configuration.MaxEvents) { $maxEvents = $Configuration.MaxEvents }
                    
                    try {
                        Get-WinEvent -LogName $LogNames -MaxEvents $maxEvents -ErrorAction SilentlyContinue |
                        Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message, LogName, TaskDisplayName, OpcodeDisplayName
                    }
                    catch {}
                }
            }
5. Actions
            $defaultEventActions = @(
                @{
                    Name         = 'Search EventID Online'
                    Scope        = 'DoubleClick'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        $query = [uri]::EscapeDataString($Data.ProviderName + ' Event ID ' + $Data.Id)
                        Start-Process "https://www.google.com/search?q=$query"
                    }
                }
            )

            if ($null -eq $Actions) {
                $Actions = $defaultEventActions
            }
            else {
                $Actions = @($defaultEventActions) + @($Actions)
            }
6. Initial Data
            if ($null -eq $inputData -or $inputData.Count -eq 0) {
                $inputData = & {
                    foreach ($key in $Configuration.Keys) {
                        Set-Variable -Name $key -Value $Configuration[$key] -Scope Local
                    }
                    & $RefreshScript
                }
            }
            
            if ($Title -eq 'Data Viewer') {
                $Title = 'Event Viewer'
            }
        }
endregion
region Network Connection Analyzer Mode
        if ($NetStatMode) {
1. ColorMapping
            if ($null -eq $ColorMapping) {
                $ColorMapping = @{
                    State = @{
                        'Established' = '#D1FAE5' # Light Green
                        'TimeWait'    = '#F3F4F6'    # Light Gray
                        'Listen'      = '#E0E7FF'      # Light Blue
                    }
                }
            }
2. Columns
            if ($null -eq $Columns) {
                $Columns = @('ProcessName', 'OwningProcess', 'LocalAddress', 'LocalPort', 'RemoteAddress', 'RemotePort', 'State')
            }
3. RefreshScript
            if ($null -eq $RefreshScript) {
                $RefreshScript = {
                    $processes = Get-Process -ErrorAction SilentlyContinue | Group-Object -Property Id -AsHashTable -AsString
                    Get-NetTCPConnection -ErrorAction SilentlyContinue | ForEach-Object {
                        $proc = $processes[$_.OwningProcess.ToString()]
                        $procName = if ($proc) { $proc.Name } else { 'Unknown' }
                        $procPath = if ($proc) { $proc.Path } else { '' }
                        
                        [PSCustomObject]@{
                            ProcessName   = $procName
                            OwningProcess = $_.OwningProcess
                            LocalAddress  = $_.LocalAddress
                            LocalPort     = $_.LocalPort
                            RemoteAddress = $_.RemoteAddress
                            RemotePort    = $_.RemotePort
                            State         = $_.State
                            CreationTime  = $_.CreationTime
                            ProcessPath   = $procPath
                        }
                    }
                }
            }
4. Actions
            $defaultNetStatActions = @(
                @{
                    Name         = 'Kill Owning Process'
                    Scope        = 'Row'
                    Icon         = '🛑'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        if ($Data.OwningProcess -gt 0) {
                            Stop-Process -Id $Data.OwningProcess -Force -ErrorAction SilentlyContinue
                            "Killed process: $($Data.ProcessName) (ID: $($Data.OwningProcess))"
                        }
                    }
                },
                @{
                    Name         = 'Open Process Location'
                    Scope        = 'DoubleClick'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        if ([string]::IsNullOrWhiteSpace($Data.ProcessPath) -eq $false -and (Test-Path -Path $Data.ProcessPath)) {
                            explorer.exe /select, "$($Data.ProcessPath)"
                        }
                        else {
                            [System.Windows.MessageBox]::Show("Path not available or access denied.", "Info", 0, 64)
                        }
                    }
                }
            )

            if ($null -eq $Actions) {
                $Actions = $defaultNetStatActions
            }
            else {
                $Actions = @($defaultNetStatActions) + @($Actions)
            }
5. Initial Data
            if ($null -eq $inputData -or $inputData.Count -eq 0) {
                $inputData = & $RefreshScript
            }
            
            if ($Title -eq 'Data Viewer') {
                $Title = 'Network Connection Analyzer'
            }
        }
region AD Explorer Mode
        if ($ADUserExplorerMode) {
1. Module check
            if (-not (Get-Module ActiveDirectory)) {
                Import-Module ActiveDirectory -ErrorAction SilentlyContinue
                if (-not (Get-Module ActiveDirectory)) {
                    [System.Windows.MessageBox]::Show("ActiveDirectory module is required for ADUserExplorerMode. Please install RSAT.", "Missing Module", 0, 16)
                }
            }
2. ColorMapping
            if ($null -eq $ColorMapping) {
                $ColorMapping = @{
                    Status       = @{
                        'Stale'    = '#FECACA' # Light Red
                        'Disabled' = '#F3F4F6' # Light Gray
                        'Active'   = '#D1FAE5' # Light Green
                    }
                    IsPrivileged = @{
                        'True' = '#FDE047' # Yellow highlight for privileged
                    }
                }
            }
3. Columns
            if ($null -eq $Columns) {
                $Columns = @('Status', 'IsPrivileged', 'SamAccountName', 'Name', 'Enabled', 'LockedOut', 'LastLogonDate', 'PasswordLastSet')
            }
4. RefreshScript
            if ($null -eq $RefreshScript) {
                $RefreshScript = {
                    $domain = if ($Configuration.Domain) { $Configuration.Domain } else { $env:USERDNSDOMAIN }
                    $privilegedGroups = @('Domain Admins', 'Enterprise Admins', 'Schema Admins', 'Administrators')
                    $staleDate = (Get-Date).AddDays(-90)

                    $params = @{
                        Filter      = '*'
                        Properties  = 'MemberOf', 'LastLogonDate', 'PasswordLastSet', 'Enabled', 'LockedOut', 'PasswordNeverExpires', 'Title', 'Department', 'EmailAddress'
                        ErrorAction = 'SilentlyContinue'
                    }
                    if ($domain) { $params.Server = $domain }

                    Get-ADUser @params | ForEach-Object {
                        
                        $isPrivileged = $false
                        if ($_.MemberOf) {
                            foreach ($group in $_.MemberOf) {
                                foreach ($privGroup in $privilegedGroups) {
                                    if ($group -match "CN=$privGroup,") {
                                        $isPrivileged = $true
                                        break
                                    }
                                }
                                if ($isPrivileged) { break }
                            }
                        }

                        $staleStatus = "Active"
                        if ($_.Enabled -eq $false) {
                            $staleStatus = "Disabled"
                        }
                        elseif ($_.LastLogonDate -lt $staleDate -and $_.LastLogonDate -ne $null) {
                            $staleStatus = "Stale"
                        }

                        [PSCustomObject]@{
                            SamAccountName       = $_.SamAccountName
                            Name                 = $_.Name
                            Enabled              = $_.Enabled
                            LockedOut            = $_.LockedOut
                            IsPrivileged         = $isPrivileged
                            Status               = $staleStatus
                            LastLogonDate        = $_.LastLogonDate
                            PasswordLastSet      = $_.PasswordLastSet
                            PasswordNeverExpires = $_.PasswordNeverExpires
                            Title                = $_.Title
                            Department           = $_.Department
                            EmailAddress         = $_.EmailAddress
                        }
                    }
                }
            }
5. Actions
            $defaultADActions = @(
                @{
                    Name         = 'Disable Account'
                    Scope        = 'Row'
                    Icon         = '🚫'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        if ($Data.Enabled) {
                            $domain = if ($Context.Configuration.Domain) { $Context.Configuration.Domain } else { $env:USERDNSDOMAIN }
                            if ($domain) {
                                Disable-ADAccount -Identity $Data.SamAccountName -Server $domain -ErrorAction Stop
                            }
                            else {
                                Disable-ADAccount -Identity $Data.SamAccountName -ErrorAction Stop
                            }
                            "Disabled account: $($Data.SamAccountName)"
                        }
                        else {
                            "Account $($Data.SamAccountName) is already disabled."
                        }
                    }
                },
                @{
                    Name         = 'Enable Account'
                    Scope        = 'Row'
                    Icon         = '✅'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        if (-not $Data.Enabled) {
                            $domain = if ($Context.Configuration.Domain) { $Context.Configuration.Domain } else { $env:USERDNSDOMAIN }
                            if ($domain) {
                                Enable-ADAccount -Identity $Data.SamAccountName -Server $domain -ErrorAction Stop
                            }
                            else {
                                Enable-ADAccount -Identity $Data.SamAccountName -ErrorAction Stop
                            }
                            "Enabled account: $($Data.SamAccountName)"
                        }
                        else {
                            "Account $($Data.SamAccountName) is already enabled."
                        }
                    }
                },
                @{
                    Name         = 'Unlock Account'
                    Scope        = 'Row'
                    Icon         = '🔓'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        if ($Data.LockedOut) {
                            $domain = if ($Context.Configuration.Domain) { $Context.Configuration.Domain } else { $env:USERDNSDOMAIN }
                            if ($domain) {
                                Unlock-ADAccount -Identity $Data.SamAccountName -Server $domain -ErrorAction Stop
                            }
                            else {
                                Unlock-ADAccount -Identity $Data.SamAccountName -ErrorAction Stop
                            }
                            "Unlocked account: $($Data.SamAccountName)"
                        }
                        else {
                            "Account $($Data.SamAccountName) is not locked out."
                        }
                    }
                }
            )

            if ($null -eq $Actions) {
                $Actions = $defaultADActions
            }
            else {
                $Actions = @($defaultADActions) + @($Actions)
            }
6. Initial Data
            if ($null -eq $inputData -or $inputData.Count -eq 0) {
                $inputData = & $RefreshScript
            }
            
            if ($Title -eq 'Data Viewer') {
                $Title = 'Active Directory User Explorer'
            }
        }
endregion
region Task Scheduler Mode
        if ($TaskSchedulerMode) {
1. Configuration
            if ($null -eq $Configuration) {
                $Configuration = @{
                    TaskPathFilter   = '\'
                    IncludeMicrosoft = $false
                    NameLike         = '*'
                    ShowHidden       = $true
                    StaleDays        = 30
                }
            }
2. ColorMapping
            if ($null -eq $ColorMapping) {
                $ColorMapping = @{
                    Health = @{
                        Failed     = '#FECACA'
                        Healthy    = '#DCFCE7'
                        Running    = '#BBF7D0'
                        Disabled   = '#E5E7EB'
                        MissedRuns = '#FEF3C7'
                        Stale      = '#FED7AA'
                        Unknown    = '#E0E7FF'
                    }
                }
            }
3. Columns
            if ($null -eq $Columns) {
                $Columns = @(
                    'TaskName', 'TaskPath', 'State', 'Health', 'Enabled',
                    'LastRunTime', 'NextRunTime', 'NumberOfMissedRuns', 'LastTaskResultText',
                    'Author', 'UserId', 'RunLevel', 'Description',
                    'ActionSummary', 'TriggerSummary'
                )
            }
4. RefreshScript
            if ($null -eq $RefreshScript) {
                $RefreshScript = {
                    if ([string]::IsNullOrWhiteSpace($TaskPathFilter)) { $TaskPathFilter = '\' }
                    if ([string]::IsNullOrWhiteSpace($NameLike)) { $NameLike = '*' }
                    if ($null -eq $ShowHidden) { $ShowHidden = $true }
                    if ($null -eq $IncludeMicrosoft) { $IncludeMicrosoft = $false }
                    if ($null -eq $StaleDays -or [int]$StaleDays -lt 1) { $StaleDays = 30 }

                    function Get-TaskHealth {
                        param($Task, $Info, [int]$StaleDays)

                        $state = [string]$Task.State
                        $lastResult = if ($null -ne $Info -and $null -ne $Info.LastTaskResult) { [long]$Info.LastTaskResult } else { $null }

                        if ($state -eq 'Disabled') { return 'Disabled' }
                        if ($state -eq 'Running') { return 'Running' }

                        if ($null -ne $Info) {
                            if ($Info.NumberOfMissedRuns -gt 0) { return 'MissedRuns' }

                            if ($Info.LastRunTime -and $Info.LastRunTime -lt (Get-Date).AddDays(-$StaleDays) -and $state -eq 'Ready') {
                                return 'Stale'
                            }

                            if ($null -ne $lastResult -and $lastResult -eq 0) {
                                return 'Healthy'
                            }

                            if ($null -ne $lastResult -and $lastResult -ne 0) {
                                return 'Failed'
                            }
                        }

                        return 'Unknown'
                    }

                    function Get-LastResultText {
                        param($Code)

                        if ($null -eq $Code) { return 'Unknown' }

                        $code64 = [long]$Code

                        switch ($code64) {
                            0 { 'Success (0x0)' }
                            1 { 'Incorrect function (0x1)' }
                            2 { 'File not found (0x2)' }
                            2147942402 { 'File not found (0x80070002)' }
                            2147942667 { 'Logon failure / account restriction (0x8007052B)' }
                            default { '0x{0:X}' -f $code64 }
                        }
                    }
                    function Get-ActionSummary {
                        param($Actions)
                        if (-not $Actions) { return $null }

                        @($Actions | ForEach-Object {
                                $type = $_.CimClass.CimClassName
                                switch ($type) {
                                    'MSFT_TaskExecAction' {
                                        if ($_.Arguments) { "Exec: $($_.Execute) $($_.Arguments)" }
                                        else { "Exec: $($_.Execute)" }
                                    }
                                    'MSFT_TaskComHandlerAction' { "ComHandler: $($_.ClassId)" }
                                    'MSFT_TaskSendEmailAction' { "Email: $($_.To)" }
                                    'MSFT_TaskShowMessageAction' { "Message: $($_.Title)" }
                                    default { $type }
                                }
                            }) -join ' | '
                    }
                    
                    function Get-TriggerSummary {
                        param($Triggers)
                        if (-not $Triggers) { return $null }

                        @($Triggers | ForEach-Object {
                                $type = $_.CimClass.CimClassName
                                $start = if ($_.StartBoundary) { "Start=$($_.StartBoundary)" } else { $null }
                                $enabled = "Enabled=$($_.Enabled)"
                                @($type, $start, $enabled) -ne $null -join '; '
                            }) -join ' || '
                    }

                    $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
                        $_.TaskName -like $NameLike -and
                        ($ShowHidden -or -not $_.Settings.Hidden) -and
                        ($IncludeMicrosoft -or $_.TaskPath -notlike '\Microsoft\Windows\*') -and
                        (
                            $TaskPathFilter -eq '\' -or
                            $TaskPathFilter -eq '*' -or
                            $_.TaskPath -like $TaskPathFilter
                        )
                    }

                    foreach ($task in $tasks) {
                        $info = $null
                        try { $info = $task | Get-ScheduledTaskInfo -ErrorAction Stop } catch {}

                        [PSCustomObject]@{
                            TaskName           = [string]$task.TaskName
                            TaskPath           = [string]$task.TaskPath
                            URI                = [string]$task.URI
                            State              = [string]$task.State
                            Enabled            = [bool]$task.Settings.Enabled
                            Hidden             = [bool]$task.Settings.Hidden
                            Health             = Get-TaskHealth -Task $task -Info $info -StaleDays $StaleDays

                            Description        = [string]$task.Description
                            Author             = [string]$task.Author
                            Source             = [string]$task.Source
                            Documentation      = [string]$task.Documentation
                            Date               = [string]$task.Date
                            Version            = [string]$task.Version

                            UserId             = [string]$task.Principal.UserId
                            GroupId            = [string]$task.Principal.GroupId
                            LogonType          = [string]$task.Principal.LogonType
                            RunLevel           = [string]$task.Principal.RunLevel

                            ActionCount        = @($task.Actions).Count
                            TriggerCount       = @($task.Triggers).Count
                            ActionSummary      = [string](Get-ActionSummary $task.Actions)
                            TriggerSummary     = [string](Get-TriggerSummary $task.Triggers)

                            LastRunTime        = if ($info -and $info.LastRunTime) { $info.LastRunTime.ToString('yyyy-MM-dd HH:mm:ss') } else { '' }
                            NextRunTime        = if ($info -and $info.NextRunTime) { $info.NextRunTime.ToString('yyyy-MM-dd HH:mm:ss') } else { '' }
                            NumberOfMissedRuns = if ($info) { [int]$info.NumberOfMissedRuns } else { 0 }
                            LastTaskResult     = if ($info -and $null -ne $info.LastTaskResult) { [long]$info.LastTaskResult } else { [long]0 }
                            LastTaskResultText = Get-LastResultText $(if ($info) { $info.LastTaskResult } else { $null })

                            RawActions         = [string]($task.Actions | Out-String).Trim()
                            RawTriggers        = [string]($task.Triggers | Out-String).Trim()
                        }
                    }
                }
            }
5. Actions
            $defaultTaskActions = @(
                @{
                    Name         = 'Run / Stop'
                    Scope        = 'Row'
                    Icon         = '⚙'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        try {
                            if ([string]$Data.State -eq 'Running') {
                                Stop-ScheduledTask -TaskName $Data.TaskName -TaskPath $Data.TaskPath -ErrorAction Stop
                            }
                            else {
                                Start-ScheduledTask -TaskName $Data.TaskName -TaskPath $Data.TaskPath -ErrorAction Stop
                            }
                            Start-Sleep -Milliseconds 600
                            $btnRefresh = $Context.Window.FindName('btnRefresh')
                            if ($btnRefresh) {
                                $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)) | out-null
                            }
                            return
                        }
                        catch {
                            "Run/Stop failed for $($Data.TaskPath)$($Data.TaskName): $($_.Exception.Message)"
                        }
                    }
                },
                @{
                    Name         = 'Enable / Disable'
                    Scope        = 'Row'
                    Icon         = '🔁'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        try {
                            if ([bool]$Data.Enabled) {
                                Disable-ScheduledTask -TaskName $Data.TaskName -TaskPath $Data.TaskPath -ErrorAction Stop
                            }
                            else {
                                Enable-ScheduledTask -TaskName $Data.TaskName -TaskPath $Data.TaskPath -ErrorAction Stop
                            }
                            Start-Sleep -Milliseconds 600
                            $btnRefresh = $Context.Window.FindName('btnRefresh')
                            if ($btnRefresh) {
                                $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)) | out-null
                            }
                            return
                        }
                        catch {
                            "Enable/Disable failed for $($Data.TaskPath)$($Data.TaskName): $($_.Exception.Message)"
                        }
                    }
                },
                @{
                    Name         = 'Search Google'
                    Scope        = 'DoubleClick'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)

                        try {
                            $query = "$($Data.TaskName) $($Data.TaskPath) scheduled task"
                            $encodedQuery = [System.Uri]::EscapeDataString($query)
                            $url = "https://www.google.com/search?q=$encodedQuery"
                            Start-Process $url
                        }
                        catch {
                            "Failed to search Google for $($Data.TaskName): $($_.Exception.Message)"
                        }
                    }
                }
            )
            
            if ($null -eq $Actions) {
                $Actions = $defaultTaskActions
            }
            else {
                $Actions = @($defaultTaskActions) + @($Actions)
            }
6. Initial Data
            if ($null -eq $inputData -or $inputData.Count -eq 0) {
                $inputData = & {
                    foreach ($key in $Configuration.Keys) {
                        Set-Variable -Name $key -Value $Configuration[$key] -Scope Local
                    }
                    & $RefreshScript
                }
            }
            
            if ($Title -eq 'Data Viewer') {
                $Title = 'Scheduled Task Operations Console'
            }
        }
endregion
region Json Explorer Mode
        if ($JsonExplorerMode) {
1. Configuration
            $defaultConfig = @{
                JsonPath        = ''
                CurrentPath     = '$'
                ShowCurrentOnly = $false
            }
            if ($null -eq $Configuration) {
                $Configuration = $defaultConfig
            }
            else {
                foreach ($key in $defaultConfig.Keys) {
                    if (-not $Configuration.ContainsKey($key)) {
                        $Configuration[$key] = $defaultConfig[$key]
                    }
                }
            }
2. Helpers & RefreshScript
            $sharedHelpers = {
                function ConvertTo-JsonLeafString {
                    param($Value)
                    if ($null -eq $Value) { return $null }
                    if ($Value -is [string] -or $Value -is [char]) { return [string]$Value }
                    if ($Value -is [bool] -or
                        $Value -is [byte] -or $Value -is [sbyte] -or
                        $Value -is [int16] -or $Value -is [int32] -or $Value -is [int64] -or
                        $Value -is [uint16] -or $Value -is [uint32] -or $Value -is [uint64] -or
                        $Value -is [single] -or $Value -is [double] -or $Value -is [decimal]) {
                        return [string]$Value
                    }
                    if ($Value -is [datetime]) { return $Value.ToString('o') }
                    return [string]$Value
                }

                function ConvertFrom-JsonEditedValue {
                    param(
                        [string]$Text,
                        [string]$NodeType
                    )
                    switch ($NodeType) {
                        'Null' { return $null }
                        'Boolean' {
                            $parsed = $false
                            if ([bool]::TryParse($Text, [ref]$parsed)) { return $parsed }
                            return $Text
                        }
                        'Number' {
                            if ($Text -match '^-?\d+$') { return [long]$Text }
                            $parsedDbl = 0.0
                            if ([double]::TryParse($Text, [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$parsedDbl)) { return $parsedDbl }
                            return $Text
                        }
                        default { return $Text }
                    }
                }

                function Get-JsonNodeByPath {
                    param($Root, $Path)
                    if ($Path -eq '$') { return $Root }
                    $current = $Root
                    $tokens = $Path.Substring(2).Split('/')
                    foreach ($token in $tokens) {
                        if ([string]::IsNullOrWhiteSpace($token)) { continue }
                        if ($token -match '^\[(\d+)\]$') {
                            $index = [int]$matches[1]
                            $current = @($current)[$index]
                        }
                        else {
                            $propertyName = $token.Replace('~1', '/').Replace('~0', '~')
                            $current = $current.PSObject.Properties[$propertyName].Value
                        }
                    }
                    return $current
                }

                function Set-JsonNodeByPath {
                    param($Root, $Path, $Value)
                    if ($Path -eq '$') { return $null }
                    $idx = $Path.LastIndexOf('/')
                    if ($idx -le 1) { return $null }
                    $parentPath = $Path.Substring(0, $idx)
                    $lastToken = $Path.Substring($idx + 1)
                    $parent = Get-JsonNodeByPath -Root $Root -Path $parentPath
                    if ($null -eq $parent) { return $null }

                    if ($lastToken -match '^\[(\d+)\]$') {
                        $index = [int]$matches[1]
                        $items = @($parent)
                        $items[$index] = $Value
                    }
                    else {
                        $propertyName = $lastToken.Replace('~1', '/').Replace('~0', '~')
                        $prop = $parent.PSObject.Properties[$propertyName]
                        if ($prop) { $prop.Value = $Value }
                        else { $parent | Add-Member -NotePropertyName $propertyName -NotePropertyValue $Value }
                    }
                }

                function Get-JsonRows {
                    param($Root, $CurrentPath = '$', [switch]$ShowCurrentOnly)

                    $rows = [System.Collections.Generic.List[PSCustomObject]]::new()
                    
                    if ($null -eq $Root) {
                        return $rows
                    }

                    $stack = [System.Collections.Generic.Stack[PSCustomObject]]::new()
                    $stack.Push([PSCustomObject]@{
                            Node  = $Root
                            Path  = '$'
                            Name  = 'root'
                            Depth = 0
                        })

                    while ($stack.Count -gt 0) {
                        $item = $stack.Pop()
                        $node = $item.Node
                        $path = $item.Path
                        $name = $item.Name
                        $depth = $item.Depth

                        $nodeType = 'Object'
                        $isContainer = $true
                        $childCount = 0
                        $valueStr = ''
                        $keys = @()

                        if ($null -eq $node) {
                            $nodeType = 'Null'
                            $isContainer = $false
                            $valueStr = 'null'
                        }
                        elseif ($node -is [string]) {
                            $nodeType = 'String'
                            $isContainer = $false
                            $valueStr = $node
                        }
                        elseif ($node -is [bool]) {
                            $nodeType = 'Boolean'
                            $isContainer = $false
                            $valueStr = if ($node) { 'true' } else { 'false' }
                        }
                        elseif ($node.GetType().IsPrimitive -or $node -is [decimal]) {
                            $nodeType = 'Number'
                            $isContainer = $false
                            $valueStr = [string]$node
                        }
                        elseif ($node -is [array]) {
                            $nodeType = 'Array'
                            $childCount = $node.Count
                            $valueStr = "[$childCount]"
                        }
                        else {
                            $nodeType = 'Object'
                            $keys = $node.PSObject.Properties | Where-Object { $_.MemberType -match 'NoteProperty' } | Select-Object -ExpandProperty Name
                            $childCount = $keys.Count
                            $valueStr = "{$childCount}"
                        }

                        $indent = '    ' * $depth
                        $icon = if ($isContainer) { if ($nodeType -eq 'Array') { '[]' } else { '{}' } } else { '└─' }
                        $treeLabel = "$indent$icon $name"
 
                        $include = $true
                        if ($ShowCurrentOnly) {
                            if ($path -eq $CurrentPath -or $path.StartsWith("$CurrentPath/")) {
                                $include = $true
                            }
                            else {
                                $include = $false
                            }
                        }

                        if ($include) {
                            $row = [PSCustomObject]@{
                                TreeLabel   = $treeLabel
                                Name        = $name
                                NodeType    = $nodeType
                                Value       = $valueStr
                                ChildCount  = if ($isContainer) { $childCount } else { $null }
                                Path        = $path
                                IsContainer = $isContainer
                                Depth       = $depth
                            }
                            $rows.Add($row)
                        }

                        if ($isContainer) {
                            if ($ShowCurrentOnly -and $path -ne $CurrentPath -and -not $path.StartsWith("$CurrentPath/")) {
                                continue
                            }

                            if ($nodeType -eq 'Array') {
                                for ($i = $node.Count - 1; $i -ge 0; $i--) {
                                    $childPath = "$path/[$i]"
                                    $stack.Push([PSCustomObject]@{
                                            Node  = $node[$i]
                                            Path  = $childPath
                                            Name  = "[$i]"
                                            Depth = $depth + 1
                                        })
                                }
                            }
                            else {
                                [array]::Reverse($keys)
                                foreach ($key in $keys) {
                                    $escapedKey = $key.Replace('~', '~0').Replace('/', '~1')
                                    $childPath = "$path/$escapedKey"
                                    $stack.Push([PSCustomObject]@{
                                            Node  = $node.PSObject.Properties[$key].Value
                                            Path  = $childPath
                                            Name  = $key
                                            Depth = $depth + 1
                                        })
                                }
                            }
                        }
                    }

                    return $rows
                }
            }

            $sharedCode = $sharedHelpers.ToString()

            if ($null -eq $RefreshScript) {
                $refreshScriptLiteral = {
                    if ([string]::IsNullOrWhiteSpace($CurrentPath)) {
                        $CurrentPath = '$'
                    }

                    if ([string]::IsNullOrWhiteSpace($JsonPath)) {
                        Write-Output ([PSCustomObject]@{ TreeLabel = '⚠️ No JSON File Opened. Use "Open File" action.'; NodeType = 'Info'; Value = ''; ChildCount = $null; Path = ''; IsContainer = $false; Depth = 0 })
                        return
                    }

                    if (-not (Test-Path -LiteralPath $JsonPath)) {
                        Write-Output ([PSCustomObject]@{ TreeLabel = "⚠️ JSON file not found: $JsonPath"; NodeType = 'Error'; Value = ''; ChildCount = $null; Path = ''; IsContainer = $false; Depth = 0 })
                        return
                    }

                    $raw = Get-Content -LiteralPath $JsonPath -Raw -Encoding UTF8
                    $root = $raw | ConvertFrom-Json

                    Get-JsonRows -Root $root -CurrentPath $CurrentPath -ShowCurrentOnly:$ShowCurrentOnly
                }
                $RefreshScript = [scriptblock]::Create($sharedCode + "`n" + $refreshScriptLiteral.ToString())
            }
3. Actions
            $defaultJsonActions = @(
                @{
                    Name         = 'Open File'
                    Scope        = 'Dataset'
                    Icon         = '📂'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        Add-Type -AssemblyName System.Windows.Forms
                        $dialog = New-Object System.Windows.Forms.OpenFileDialog
                        $dialog.Filter = 'JSON Files (*.json)|*.json|All Files (*.*)|*.*'
                        $dialog.Title = 'Open JSON File'
                        
                        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                            $Context.Configuration.JsonPath = $dialog.FileName
                            $Context.Configuration.CurrentPath = '$'
                            $btnRefresh = $Context.Window.FindName('btnRefresh')
                            if ($btnRefresh) {
                                $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                            }
                            return "Opened: $($dialog.FileName)"
                        }
                        return 'Open cancelled.'
                    }
                },
                @{
                    Name         = 'Open / Enter'
                    Scope        = 'DoubleClick'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        if ($Data.IsContainer) {
                            $Context.Configuration.CurrentPath = $Data.Path
                            $btnRefresh = $Context.Window.FindName('btnRefresh')
                            if ($btnRefresh) {
                                $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                            }
                        }
                    }
                },
                @{
                    Name         = 'Go Up'
                    Scope        = 'Dataset'
                    Icon         = '⬆️'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        $current = [string]$Context.Configuration.CurrentPath
                        if ($current -eq '$') { return 'Already at root.' }
                        $idx = $current.LastIndexOf('/')
                        $Context.Configuration.CurrentPath = if ($idx -le 1) { '$' } else { $current.Substring(0, $idx) }
                        $btnRefresh = $Context.Window.FindName('btnRefresh')
                        if ($btnRefresh) {
                            $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                        }
                    }
                },
                @{
                    Name         = 'Save'
                    Scope        = 'Dataset'
                    Icon         = '💾'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        $path = $Context.Configuration.JsonPath
                        if ([string]::IsNullOrWhiteSpace($path)) { return 'Cannot save: Configuration.JsonPath is empty.' }
                        if (-not (Test-Path -LiteralPath $path)) { return "Cannot save: JSON file was not found: $path" }

                        $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
                        $root = $raw | ConvertFrom-Json 

                        foreach ($row in @($Context.Data)) {
                            if ([string]::IsNullOrWhiteSpace($row.Path)) { continue }
                            if ($row.IsContainer) { continue }
                            $typedValue = ConvertFrom-JsonEditedValue -Text $row.Value -NodeType $row.NodeType
                            Set-JsonNodeByPath -Root $root -Path $row.Path -Value $typedValue
                        }

                        $root | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding UTF8
                        return "Saved changes to JSON file: $path"
                    }
                },
                @{
                    Name         = 'Add Property / Item'
                    Scope        = 'Row'
                    Icon         = '➕'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        Add-Type -AssemblyName Microsoft.VisualBasic

                        if (-not $Data.IsContainer) {
                            return "Select an Object or Array row first. '$($Data.Name)' is a $($Data.NodeType)."
                        }

                        $raw = Get-Content -Path $Context.Configuration.JsonPath -Raw -Encoding UTF8
                        $root = $raw | ConvertFrom-Json
                        $targetPath = $Data.Path
                        $target = Get-JsonNodeByPath -Root $root -Path $targetPath

                        if ($Data.NodeType -eq 'Array') {
                            $value = [Microsoft.VisualBasic.Interaction]::InputBox("New value for array '$($Data.Name)':", 'Add JSON Array Item', '')
                            $updatedArray = @($target) + $value
                            Set-JsonNodeByPath -Root $root -Path $targetPath -Value $updatedArray
                            $message = "Added an item to array '$targetPath'."
                        }
                        else {
                            $name = [Microsoft.VisualBasic.Interaction]::InputBox("New property name in '$($Data.Name)':", 'Add JSON Property', 'NewProperty')
                            if ([string]::IsNullOrWhiteSpace($name)) { return 'No property name was entered.' }
                            $value = [Microsoft.VisualBasic.Interaction]::InputBox("Value for '$name':", 'Add JSON Property', '')
                            $target | Add-Member -NotePropertyName $name -NotePropertyValue $value -Force
                            $message = "Added property '$name' to '$targetPath'."
                        }

                        $root | ConvertTo-Json -Depth 100 | Set-Content -Path $Context.Configuration.JsonPath -Encoding UTF8
                        $refreshButton = $Context.Window.FindName('btnRefresh')
                        if ($null -ne $refreshButton) { $refreshButton.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)) }
                        return $message
                    }
                },
                @{
                    Name         = 'Delete Node'
                    Scope        = 'Row'
                    Icon         = '🗑'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        if ($Data.Path -eq '$') { return 'The root JSON node cannot be deleted.' }

                        $answer = [System.Windows.MessageBox]::Show("Delete '$($Data.Name)' at path:`n$($Data.Path) ?", 'Confirm JSON deletion', [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
                        if ($answer -ne [System.Windows.MessageBoxResult]::Yes) { return 'Delete cancelled.' }

                        $path = $Data.Path
                        $tokens = @($path.Substring(2).Split('/'))
                        $lastToken = [string]$tokens[-1]
                        $parentPath = if ($tokens.Count -eq 1) { '$' } else { '$/' + ($tokens[0..($tokens.Count - 2)] -join '/') }

                        $raw = Get-Content -LiteralPath $Context.Configuration.JsonPath -Raw -Encoding UTF8
                        $root = $raw | ConvertFrom-Json
                        $parent = Get-JsonNodeByPath -Root $root -Path $parentPath

                        if ($lastToken -match '^\[(\d+)\]$') {
                            $index = [int]$matches[1]
                            $items = @($parent)
                            if ($index -lt 0 -or $index -ge $items.Count) { throw "Array index $index does not exist at '$parentPath'." }
                            
                            $newArray = @(
                                for ($i = 0; $i -lt $items.Count; $i++) {
                                    if ($i -ne $index) { $items[$i] }
                                }
                            )

                            $parentTokens = @($parentPath.Substring(2).Split('/'))
                            $arrayName = [string]$parentTokens[-1]

                            if ($parentTokens.Count -eq 1) { $arrayOwner = $root }
                            else {
                                $arrayOwnerPath = '$/' + ($parentTokens[0..($parentTokens.Count - 2)] -join '/')
                                $arrayOwner = Get-JsonNodeByPath -Root $root -Path $arrayOwnerPath
                            }

                            $arrayName = $arrayName.Replace('~1', '/').Replace('~0', '~')
                            $arrayOwner.PSObject.Properties[$arrayName].Value = $newArray
                            $message = "Deleted array item [$index] from '$parentPath'."
                        }
                        else {
                            $propertyName = $lastToken.Replace('~1', '/').Replace('~0', '~')
                            $property = $parent.PSObject.Properties[$propertyName]
                            if ($null -eq $property) { throw "Property '$propertyName' was not found at '$parentPath'." }
                            [void]$parent.PSObject.Properties.Remove($propertyName)
                            $message = "Deleted property '$propertyName' from '$parentPath'."
                        }

                        $root | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Context.Configuration.JsonPath -Encoding UTF8
                        $btnRefresh = $Context.Window.FindName('btnRefresh')
                        if ($btnRefresh) { $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)) }
                        return $message
                    }
                },
                @{
                    Name         = 'Copy Path'
                    Scope        = 'Row'
                    Icon         = '📋'
                    ReturnToGrid = $false
                    Script       = {
                        param($Data, $Context)
                        Set-Clipboard -Value $Data.Path
                        return "Copied to clipboard: $($Data.Path)"
                    }
                },
                @{
                    Name         = 'Rename Property'
                    Scope        = 'Row'
                    Icon         = '✏️'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        Add-Type -AssemblyName Microsoft.VisualBasic
                        
                        if ($Data.Path -eq '$') { return 'Cannot rename root node.' }
                        
                        $path = $Data.Path
                        $tokens = @($path.Substring(2).Split('/'))
                        $lastToken = [string]$tokens[-1]
                        
                        if ($lastToken -match '^\[(\d+)\]$') { return 'Cannot rename an array item. Rename is for object properties.' }
                        
                        $oldName = $lastToken.Replace('~1', '/').Replace('~0', '~')
                        $newName = [Microsoft.VisualBasic.Interaction]::InputBox("Rename property '$oldName' to:", 'Rename JSON Property', $oldName)
                        if ([string]::IsNullOrWhiteSpace($newName) -or $newName -eq $oldName) { return 'Rename cancelled.' }
                        
                        $parentPath = if ($tokens.Count -eq 1) { '$' } else { '$/' + ($tokens[0..($tokens.Count - 2)] -join '/') }
                        
                        $raw = Get-Content -LiteralPath $Context.Configuration.JsonPath -Raw -Encoding UTF8
                        $root = $raw | ConvertFrom-Json
                        $parent = Get-JsonNodeByPath -Root $root -Path $parentPath
                        
                        if ($null -ne $parent.PSObject.Properties[$newName]) { return "Property '$newName' already exists." }
                        
                        $value = $parent.PSObject.Properties[$oldName].Value
                        [void]$parent.PSObject.Properties.Remove($oldName)
                        $parent | Add-Member -NotePropertyName $newName -NotePropertyValue $value -Force
                        
                        $root | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Context.Configuration.JsonPath -Encoding UTF8
                        $btnRefresh = $Context.Window.FindName('btnRefresh')
                        if ($btnRefresh) { $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)) }
                        
                        return "Renamed '$oldName' to '$newName'."
                    }
                },
                @{
                    Name         = 'Clone Node'
                    Scope        = 'Row'
                    Icon         = '🐑'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        if ($Data.Path -eq '$') { return 'Cannot clone the root node.' }
                        
                        $path = $Data.Path
                        $tokens = @($path.Substring(2).Split('/'))
                        $lastToken = [string]$tokens[-1]
                        $parentPath = if ($tokens.Count -eq 1) { '$' } else { '$/' + ($tokens[0..($tokens.Count - 2)] -join '/') }
                        
                        $raw = Get-Content -LiteralPath $Context.Configuration.JsonPath -Raw -Encoding UTF8
                        $root = $raw | ConvertFrom-Json
                        $parent = Get-JsonNodeByPath -Root $root -Path $parentPath
                        
                        if ($lastToken -match '^\[(\d+)\]$') {
                            $index = [int]$matches[1]
                            $items = @($parent)
                            $target = $items[$index]
                            
                            $copy = $target | ConvertTo-Json -Depth 100 | ConvertFrom-Json
                            $updatedArray = @($parent) + @($copy)
                            
                            $parentTokens = @($parentPath.Substring(2).Split('/'))
                            $arrayName = [string]$parentTokens[-1]
                            
                            if ($parentTokens.Count -eq 1) { $arrayOwner = $root }
                            else {
                                $arrayOwnerPath = '$/' + ($parentTokens[0..($parentTokens.Count - 2)] -join '/')
                                $arrayOwner = Get-JsonNodeByPath -Root $root -Path $arrayOwnerPath
                            }
                            $arrayName = $arrayName.Replace('~1', '/').Replace('~0', '~')
                            $arrayOwner.PSObject.Properties[$arrayName].Value = $updatedArray
                            
                            $message = "Cloned array item."
                        }
                        else {
                            $oldName = $lastToken.Replace('~1', '/').Replace('~0', '~')
                            $target = $parent.PSObject.Properties[$oldName].Value
                            $newName = "${oldName}_copy"
                            $counter = 1
                            while ($null -ne $parent.PSObject.Properties[$newName]) {
                                $newName = "${oldName}_copy_$counter"
                                $counter++
                            }
                            
                            $copy = $target | ConvertTo-Json -Depth 100 | ConvertFrom-Json
                            $parent | Add-Member -NotePropertyName $newName -NotePropertyValue $copy -Force
                            $message = "Cloned property as '$newName'."
                        }
                        
                        $root | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Context.Configuration.JsonPath -Encoding UTF8
                        $btnRefresh = $Context.Window.FindName('btnRefresh')
                        if ($btnRefresh) { $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)) }
                        
                        return $message
                    }
                },
                @{
                    Name         = 'Toggle Scope'
                    Scope        = 'Dataset'
                    Icon         = '🌳'
                    ReturnToGrid = $true
                    Script       = {
                        param($Data, $Context)
                        $Context.Configuration.ShowCurrentOnly = -not [bool]$Context.Configuration.ShowCurrentOnly
                        return "ShowCurrentOnly = $($Context.Configuration.ShowCurrentOnly)"
                    }
                }
            )
Compile actions with shared code
            foreach ($action in $defaultJsonActions) {
                if ($action.Script) {
                    $orig = $action.Script.ToString()
                    $newCode = $orig.Replace('param($Data, $Context)', "param(`$Data, `$Context)`n$sharedCode")
                    $action.Script = [scriptblock]::Create($newCode)
                }
            }

            if ($null -eq $Actions) {
                $Actions = $defaultJsonActions
            }
            else {
                $Actions = @($defaultJsonActions) + @($Actions)
            }
4. Overrides
            if ($null -eq $Columns -or $Columns.Count -eq 0) {
                $Columns = @('TreeLabel', 'NodeType', 'Value', 'ChildCount', 'Path')
            }
            $AllowEdit = $true
            if ($Title -eq 'Data Viewer') {
                $Title = 'JSON Explorer Editor'
            }
5. Initial Data
            if ($null -eq $inputData -or $inputData.Count -eq 0) {
                $inputData = & {
                    foreach ($key in $Configuration.Keys) {
                        Set-Variable -Name $key -Value $Configuration[$key] -Scope Local
                    }
                    & $RefreshScript
                }
            }
        }
endregion
endregion
requires -Version 5.1
        Add-Type -AssemblyName PresentationFramework
        Add-Type -AssemblyName PresentationCore
        Add-Type -AssemblyName WindowsBase
        Add-Type -AssemblyName System.Windows.Forms

        $screenH = [System.Windows.SystemParameters]::PrimaryScreenHeight * 0.9
        $screenW = [System.Windows.SystemParameters]::PrimaryScreenWidth * 0.9
region XAML
        [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:primitives="clr-namespace:System.Windows.Controls.Primitives;assembly=PresentationFramework"
        Title="$Title" Height="$screenH" Width="$screenW"
        WindowStartupLocation="CenterScreen"
        Background="{DynamicResource BgApp}" Foreground="{DynamicResource TextPrimary}"
        FontFamily="Segoe UI" FontSize="13">

    <Window.Resources>
        <SolidColorBrush x:Key="BgApp" Color="#F3F5F7"/>
        <SolidColorBrush x:Key="BgPanel" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="BgSubtle" Color="#F8FAFC"/>
        <SolidColorBrush x:Key="BgControl" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="BgControlHover" Color="#EEF2F7"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#111827"/>
        <SolidColorBrush x:Key="TextMuted" Color="#6B7280"/>
        <SolidColorBrush x:Key="StrokeSoft" Color="#E5E7EB"/>
        <SolidColorBrush x:Key="StrokeMid" Color="#D1D5DB"/>
        <SolidColorBrush x:Key="Accent" Color="#0F766E"/>
        <SolidColorBrush x:Key="AccentHover" Color="#0D655F"/>
        <SolidColorBrush x:Key="AccentSoft" Color="#DFF3F1"/>

        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
        </Style>

        <Style x:Key="LabelStyle" TargetType="TextBlock">
            <Setter Property="FontSize" Value="10"/>
            <Setter Property="Foreground" Value="{DynamicResource TextMuted}"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Margin" Value="0,0,0,4"/>
        </Style>

        <Style TargetType="TextBox">
            <Setter Property="Padding" Value="8,5"/>
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>

        <Style TargetType="ComboBox">
            <Setter Property="Padding" Value="6,4"/>
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <ToggleButton x:Name="ToggleButton" Focusable="false" IsChecked="{Binding IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}" ClickMode="Press"
                                          Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Foreground="{TemplateBinding Foreground}">
                                <ToggleButton.Template>
                                    <ControlTemplate TargetType="ToggleButton">
                                        <Border CornerRadius="3" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*" />
                                                    <ColumnDefinition Width="24" />
                                                </Grid.ColumnDefinitions>
                                                <Border Grid.Column="1" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="1,0,0,0" Background="Transparent">
                                                    <Path x:Name="Arrow" Fill="{TemplateBinding Foreground}" HorizontalAlignment="Center" VerticalAlignment="Center" Data="M 0 0 L 4 4 L 8 0 Z"/>
                                                </Border>
                                            </Grid>
                                        </Border>
                                    </ControlTemplate>
                                </ToggleButton.Template>
                            </ToggleButton>
                            <ContentPresenter x:Name="ContentSite" IsHitTestVisible="False" Content="{TemplateBinding SelectionBoxItem}" ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}" ContentTemplateSelector="{TemplateBinding ItemTemplateSelector}" Margin="8,4,28,4" VerticalAlignment="Center" HorizontalAlignment="Left" />
                            <Popup x:Name="Popup" Placement="Bottom" IsOpen="{TemplateBinding IsDropDownOpen}" AllowsTransparency="True" Focusable="False" PopupAnimation="Slide">
                                <Grid x:Name="DropDown" SnapsToDevicePixels="True" MinWidth="{TemplateBinding ActualWidth}" MaxHeight="{TemplateBinding MaxDropDownHeight}">
                                    <Border x:Name="DropDownBorder" CornerRadius="3" Background="{DynamicResource BgPanel}" BorderThickness="1" BorderBrush="{DynamicResource StrokeMid}">
                                        <ScrollViewer Margin="1" SnapsToDevicePixels="True">
                                            <ItemsPresenter KeyboardNavigation.DirectionalNavigation="Contained" />
                                        </ScrollViewer>
                                    </Border>
                                </Grid>
                            </Popup>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Setter Property="ItemContainerStyle">
                <Setter.Value>
                    <Style TargetType="ComboBoxItem">
                        <Setter Property="Background" Value="{DynamicResource BgControl}"/>
                        <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="ComboBoxItem">
                                    <Border x:Name="Bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Padding="4,2">
                                        <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsSelected" Value="True">
                                            <Setter TargetName="Bd" Property="Background" Value="#0F766E"/>
                                            <Setter Property="Foreground" Value="White"/>
                                        </Trigger>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter TargetName="Bd" Property="Background" Value="#0F766E"/>
                                            <Setter Property="Foreground" Value="White"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="DatePicker">
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CalendarStyle">
                <Setter.Value>
                    <Style TargetType="Calendar">
                        <Setter Property="Background" Value="{DynamicResource BgPanel}"/>
                        <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
                        <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
                        <Setter Property="BorderThickness" Value="1"/>
                    </Style>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="{x:Type primitives:DatePickerTextBox}">
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="4,2"/>
        </Style>

        <Style TargetType="CalendarItem">
            <Setter Property="Background" Value="{DynamicResource BgPanel}"/>
        </Style>

        <Style TargetType="CalendarDayButton">
            <Setter Property="Background" Value="{DynamicResource BgPanel}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
        </Style>

        <Style TargetType="CalendarButton">
            <Setter Property="Background" Value="{DynamicResource BgPanel}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
        </Style>

        <Style TargetType="ListBox">
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="ItemContainerStyle">
                <Setter.Value>
                    <Style TargetType="ListBoxItem">
                        <Setter Property="Background" Value="{DynamicResource BgControl}"/>
                        <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="ListBoxItem">
                                    <Border x:Name="Bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Padding="4,2">
                                        <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsSelected" Value="True">
                                            <Setter TargetName="Bd" Property="Background" Value="#0F766E"/>
                                            <Setter Property="Foreground" Value="White"/>
                                        </Trigger>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter TargetName="Bd" Property="Background" Value="#0F766E"/>
                                            <Setter Property="Foreground" Value="White"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="Margin" Value="0,6,0,0"/>
        </Style>

        <Style x:Key="ModernButton" TargetType="Button">
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,7"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="BtnBorder"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="7"
                                SnapsToDevicePixels="True">
                            <ContentPresenter HorizontalAlignment="Center"
                                              VerticalAlignment="Center"
                                              Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="BtnBorder" Property="Background" Value="{DynamicResource BgControlHover}"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="BtnBorder" Property="Opacity" Value="0.92"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="BtnBorder" Property="Opacity" Value="0.55"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="PrimaryButton" TargetType="Button" BasedOn="{StaticResource ModernButton}">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Background" Value="{DynamicResource Accent}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource Accent}"/>
        </Style>

        <Style TargetType="Button" BasedOn="{StaticResource ModernButton}"/>

        <Style TargetType="TabControl">
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Background" Value="{DynamicResource BgApp}"/>
        </Style>

        <Style TargetType="TabItem">
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Background" Value="{DynamicResource BgSubtle}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextMuted}"/>
            <Setter Property="BorderThickness" Value="1,1,1,0"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeSoft}"/>
            <Setter Property="Margin" Value="0,0,2,0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border x:Name="Bd"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                Margin="{TemplateBinding Margin}"
                                Padding="{TemplateBinding Padding}"
                                SnapsToDevicePixels="True">
                            <ContentPresenter x:Name="ContentSite"
                                              VerticalAlignment="Center"
                                              HorizontalAlignment="Center"
                                              ContentSource="Header"
                                              RecognizesAccessKey="True"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{DynamicResource BgPanel}"/>
                                <Setter TargetName="Bd" Property="BorderThickness" Value="1,1,1,0"/>
                                <Setter TargetName="Bd" Property="Margin" Value="0,-2,2,0"/>
                                <Setter TargetName="Bd" Property="Padding" Value="14,10"/>
                                <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="DataGrid">
            <Setter Property="AlternatingRowBackground" Value="{DynamicResource BgSubtle}"/>
            <Setter Property="Background" Value="{DynamicResource BgPanel}"/>
            <Setter Property="RowBackground" Value="{DynamicResource BgPanel}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="GridLinesVisibility" Value="Horizontal"/>
            <Setter Property="HorizontalGridLinesBrush" Value="{DynamicResource StrokeSoft}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeSoft}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="HeadersVisibility" Value="Column"/>
            <Setter Property="ColumnHeaderHeight" Value="34"/>
            <Setter Property="RowHeight" Value="28"/>
        </Style>
        <Style TargetType="DataGridColumnHeader">
            <Setter Property="Background" Value="{DynamicResource BgSubtle}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="Padding" Value="8,0"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeSoft}"/>
            <Setter Property="BorderThickness" Value="0,0,1,1"/>
        </Style>

        <Style TargetType="DataGridRow">
            <Setter Property="Background" Value="{DynamicResource BgPanel}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="60"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header Bar -->
        <Border Grid.Row="0" Background="{DynamicResource BgPanel}" BorderBrush="{DynamicResource StrokeSoft}" BorderThickness="0,0,0,1">
            <Grid Margin="18,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <Border Width="30" Height="30" CornerRadius="8" Background="{DynamicResource Accent}" Margin="0,0,10,0">
                        <TextBlock Text="&#x1F50D;" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="14"/>
                    </Border>
                    <TextBlock x:Name="txtTitle" Text="$Title" FontSize="17" FontWeight="SemiBold" VerticalAlignment="Center"/>
                </StackPanel>

                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                    <Button x:Name="btnRefresh" Style="{DynamicResource PrimaryButton}" Margin="0,0,4,0">Refresh Data</Button>
                    <ComboBox x:Name="cmbAutoRefresh" Width="60" Margin="0,0,8,0" SelectedIndex="0" ToolTip="Auto-Refresh Interval">
                        <ComboBoxItem>Off</ComboBoxItem>
                        <ComboBoxItem>5s</ComboBoxItem>
                        <ComboBoxItem>30s</ComboBoxItem>
                        <ComboBoxItem>1m</ComboBoxItem>
                    </ComboBox>
                    <Button x:Name="btnColumns" Margin="0,0,8,0">Columns</Button>
                    <Button x:Name="btnConfig" Margin="0,0,8,0" Visibility="Collapsed">Configuration</Button>
                    <Button x:Name="btnExportRows" Margin="0,0,6,0">Export Rows</Button>
                    <Button x:Name="btnExportPivot" Margin="0,0,8,0">Export Pivot</Button>
                    <Border x:Name="sepDatasetActions" Width="1" Background="{DynamicResource StrokeMid}" Margin="6,8" Visibility="Collapsed"/>
                    <StackPanel x:Name="pnlDatasetActions" Orientation="Horizontal" Visibility="Collapsed"/>
                    <Button x:Name="btnTheme">🌙 Dark Mode</Button>
                </StackPanel>
            </Grid>
        </Border>

        <!-- Filter Bar -->
        <Border x:Name="pnlFilterBar" Grid.Row="1" Background="{DynamicResource BgSubtle}" BorderBrush="{DynamicResource StrokeSoft}" BorderThickness="0,0,0,1" Padding="16,10">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Grid Grid.Row="0" Margin="0,0,0,8">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Text="Filters" FontSize="12" FontWeight="SemiBold" VerticalAlignment="Center" Foreground="{DynamicResource TextMuted}" Margin="0,0,16,0"/>
                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="Search (Regex):" VerticalAlignment="Center" Margin="0,0,6,0" FontSize="11" Foreground="{DynamicResource TextMuted}" FontWeight="SemiBold"/>
                        <TextBox x:Name="txtSearchAll" Width="200" Padding="4,3" FontSize="11"/>
                    </StackPanel>
                    <StackPanel Grid.Column="3" Orientation="Horizontal" Margin="0,0,8,0" VerticalAlignment="Center">
                        <TextBlock Text="Top N:" VerticalAlignment="Center" Margin="0,0,4,0" FontSize="11" Foreground="{DynamicResource TextMuted}"/>
                        <TextBox x:Name="txtTopN" Width="50" Text="10" Padding="4,3" FontSize="11"/>
                    </StackPanel>
                    <StackPanel Grid.Column="4" Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="Quick Views:" VerticalAlignment="Center" Margin="0,0,6,0" FontSize="11" Foreground="{DynamicResource TextMuted}" FontWeight="SemiBold"/>
                        <ComboBox x:Name="cmbSavedViews" Width="140" Margin="0,0,8,0" ToolTip="Saved filter views"/>
                        <Button x:Name="btnSaveView" Margin="0,0,8,0" Padding="10,6">Save View</Button>
                        <Button x:Name="btnLoadView" Margin="0,0,8,0" Padding="10,6">Load View</Button>
                        <Button x:Name="btnReset" Margin="0,0,8,0" Padding="10,6">Reset Filters</Button>
                        <Button x:Name="btnToggleFilterPanel" Padding="10,6">Hide Filters</Button>
                    </StackPanel>
                </Grid>

                <WrapPanel x:Name="pnlFilterContent" Grid.Row="1"/>
            </Grid>
        </Border>

        <!-- Main Content -->
        <TabControl Grid.Row="2">
            <!-- Events / Data Tab -->
            <TabItem Header="Data View">
                <Grid Margin="12">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="6"/>
                        <ColumnDefinition Width="270"/>
                    </Grid.ColumnDefinitions>

                    <Grid Grid.Column="0">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*" MinHeight="70"/>
                            <RowDefinition Height="6"/>
                            <RowDefinition Height="170" MinHeight="70"/>
                        </Grid.RowDefinitions>

                        <Grid Grid.Row="0">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            <DataGrid x:Name="dgData" Grid.Row="0"
                                      AutoGenerateColumns="False" IsReadOnly="True" CanUserAddRows="False"
                                      SelectionMode="Single" SelectionUnit="FullRow"
                                      CanUserSortColumns="True" CanUserReorderColumns="True"
                                      EnableRowVirtualization="True" EnableColumnVirtualization="True"
                                      VirtualizingStackPanel.IsVirtualizing="True"
                                      VirtualizingStackPanel.VirtualizationMode="Recycling"
                                      ScrollViewer.IsDeferredScrollingEnabled="True"
                                      ScrollViewer.VerticalScrollBarVisibility="Visible"
                                      ScrollViewer.HorizontalScrollBarVisibility="Auto"/>

                            <Border x:Name="pnlFooter" Grid.Row="1" Background="{DynamicResource BgSubtle}" BorderBrush="{DynamicResource StrokeSoft}" BorderThickness="0,1,0,0" Padding="8,4" Visibility="Collapsed">
                                <TextBlock x:Name="txtFooterSummary" FontWeight="SemiBold" FontSize="11" Foreground="{DynamicResource TextPrimary}" TextWrapping="Wrap"/>
                            </Border>

                            <TextBlock x:Name="txtEmptyState" Grid.Row="0" Grid.RowSpan="2"
                                       Text="No data loaded. Pass data via -Data parameter or click Refresh."
                                       Margin="24" Padding="14,10"
                                       Background="#F9FAFB"
                                       Foreground="{DynamicResource TextMuted}"
                                       FontStyle="Italic"
                                       TextAlignment="Center"
                                       VerticalAlignment="Center"
                                       Visibility="Collapsed"/>
                        </Grid>

                        <GridSplitter Grid.Row="1" Height="6" HorizontalAlignment="Stretch" VerticalAlignment="Center"
                                      Background="{DynamicResource StrokeSoft}" ResizeDirection="Rows" ResizeBehavior="PreviousAndNext"/>

                        <Grid Grid.Row="2">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>

                            <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,8">
                                <Button x:Name="btnCopyRow" Margin="0,0,8,0">Copy Row</Button>
                                <Button x:Name="btnCopyDetails" Margin="0,0,4,0">Copy Details</Button>
                                <Border x:Name="sepRowActions" Width="1" Background="{DynamicResource StrokeMid}" Margin="8,2" Visibility="Collapsed"/>
                                <StackPanel x:Name="pnlRowActions" Orientation="Horizontal" Visibility="Collapsed"/>
                            </StackPanel>

                            <TextBox x:Name="txtDetail" Grid.Row="1" IsReadOnly="True" TextWrapping="Wrap"
                                     VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto"
                                     Background="{DynamicResource BgSubtle}"
                                     BorderBrush="{DynamicResource StrokeSoft}" BorderThickness="1" Padding="10"
                                     FontFamily="Consolas" FontSize="12"
                                     Text="Select a row to view full details."/>
                        </Grid>
                    </Grid>

                    <GridSplitter Grid.Column="1" Width="6" HorizontalAlignment="Stretch" Background="{DynamicResource StrokeSoft}"/>

                    <!-- Group By Panel -->
                    <Border Grid.Column="2" Background="{DynamicResource BgSubtle}" BorderBrush="{DynamicResource StrokeSoft}" BorderThickness="1">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel x:Name="pnlGroupBy" Margin="12"/>
                        </ScrollViewer>
                    </Border>
                </Grid>
            </TabItem>

            <!-- Pivot Tab -->
            <TabItem Header="Pivot Analysis">
                <Grid Margin="12">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="300"/>
                        <ColumnDefinition Width="6"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <Border Grid.Column="0" Background="{DynamicResource BgSubtle}" BorderBrush="{DynamicResource StrokeSoft}" BorderThickness="1" Padding="12">
                        <StackPanel>
                            <TextBlock Text="Pivot Fields" FontSize="14" FontWeight="SemiBold" Margin="0,0,0,10"/>
                            <TextBlock Text="AVAILABLE FIELDS" Style="{DynamicResource LabelStyle}"/>
                            <ListBox x:Name="lbAvailableFields" Height="130"/>
                            <WrapPanel Margin="0,7,0,10">
                                <Button x:Name="btnAddRowField" Margin="0,0,6,0" Padding="10,6">To Rows</Button>
                                <Button x:Name="btnAddColumnField" Margin="0,0,6,0" Padding="10,6">To Columns</Button>
                                <Button x:Name="btnClearPivotFields" Padding="10,6">Clear</Button>
                            </WrapPanel>

                            <TextBlock Text="ROW FIELDS" Style="{DynamicResource LabelStyle}"/>
                            <ListBox x:Name="lbRowFields" Height="90"/>
                            <WrapPanel Margin="0,5,0,10">
                                <Button x:Name="btnRemoveRowField" Margin="0,0,6,0" Padding="8,5">Remove</Button>
                                <Button x:Name="btnMoveRowUp" Margin="0,0,6,0" Padding="8,5">Up</Button>
                                <Button x:Name="btnMoveRowDown" Padding="8,5">Down</Button>
                            </WrapPanel>

                            <TextBlock Text="COLUMN FIELDS" Style="{DynamicResource LabelStyle}"/>
                            <ListBox x:Name="lbColumnFields" Height="90"/>
                            <WrapPanel Margin="0,5,0,10">
                                <Button x:Name="btnRemoveColumnField" Margin="0,0,6,0" Padding="8,5">Remove</Button>
                                <Button x:Name="btnMoveColumnUp" Margin="0,0,6,0" Padding="8,5">Up</Button>
                                <Button x:Name="btnMoveColumnDown" Padding="8,5">Down</Button>
                            </WrapPanel>

                            <CheckBox x:Name="chkShowTotals" IsChecked="True" Content="Show totals" Margin="0,0,0,10"/>
                            <Button x:Name="btnApplyPivot" Style="{DynamicResource PrimaryButton}" Padding="12,8">Apply Pivot</Button>
                        </StackPanel>
                    </Border>

                    <GridSplitter Grid.Column="1" Width="6" HorizontalAlignment="Stretch" Background="{DynamicResource StrokeSoft}"/>

                    <DataGrid x:Name="dgPivot" Grid.Column="2"
                              AutoGenerateColumns="True" IsReadOnly="True" CanUserAddRows="False"/>
                </Grid>
            </TabItem>

            <!-- Charts Tab -->
            <TabItem Header="Charts">
                <Grid Margin="12">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="220"/>
                        <ColumnDefinition Width="6"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <Border Grid.Column="0" Background="{DynamicResource BgSubtle}" BorderBrush="{DynamicResource StrokeSoft}" BorderThickness="1" Padding="12">
                        <StackPanel>
                            <TextBlock Text="Chart Settings" FontSize="14" FontWeight="SemiBold" Margin="0,0,0,12"/>
                            <TextBlock Text="FIELD" Style="{DynamicResource LabelStyle}"/>
                            <ComboBox x:Name="cmbChartField" Margin="0,0,0,10"/>
                            <TextBlock Text="CHART TYPE" Style="{DynamicResource LabelStyle}"/>
                            <ComboBox x:Name="cmbChartType" Margin="0,0,0,10"/>
                            <TextBlock Text="TOP N VALUES" Style="{DynamicResource LabelStyle}"/>
                            <TextBox x:Name="txtChartTopN" Text="15" Margin="0,0,0,14"/>
                            <CheckBox x:Name="chkChartShowOther" Content="Group remaining as 'Other'" IsChecked="True" Margin="0,0,0,14"/>
                            <Button x:Name="btnRefreshChart" Style="{DynamicResource PrimaryButton}" Padding="12,8" Margin="0,0,0,8">Refresh Chart</Button>
                            <Button x:Name="btnExportChart" Padding="12,8">Export to PNG</Button>
                        </StackPanel>
                    </Border>

                    <GridSplitter Grid.Column="1" Width="6" HorizontalAlignment="Stretch" Background="{DynamicResource StrokeSoft}"/>

                    <Border Grid.Column="2" Background="{DynamicResource BgApp}" BorderBrush="{DynamicResource StrokeSoft}" BorderThickness="1">
                        <ScrollViewer HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto">
                            <Canvas x:Name="canvasChart" Background="Transparent" MinHeight="400"/>
                        </ScrollViewer>
                    </Border>
                </Grid>
            </TabItem>
        </TabControl>

        <!-- Status Bar -->
        <Border Grid.Row="3" Background="{DynamicResource BgPanel}" BorderBrush="{DynamicResource StrokeSoft}" BorderThickness="0,1,0,0">
            <StackPanel>
                <ProgressBar x:Name="pbLoading" Height="3" IsIndeterminate="True" Visibility="Collapsed"
                             Foreground="{DynamicResource Accent}" Background="{DynamicResource AccentSoft}" BorderThickness="0"/>

                <Grid Margin="16,6">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock x:Name="lblStatus" Foreground="{DynamicResource TextMuted}" FontSize="11" Text="Ready."/>
                    <TextBlock x:Name="lblCount" Grid.Column="1" Foreground="{DynamicResource Accent}" FontSize="11" FontWeight="SemiBold" Text="0 items"/>
                </Grid>
            </StackPanel>
        </Border>
    </Grid>
</Window>
"@
endregion
region UI Initialization
        $reader = [System.Xml.XmlNodeReader]::new($xaml)
        $window = [Windows.Markup.XamlReader]::Load($reader)
Find named elements
        $txtTitleCtrl = $window.FindName('txtTitle')
        $btnRefresh = $window.FindName('btnRefresh')
        $cmbAutoRefresh = $window.FindName('cmbAutoRefresh')
        $btnColumns = $window.FindName('btnColumns')
        $btnConfig = $window.FindName('btnConfig')
        $btnExportRows = $window.FindName('btnExportRows')
        $btnExportPivot = $window.FindName('btnExportPivot')
        $btnTheme = $window.FindName('btnTheme')
        $btnToggleFilterPanel = $window.FindName('btnToggleFilterPanel')
        $btnReset = $window.FindName('btnReset')
        $btnSaveView = $window.FindName('btnSaveView')
        $btnLoadView = $window.FindName('btnLoadView')
        $cmbSavedViews = $window.FindName('cmbSavedViews')
        $txtTopN = $window.FindName('txtTopN')
        $txtSearchAll = $window.FindName('txtSearchAll')
        $pnlFilterContent = $window.FindName('pnlFilterContent')
        $dgData = $window.FindName('dgData')
        $txtEmptyState = $window.FindName('txtEmptyState')
        $txtDetail = $window.FindName('txtDetail')
        $btnCopyRow = $window.FindName('btnCopyRow')
        $btnCopyDetails = $window.FindName('btnCopyDetails')
        $pnlGroupBy = $window.FindName('pnlGroupBy')
        $lbAvailableFields = $window.FindName('lbAvailableFields')
        $lbRowFields = $window.FindName('lbRowFields')
        $lbColumnFields = $window.FindName('lbColumnFields')
        $btnAddRowField = $window.FindName('btnAddRowField')
        $btnAddColumnField = $window.FindName('btnAddColumnField')
        $btnClearPivotFields = $window.FindName('btnClearPivotFields')
        $btnRemoveRowField = $window.FindName('btnRemoveRowField')
        $btnMoveRowUp = $window.FindName('btnMoveRowUp')
        $btnMoveRowDown = $window.FindName('btnMoveRowDown')
        $btnRemoveColumnField = $window.FindName('btnRemoveColumnField')
        $btnMoveColumnUp = $window.FindName('btnMoveColumnUp')
        $btnMoveColumnDown = $window.FindName('btnMoveColumnDown')
        $chkShowTotals = $window.FindName('chkShowTotals')
        $btnApplyPivot = $window.FindName('btnApplyPivot')
        $dgPivot = $window.FindName('dgPivot')
        $lblStatus = $window.FindName('lblStatus')
        $lblCount = $window.FindName('lblCount')
        $pbLoading = $window.FindName('pbLoading')
        $cmbChartField = $window.FindName('cmbChartField')
        $cmbChartType = $window.FindName('cmbChartType')
        $txtChartTopN = $window.FindName('txtChartTopN')
        $chkChartShowOther = $window.FindName('chkChartShowOther')
        $btnRefreshChart = $window.FindName('btnRefreshChart')
        $btnExportChart = $window.FindName('btnExportChart')
        $canvasChart = $window.FindName('canvasChart')
        $pnlFooter = $window.FindName('pnlFooter')
        $txtFooterSummary = $window.FindName('txtFooterSummary')
        $sepRowActions = $window.FindName('sepRowActions')
        $pnlRowActions = $window.FindName('pnlRowActions')
        $sepDatasetActions = $window.FindName('sepDatasetActions')
        $pnlDatasetActions = $window.FindName('pnlDatasetActions')
        
        $dgData.IsReadOnly = -not $AllowEdit
        if ($AllowEdit) {
            $dgData.Add_CellEditEnding({
                    param($sender, $e)
                    if ($e.EditAction -eq [System.Windows.Controls.DataGridEditAction]::Commit) {
                        $el = $e.EditingElement
                        if ($el -is [System.Windows.Controls.TextBox]) {
                            $newValStr = $el.Text
                            $propName = if ($e.Column.SortMemberPath) { $e.Column.SortMemberPath } else { $e.Column.Header }
                            $item = $e.Row.Item
                            if ($null -ne $item -and $item -is [PSCustomObject]) {
                                $oldVal = $item.$propName
                                if ($null -ne $oldVal) {
                                    $targetType = $oldVal.GetType()
                                    if ($targetType -ne [string]) {
                                        try {
                                            $parsedVal = $newValStr -as $targetType
                                            if ($null -eq $parsedVal -and -not [string]::IsNullOrWhiteSpace($newValStr)) {
                                                [System.Windows.MessageBox]::Show("Invalid value for type $($targetType.Name).", 'Validation Error', 'OK', 'Warning') | Out-Null
                                                $e.Cancel = $true
                                            }
                                            else {
                                                $item.$propName = $parsedVal
                                            }
                                        }
                                        catch {
                                            [System.Windows.MessageBox]::Show("Invalid value.", 'Validation Error', 'OK', 'Warning') | Out-Null
                                            $e.Cancel = $true
                                        }
                                    }
                                    else {
                                        $item.$propName = $newValStr
                                    }
                                }
                                else {
                                    $item.$propName = $newValStr
                                }
Update Search Cache
                                if ($null -ne $script:SearchCache) {
                                    $txt = [System.Text.StringBuilder]::new()
                                    foreach ($p in $item.PSObject.Properties) {
                                        [void]$txt.Append($p.Value)
                                        [void]$txt.Append(' ')
                                    }
                                    $script:SearchCache[$item] = $txt.ToString()
                                }
                            }
                        }
                    }
                })
        }
endregion
region Application State
        $script:SearchCache = [System.Collections.Generic.Dictionary[object, string]]::new()
        $script:AllItems = @()
        $script:FilteredItems = @()
        $script:DataSourceCollection = $null
        $script:PivotData = @()
        $script:AllFieldNames = @()
        $script:AllDiscoveredFields = @()  # Full field list, never filtered by -Columns
        $script:VisibleColumns = @()
        $script:FilterDefinitions = @()  # Array of @{ Name; Type; Control; LabelControl; ContainerControl; ExtraControl }
        $script:RequestedColumns = $Columns   # user-supplied column whitelist (may be $null)
        $script:ColorMapping = $ColorMapping     # conditional row coloring (may be $null)
        $script:GroupByTopN = $GroupByTopN
        $script:RefreshScript = $RefreshScript
        $script:Configuration = if ($Configuration) { [hashtable]$Configuration.Clone() } else { $null }
        $script:MainWindow = $window
        $script:FilterDebounceTimer = $null
        $script:GroupByDebounceTimer = $null
        $script:LastGroupBySignature = $null
        $script:PivotBuildTimer = $null
        $script:RefreshTimer = $null
        $script:RefreshStartTime = $null
        $script:ComboBoxMaxUnique = if ($Configuration.ComboBoxMaxUnique) { $Configuration.ComboBoxMaxUnique } else { 50 }  # Fields with <= this many unique values get a ComboBox
        $script:SearchRegexValid = $true
        $script:IsDarkMode = $false

        $txtTopN.Text = [string]$GroupByTopN
Show the Configuration button only when a Configuration hashtable was provided
        if ($script:Configuration) {
            $btnConfig.Visibility = 'Visible'
        }
Populate chart type selector
        @('Bar', 'Horizontal Bar', 'Pie', 'Line') | ForEach-Object { [void]$cmbChartType.Items.Add($_) }
        $cmbChartType.SelectedIndex = 0
Chart color palette
        $script:ChartColors = @('#0F766E', '#2563EB', '#D97706', '#DC2626', '#7C3AED', '#059669', '#DB2777', '#CA8A04', '#4F46E5', '#0891B2')
endregion
region Helper & Core Functions
region Status Text
        function script:Update-StatusText {
            param([string]$Message)
            if ($null -ne $lblStatus) { $lblStatus.Text = $Message }
        }
endregion
region Filter Apply
        function script:Schedule-FilterApply {
            if (-not $script:FilterDebounceTimer) {
                $timer = [System.Windows.Threading.DispatcherTimer]::new()
                $script:FilterDebounceTimer = $timer
                $timer.Interval = [TimeSpan]::FromMilliseconds(250)
                $action = { script:Apply-Filters }
                $timer.Add_Tick({
                        $timer.Stop()
                        & $action
                    }.GetNewClosure())
            }
            $script:FilterDebounceTimer.Stop()
            $script:FilterDebounceTimer.Start()
        }
endregion
region Runspace Pool   
        function script:Get-RunspacePool {
            if (-not $script:RunspacePool) {
                $maxThreads = [Math]::Max([int]$env:NUMBER_OF_PROCESSORS - 1, 2)
                $script:RunspacePool = [runspacefactory]::CreateRunspacePool(1, $maxThreads)
                $script:RunspacePool.ThreadOptions = 'ReuseThread'
                $script:RunspacePool.Open()
            }
            return $script:RunspacePool
        }
endregion
region Default Visible Columns
        function script:Get-DefaultVisibleColumns {
            param([array]$Items)

            foreach ($item in $Items) {
                if ($null -eq $item) { continue }

                try {
                    $displaySet = $item.PSStandardMembers.DefaultDisplayPropertySet
                    $propertyNames = @($displaySet.ReferencedPropertyNames)
                    if ($propertyNames.Count -gt 0) {
                        return @($propertyNames)
                    }
                }
                catch {
                    Write-Verbose "Failed to extract default display properties: $($_.Exception.Message)"
                }
            }

            return @()
        }
endregion
region Data Filtering & Schema Detection
```
