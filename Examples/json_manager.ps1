# Requires: Show-DataViewer function loaded in session
# Example JSON Explorer / Editor built only with Show-DataViewer parameters and actions

Add-Type -AssemblyName System.Windows.Forms

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
                $decimalValue = 0
                if ([decimal]::TryParse($Text, [ref]$decimalValue)) { return $decimalValue }
                return $Text
            }
            default { return $Text }
        }
    }

    function Get-NodeTypeName {
        param($Node)
        if ($null -eq $Node) { return 'Null' }
        if ($Node -is [System.Collections.IDictionary] -or $Node -is [pscustomobject]) { return 'Object' }
        if (($Node -is [System.Collections.IEnumerable]) -and -not ($Node -is [string])) { return 'Array' }
        if ($Node -is [bool]) { return 'Boolean' }
        if ($Node -is [byte] -or $Node -is [sbyte] -or $Node -is [int16] -or $Node -is [int32] -or $Node -is [int64] -or $Node -is [uint16] -or $Node -is [uint32] -or $Node -is [uint64] -or $Node -is [single] -or $Node -is [double] -or $Node -is [decimal]) { return 'Number' }
        return 'String'
    }

    function Get-NodeChildCount {
        param($Node)
        if ($null -eq $Node) { return 0 }
        if ($Node -is [System.Collections.IDictionary]) { return $Node.Count }
        if ($Node -is [pscustomobject]) { return @($Node.PSObject.Properties).Count }
        if (($Node -is [System.Collections.IEnumerable]) -and -not ($Node -is [string])) { return @($Node).Count }
        return 0
    }

    function Split-PathLeafLike {
        param([string]$Path)
        if ($Path -eq '$') { return '$' }
        $parts = $Path.Split('/')
        return $parts[-1]
    }

    function Get-ParentJsonPath {
        param([string]$Path)
        if ($Path -eq '$') { return $null }
        $idx = $Path.LastIndexOf('/')
        if ($idx -le 1) { return '$' }
        return $Path.Substring(0, $idx)
    }

    function Get-JsonNodeByPath {
        param(
            [Parameter(Mandatory)]$Root,
            [Parameter(Mandatory)][string]$Path
        )

        if ($Path -eq '$') { return $Root }

        $current = $Root
        $tokens = $Path.Substring(2).Split('/')

        foreach ($token in $tokens) {
            if ([string]::IsNullOrWhiteSpace($token)) { continue }
            if ($token -match '^\[(\d+)\]$') {
                $index = [int]$matches[1]
                $current = @($current)[$index]
                continue
            }

            $name = $token.Replace('~1', '/').Replace('~0', '~')
            if ($current -is [System.Collections.IDictionary]) {
                $current = $current[$name]
            }
            else {
                $prop = $current.PSObject.Properties[$name]
                $current = if ($prop) { $prop.Value } else { $null }
            }
        }

        return $current
    }

    function Set-JsonNodeByPath {
        param(
            [Parameter(Mandatory)]$Root,
            [Parameter(Mandatory)][string]$Path,
            $Value
        )

        if ($Path -eq '$') { throw 'Editing the root node is not supported in this sample.' }

        $tokens = $Path.Substring(2).Split('/') | Where-Object { $_ -ne '' }
        $leaf = $tokens[-1]
        $parentTokens = @($tokens | Select-Object -SkipLast 1)
        $parent = $Root

        foreach ($token in $parentTokens) {
            if ($token -match '^\[(\d+)\]$') {
                $parent = @($parent)[[int]$matches[1]]
            }
            else {
                $name = $token.Replace('~1', '/').Replace('~0', '~')
                if ($parent -is [System.Collections.IDictionary]) {
                    $parent = $parent[$name]
                }
                else {
                    $parent = $parent.PSObject.Properties[$name].Value
                }
            }
        }

        if ($leaf -match '^\[(\d+)\]$') {
            $index = [int]$matches[1]
            $parent[$index] = $Value
        }
        else {
            $name = $leaf.Replace('~1', '/').Replace('~0', '~')
            if ($parent -is [System.Collections.IDictionary]) {
                $parent[$name] = $Value
            }
            else {
                $parent.PSObject.Properties[$name].Value = $Value
            }
        }
    }

    function Get-JsonRows {
        param(
            [Parameter(Mandatory)]$Root,
            [Parameter(Mandatory)][string]$CurrentPath,
            [switch]$ShowCurrentOnly
        )

        $rows = New-Object System.Collections.Generic.List[object]

        function Add-NodeRow {
            param(
                $Node,
                [string]$Name,
                [string]$Path,
                [string]$ParentPath,
                [int]$Depth
            )

            $nodeType = Get-NodeTypeName -Node $Node
            $isContainer = $nodeType -in @('Object', 'Array')
            $childCount = Get-NodeChildCount -Node $Node
            $treeLabel = (' ' * ($Depth * 2)) + $(if ($Depth -gt 0) { ' └── ' } else { '' }) + $Name

            $rows.Add([pscustomobject]@{
                    TreeLabel   = $treeLabel
                    Name        = $Name
                    Path        = $Path
                    ParentPath  = $ParentPath
                    Depth       = $Depth
                    NodeType    = $nodeType
                    Value       = $(if ($isContainer) { '' } else { ConvertTo-JsonLeafString -Value $Node })
                    IsContainer = $isContainer
                    ChildCount  = $childCount
                })

            if (-not $isContainer) { return }

            if ($Node -is [System.Collections.IDictionary]) {
                foreach ($key in $Node.Keys) {
                    $escaped = $key.Replace('~', '~0').Replace('/', '~1')
                    Add-NodeRow -Node $Node[$key] -Name $key -Path "$Path/$escaped" -ParentPath $Path -Depth ($Depth + 1)
                }
                return
            }

            if ($Node -is [pscustomobject]) {
                foreach ($prop in $Node.PSObject.Properties) {
                    $escaped = $prop.Name.Replace('~', '~0').Replace('/', '~1')
                    Add-NodeRow -Node $prop.Value -Name $prop.Name -Path "$Path/$escaped" -ParentPath $Path -Depth ($Depth + 1)
                }
                return
            }

            $index = 0
            foreach ($item in @($Node)) {
                Add-NodeRow -Node $item -Name "[$index]" -Path "$Path/[$index]" -ParentPath $Path -Depth ($Depth + 1)
                $index++
            }
        }

        $scopeRoot = Get-JsonNodeByPath -Root $Root -Path $CurrentPath
        if ($ShowCurrentOnly) {
            Add-NodeRow -Node $scopeRoot -Name $(Split-PathLeafLike -Path $CurrentPath) -Path $CurrentPath -ParentPath $(Get-ParentJsonPath -Path $CurrentPath) -Depth 0
        }
        else {
            Add-NodeRow -Node $scopeRoot -Name $(Split-PathLeafLike -Path $CurrentPath) -Path $CurrentPath -ParentPath $(Get-ParentJsonPath -Path $CurrentPath) -Depth 0
        }

        return $rows
    }
}

$sampleJsonPath = Join-Path $env:TEMP 'sample-json-explorer.json'
if (-not (Test-Path $sampleJsonPath)) {
    @'
{
  "app": {
    "name": "Show-DataViewer JSON Explorer",
    "version": 1,
    "enabled": true,
    "owners": ["Anna", "Marek"],
    "settings": {
      "theme": "Dark",
      "autoSave": false,
      "maxItems": 25
    }
  },
  "servers": [
    {
      "name": "SRV-APP-01",
      "ip": "10.0.0.11",
      "active": true
    },
    {
      "name": "SRV-DB-01",
      "ip": "10.0.0.21",
      "active": false
    }
  ]
}
'@ | Set-Content -Path $sampleJsonPath -Encoding UTF8
}

$config = @{
    JsonPath        = $sampleJsonPath
    CurrentPath     = '$'
    ShowCurrentOnly = $false
    Helpers         = $sharedHelpers
}

$JsonPath = $sampleJsonPath

if ([string]::IsNullOrWhiteSpace($CurrentPath)) {
    $CurrentPath = '$'
}

$refreshScript = {
    . $Helpers

    if ([string]::IsNullOrWhiteSpace($CurrentPath)) {
        $CurrentPath = '$'
    }

    if ([string]::IsNullOrWhiteSpace($JsonPath)) {
        throw 'JsonPath is empty. Set Configuration.JsonPath before refreshing.'
    }

    $raw = Get-Content -Path $JsonPath -Raw -Encoding UTF8
    $root = $raw | ConvertFrom-Json

    Get-JsonRows -Root $root -CurrentPath $CurrentPath -ShowCurrentOnly:$ShowCurrentOnly
}

$actions = @(
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
            . $Context.Configuration.Helpers

            $path = $Context.Configuration.JsonPath
            if ([string]::IsNullOrWhiteSpace($path)) { return 'Cannot save: Configuration.JsonPath is empty.' }
            if (-not (Test-Path -LiteralPath $path)) { return "Cannot save: JSON file was not found: $path" }

            $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
            $root = $raw | ConvertFrom-Json 

            foreach ($row in @($Context.Data)) {
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
            . $Context.Configuration.Helpers
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
            . $Context.Configuration.Helpers

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
            . $Context.Configuration.Helpers
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
            . $Context.Configuration.Helpers
            
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

$initialData = & $refreshScript

Show-DataViewer `
    -Title 'JSON Explorer Editor' `
    -Data $initialData `
    -RefreshScript $refreshScript `
    -Configuration $config `
    -Actions $actions `
    -Columns @('TreeLabel', 'NodeType', 'Value', 'ChildCount', 'Path') `
    -AllowEdit
