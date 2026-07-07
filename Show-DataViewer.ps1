<#
.SYNOPSIS
    Launches a WPF-based data viewer for PowerShell objects.

.DESCRIPTION
    Displays a collection of PSCustomObject items in an interactive WPF window.
    The viewer can:
    - auto-detect field types and build filter controls
    - show, hide, and reorder columns
    - display a details pane for the selected row
    - aggregate data in the Group By panel
    - build charts and export them to PNG
    - refresh data asynchronously through -RefreshScript
    - execute custom row or dataset actions through -Actions
    - allow inline editing when -AllowEdit is used

.PARAMETER Data
    One or more PSCustomObject items to display. Accepts pipeline input.

.PARAMETER RefreshScript
    Optional scriptblock executed asynchronously when the Refresh button is clicked.
    It must return an array of PSCustomObject items. When -Configuration is provided,
    its keys are injected as variables into the scriptblock.

.PARAMETER Configuration
    Optional hashtable of runtime settings exposed through the Configuration dialog.
    Each key is available inside -RefreshScript as a variable.

.PARAMETER Columns
    Optional list of property names to pre-select as visible. Non-matching names are ignored.
    If omitted, the viewer prefers the object's default display properties (similar to Format-Table)
    when available, and otherwise falls back to all discovered properties.

.PARAMETER ColorMapping
    Optional hashtable that highlights rows based on property values.
    Example: @{ Level = @{ Error = '#FECACA'; Warning = '#FEF3C7' } }

.PARAMETER Title
    Optional window title. Default: Data Viewer

.PARAMETER GroupByTopN
    Default number of values shown in Group By analysis. Default: 10

.PARAMETER Actions
    Optional array of action definitions. Each action is a hashtable with keys:
    Name, Script, Scope, Icon, and ReturnToGrid. Scope can be Row, Dataset, or Both.

.PARAMETER AllowEdit
    Enables inline editing of cells in the DataGrid. Edited values update the underlying objects
    and refresh related filters and group-by logic.

.EXAMPLE
    $data = Get-Process | Select-Object Name, Id, CPU, Handles
    Show-DataViewer -Data $data -Title 'Process Monitor'

.EXAMPLE
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

.EXAMPLE
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

.EXAMPLE
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

.EXAMPLE
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

.EXAMPLE
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

.AUTHOR
    Adam Mnich @2026
#>

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

        [switch]$AllowEdit
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
        $inputData = @($collectedData)

        #requires -Version 5.1
        Add-Type -AssemblyName PresentationFramework
        Add-Type -AssemblyName PresentationCore
        Add-Type -AssemblyName WindowsBase
        Add-Type -AssemblyName System.Windows.Forms

        $screenH = [System.Windows.SystemParameters]::PrimaryScreenHeight * 0.9
        $screenW = [System.Windows.SystemParameters]::PrimaryScreenWidth * 0.9

        # 
        #region XAML
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
        #endregion

        # 
        #region Window Setup
        $reader = [System.Xml.XmlNodeReader]::new($xaml)
        $window = [Windows.Markup.XamlReader]::Load($reader)

        # Find named elements
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
                                # Update Search Cache
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
        #endregion

        # 
        #region Script-scope State
        $script:SearchCache = [System.Collections.Generic.Dictionary[object, string]]::new()
        $script:AllItems = @()
        $script:FilteredItems = @()
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
        $script:PivotBuildJob = $null
        $script:PivotBuildTimer = $null
        $script:RefreshJob = $null
        $script:RefreshTimer = $null
        $script:RefreshStartTime = $null
        $script:ComboBoxMaxUnique = 50  # Fields with <= this many unique values get a ComboBox
        $script:SearchRegexValid = $true
        $script:IsDarkMode = $false

        $txtTopN.Text = [string]$GroupByTopN

        # Show the Configuration button only when a Configuration hashtable was provided
        if ($script:Configuration) {
            $btnConfig.Visibility = 'Visible'
        }

        # Populate chart type selector
        @('Bar', 'Horizontal Bar', 'Pie', 'Line') | ForEach-Object { [void]$cmbChartType.Items.Add($_) }
        $cmbChartType.SelectedIndex = 0

        # Chart color palette
        $script:ChartColors = @('#0F766E', '#2563EB', '#D97706', '#DC2626', '#7C3AED', '#059669', '#DB2777', '#CA8A04', '#4F46E5', '#0891B2')
        #endregion

        # 
        #region Helper Functions

        function script:Update-StatusText {
            param([string]$Message)
            if ($null -ne $lblStatus) { $lblStatus.Text = $Message }
        }

        function script:Schedule-FilterApply {
            if (-not $script:FilterDebounceTimer) {
                $script:FilterDebounceTimer = [System.Windows.Threading.DispatcherTimer]::new()
                $script:FilterDebounceTimer.Interval = [TimeSpan]::FromMilliseconds(250)
                $script:FilterDebounceTimer.Add_Tick({
                        $script:FilterDebounceTimer.Stop()
                        global:Apply-Filters
                    })
            }
            $script:FilterDebounceTimer.Stop()
            $script:FilterDebounceTimer.Start()
        }

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
                catch {}
            }

            return @()
        }

        #  Schema Detection 
        # Inspects data to discover field names, types, and cardinality.
        # Uses sampling and HashSet for O(n) performance instead of Select-Unique.
        function script:Initialize-DynamicSchema {
            param([array]$Items)

            if ($Items.Count -eq 0) { return @() }

            # Collect property names from a sample (first 200 items covers most schemas)
            $allProps = [System.Collections.Generic.HashSet[string]]::new()
            $sampleLimit = [Math]::Min(200, $Items.Count)
            for ($i = 0; $i -lt $sampleLimit; $i++) {
                foreach ($prop in $Items[$i].PSObject.Properties) {
                    [void]$allProps.Add($prop.Name)
                }
            }
            # If the sample found new props, do a final check on a few later items
            if ($Items.Count -gt $sampleLimit) {
                $step = [Math]::Max(1, [int]($Items.Count / 20))
                for ($i = $sampleLimit; $i -lt $Items.Count; $i += $step) {
                    foreach ($prop in $Items[$i].PSObject.Properties) {
                        [void]$allProps.Add($prop.Name)
                    }
                }
            }
            $script:AllFieldNames = @($allProps)

            $schema = @()
            $maxCombo = $script:ComboBoxMaxUnique
            foreach ($fieldName in $script:AllFieldNames) {
                # Sample first 100 for type detection
                $sampleValues = [System.Collections.Generic.List[object]]::new()
                $sampleN = [Math]::Min(100, $Items.Count)
                for ($i = 0; $i -lt $sampleN; $i++) {
                    $v = $Items[$i].$fieldName
                    if ($null -ne $v) { $sampleValues.Add($v) }
                }

                $isDateTime = $false
                $isComboBox = $false

                # Check if DateTime
                if ($sampleValues.Count -gt 0) {
                    $firstNonNull = $sampleValues[0]
                    if ($firstNonNull -is [DateTime]) {
                        $isDateTime = $true
                    }
                    elseif ($firstNonNull -is [string]) {
                        $testDate = [DateTime]::MinValue
                        if ([DateTime]::TryParse($firstNonNull, [ref]$testDate)) {
                            $dateCount = 0
                            $checkN = [Math]::Min(5, $sampleValues.Count)
                            for ($si = 0; $si -lt $checkN; $si++) {
                                $d = [DateTime]::MinValue
                                if ([DateTime]::TryParse($sampleValues[$si].ToString(), [ref]$d)) { $dateCount++ }
                            }
                            if ($dateCount -ge [Math]::Min(3, $sampleValues.Count)) {
                                $isDateTime = $true
                            }
                        }
                    }
                }

                # Count unique values via HashSet with early-exit for cardinality check
                $uniqueCount = 0
                if (-not $isDateTime) {
                    $seen = [System.Collections.Generic.HashSet[string]]::new()
                    $tooMany = $false
                    foreach ($item in $Items) {
                        $v = $item.$fieldName
                        $vs = if ($null -eq $v -or $v.ToString().Trim() -eq '') { '(Empty)' } else { $v.ToString() }
                        if ($seen.Add($vs)) {
                            # Once we exceed threshold+1, no need to keep counting
                            if ($seen.Count -gt $maxCombo) {
                                $tooMany = $true
                                break
                            }
                        }
                    }
                    $uniqueCount = $seen.Count
                    if (-not $tooMany -and $uniqueCount -gt 0 -and $uniqueCount -le $maxCombo) {
                        $isComboBox = $true
                    }
                }

                $filterType = 'TextBox'
                if ($isDateTime) { $filterType = 'DateTime' }
                elseif ($isComboBox) { $filterType = 'ComboBox' }

                $schema += @{
                    Name        = $fieldName
                    FilterType  = $filterType
                    UniqueCount = $uniqueCount
                    IsDateTime  = $isDateTime
                    IsComboBox  = $isComboBox
                }
            }

            return $schema
        }

        #  Dynamic Filter Controls 
        function script:Build-FilterControls {
            param([array]$Schema, [array]$Items)

            $pnlFilterContent.Children.Clear()
            $script:FilterDefinitions = @()

            foreach ($fieldSchema in $Schema) {
                $container = [System.Windows.Controls.StackPanel]::new()
                $container.Margin = [System.Windows.Thickness]::new(0, 0, 14, 8)

                $label = [System.Windows.Controls.TextBlock]::new()
                $label.Text = $fieldSchema.Name.ToUpper()
                $label.FontSize = 10
                $label.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextMuted")
                $label.FontWeight = 'SemiBold'
                $label.Margin = [System.Windows.Thickness]::new(0, 0, 0, 4)
                [void]$container.Children.Add($label)

                $filterDef = @{
                    Name             = $fieldSchema.Name
                    Type             = $fieldSchema.FilterType
                    Control          = $null
                    ExtraControl     = $null   # For DateTime: time TextBox or "To" DatePicker
                    ExtraControl2    = $null   # For DateTime: "To" time TextBox
                    LabelControl     = $label
                    ContainerControl = $container
                }

                switch ($fieldSchema.FilterType) {
                    'ComboBox' {
                        # Multi-select dropdown via ToggleButton + Popup
                        $uniqueVals = @($Items | ForEach-Object {
                                $v = $_."$($fieldSchema.Name)"
                                if ($null -eq $v -or $v.ToString().Trim() -eq '') { '(Empty)' } else { $v.ToString() }
                            } | Select-Object -Unique | Sort-Object)

                        $toggleBtn = [System.Windows.Controls.Primitives.ToggleButton]::new()
                        $toggleBtn.Content = '(All)'
                        $toggleBtn.Width = 200
                        $toggleBtn.Padding = [System.Windows.Thickness]::new(6, 4, 6, 4)
                        $toggleBtn.HorizontalContentAlignment = 'Left'
                        $toggleBtn.SetResourceReference([System.Windows.Controls.Control]::BackgroundProperty, "BgControl")
                        $toggleBtn.SetResourceReference([System.Windows.Controls.Control]::BorderBrushProperty, "StrokeMid")
                        $toggleBtn.BorderThickness = [System.Windows.Thickness]::new(1)
                        $toggleBtn.Tag = $fieldSchema.Name

                        $popup = [System.Windows.Controls.Primitives.Popup]::new()
                        $popup.PlacementTarget = $toggleBtn
                        $popup.Placement = 'Bottom'
                        $popup.StaysOpen = $false
                        $popup.AllowsTransparency = $true

                        $popupBorder = [System.Windows.Controls.Border]::new()
                        $popupBorder.SetResourceReference([System.Windows.Controls.Border]::BackgroundProperty, "BgPanel")
                        $popupBorder.SetResourceReference([System.Windows.Controls.Border]::BorderBrushProperty, "StrokeMid")
                        $popupBorder.BorderThickness = [System.Windows.Thickness]::new(1)
                        $popupBorder.Padding = [System.Windows.Thickness]::new(6)
                        $popupBorder.MaxHeight = 350
                        $popupBorder.Width = 200

                        $popupStack = [System.Windows.Controls.StackPanel]::new()

                        # Select All / Deselect All buttons
                        $btnPanel = [System.Windows.Controls.StackPanel]::new()
                        $btnPanel.Orientation = 'Horizontal'
                        $btnPanel.Margin = [System.Windows.Thickness]::new(0, 0, 0, 4)
                        $btnSelAll = [System.Windows.Controls.Button]::new()
                        $btnSelAll.Content = 'All'
                        $btnSelAll.Padding = [System.Windows.Thickness]::new(8, 2, 8, 2)
                        $btnSelAll.Margin = [System.Windows.Thickness]::new(0, 0, 4, 0)
                        $btnSelAll.FontSize = 11
                        $btnDeselAll = [System.Windows.Controls.Button]::new()
                        $btnDeselAll.Content = 'None'
                        $btnDeselAll.Padding = [System.Windows.Thickness]::new(8, 2, 8, 2)
                        $btnDeselAll.FontSize = 11
                        [void]$btnPanel.Children.Add($btnSelAll)
                        [void]$btnPanel.Children.Add($btnDeselAll)
                        [void]$popupStack.Children.Add($btnPanel)

                        $scrollViewer = [System.Windows.Controls.ScrollViewer]::new()
                        $scrollViewer.VerticalScrollBarVisibility = 'Auto'
                        $scrollViewer.MaxHeight = 280
                        $cbStack = [System.Windows.Controls.StackPanel]::new()

                        $checkBoxes = [System.Collections.Generic.List[System.Windows.Controls.CheckBox]]::new()
                        foreach ($v in $uniqueVals) {
                            $cb = [System.Windows.Controls.CheckBox]::new()
                            $cb.Content = $v.ToString()
                            $cb.IsChecked = $true
                            $cb.Margin = [System.Windows.Thickness]::new(2, 2, 2, 2)
                            $cb.FontSize = 12
                            $cb.Tag = $toggleBtn  # reference back to update label
                            $cb.Add_Checked({ script:Schedule-FilterApply })
                            $cb.Add_Unchecked({ script:Schedule-FilterApply })
                            [void]$cbStack.Children.Add($cb)
                            $checkBoxes.Add($cb)
                        }
                        $scrollViewer.Content = $cbStack
                        [void]$popupStack.Children.Add($scrollViewer)
                        $popupBorder.Child = $popupStack
                        $popup.Child = $popupBorder

                        # Toggle popup open/close
                        $toggleBtn.Add_Checked({ $popup.IsOpen = $true }.GetNewClosure())
                        $toggleBtn.Add_Unchecked({ $popup.IsOpen = $false }.GetNewClosure())
                        $popup.Add_Closed({ $toggleBtn.IsChecked = $false }.GetNewClosure())

                        # Select All / Deselect All
                        $btnSelAll.Add_Click({
                                foreach ($c in $checkBoxes) { $c.IsChecked = $true }
                            }.GetNewClosure())
                        $btnDeselAll.Add_Click({
                                foreach ($c in $checkBoxes) { $c.IsChecked = $false }
                            }.GetNewClosure())

                        [void]$container.Children.Add($toggleBtn)
                        # Store the multi-select wrapper as the Control
                        $filterDef.Control = @{
                            ToggleButton = $toggleBtn
                            CheckBoxes   = $checkBoxes
                            Popup        = $popup
                        }
                    }

                    'DateTime' {
                        # "From" DatePicker
                        $dpFrom = [System.Windows.Controls.DatePicker]::new()
                        $dpFrom.Width = 145
                        $dpFrom.Tag = "$($fieldSchema.Name)_From"
                        $dpFrom.Add_SelectedDateChanged({ global:Apply-Filters })
                        [void]$container.Children.Add($dpFrom)

                        # "From" Time
                        $txtTimeFrom = [System.Windows.Controls.TextBox]::new()
                        $txtTimeFrom.Width = 145
                        $txtTimeFrom.Text = '00:00'
                        $txtTimeFrom.Margin = [System.Windows.Thickness]::new(0, 3, 0, 0)
                        $txtTimeFrom.Tag = "$($fieldSchema.Name)_TimeFrom"
                        $txtTimeFrom.Add_TextChanged({ script:Schedule-FilterApply })
                        [void]$container.Children.Add($txtTimeFrom)

                        # "To" label
                        $labelTo = [System.Windows.Controls.TextBlock]::new()
                        $labelTo.Text = "$($fieldSchema.Name.ToUpper()) TO"
                        $labelTo.FontSize = 10
                        $labelTo.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextMuted")
                        $labelTo.FontWeight = 'SemiBold'
                        $labelTo.Margin = [System.Windows.Thickness]::new(0, 6, 0, 4)
                        [void]$container.Children.Add($labelTo)

                        # "To" DatePicker
                        $dpTo = [System.Windows.Controls.DatePicker]::new()
                        $dpTo.Width = 145
                        $dpTo.Tag = "$($fieldSchema.Name)_To"
                        $dpTo.Add_SelectedDateChanged({ global:Apply-Filters })
                        [void]$container.Children.Add($dpTo)

                        # "To" Time
                        $txtTimeTo = [System.Windows.Controls.TextBox]::new()
                        $txtTimeTo.Width = 145
                        $txtTimeTo.Text = '23:59'
                        $txtTimeTo.Margin = [System.Windows.Thickness]::new(0, 3, 0, 0)
                        $txtTimeTo.Tag = "$($fieldSchema.Name)_TimeTo"
                        $txtTimeTo.Add_TextChanged({ script:Schedule-FilterApply })
                        [void]$container.Children.Add($txtTimeTo)

                        $filterDef.Control = $dpFrom
                        $filterDef.ExtraControl = @{ DatePickerTo = $dpTo; TimeFrom = $txtTimeFrom; TimeTo = $txtTimeTo }
                    }

                    'TextBox' {
                        $txt = [System.Windows.Controls.TextBox]::new()
                        $txt.Width = 200
                        $txt.Tag = $fieldSchema.Name
                        $txt.Add_TextChanged({ script:Schedule-FilterApply })
                        [void]$container.Children.Add($txt)
                        $filterDef.Control = $txt
                    }
                }

                [void]$pnlFilterContent.Children.Add($container)
                $script:FilterDefinitions += $filterDef
            }
        }

        # ── Update Dynamic Filters ───────────────────────────────────────────────
        function script:Update-DynamicFilters {
            foreach ($fd in $script:FilterDefinitions) {
                if ($fd.Type -eq 'ComboBox') {
                    $cbs = $fd.Control.CheckBoxes
                    if (-not $cbs -or $cbs.Count -eq 0) { continue }
                    $cbStack = $cbs[0].Parent
                    
                    $state = @{}
                    foreach ($c in $cbs) { $state[$c.Content.ToString()] = $c.IsChecked }
                    
                    $uniqueVals = @($script:AllItems | ForEach-Object {
                            $v = $_."$($fd.Name)"
                            if ($null -eq $v -or $v.ToString().Trim() -eq '') { '(Empty)' } else { $v.ToString() }
                        } | Select-Object -Unique | Sort-Object)
                    
                    $cbStack.Children.Clear()
                    $cbs.Clear()
                    
                    $toggleBtn = $fd.Control.ToggleButton
                    foreach ($v in $uniqueVals) {
                        $vs = $v.ToString()
                        $cb = [System.Windows.Controls.CheckBox]::new()
                        $cb.Content = $vs
                        $cb.IsChecked = if ($state.ContainsKey($vs)) { $state[$vs] } else { $true }
                        $cb.Margin = [System.Windows.Thickness]::new(2, 2, 2, 2)
                        $cb.FontSize = 12
                        $cb.Tag = $toggleBtn
                        $cb.Add_Checked({ script:Schedule-FilterApply })
                        $cb.Add_Unchecked({ script:Schedule-FilterApply })
                        [void]$cbStack.Children.Add($cb)
                        $cbs.Add($cb)
                    }
                    
                    $total = $cbs.Count
                    $uncheckedCount = ($cbs | Where-Object { -not $_.IsChecked }).Count
                    $checkedCount = $total - $uncheckedCount
                    if ($checkedCount -eq $total -or $checkedCount -eq 0) {
                        $toggleBtn.Content = if ($checkedCount -eq $total) { '(All)' } else { '(None)' }
                    }
                    elseif ($checkedCount -eq 1) {
                        $checkedCb = $cbs | Where-Object { $_.IsChecked } | Select-Object -First 1
                        $toggleBtn.Content = if ($checkedCb.Content.ToString().Length -gt 25) { $checkedCb.Content.ToString().Substring(0, 22) + "..." } else { $checkedCb.Content.ToString() }
                    }
                    else {
                        $toggleBtn.Content = "{0} of {1} selected" -f $checkedCount, $total
                    }
                }
            }
        }

        #  Get Filtered Items 
        # Single-pass filter: pre-computes all active filter criteria, then
        # iterates AllItems once testing every criterion per item.
        function script:Get-FilteredItems {
            param([string]$ExcludeProp)

            if ($script:AllItems.Count -eq 0) { return @() }

            #  Pre-compute active criteria 
            # Each criterion is a hashtable: @{ Type; PropName; ... }
            $criteria = [System.Collections.Generic.List[hashtable]]::new()

            # Global regex search
            $searchRegex = $null
            if ($txtSearchAll -and $txtSearchAll.Text.Trim()) {
                $searchText = $txtSearchAll.Text.Trim()
                try {
                    $searchRegex = [regex]::new($searchText, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Compiled, [TimeSpan]::FromMilliseconds(100))
                    $script:SearchRegexValid = $true
                }
                catch {
                    $script:SearchRegexValid = $false
                }
            }
            else {
                $script:SearchRegexValid = $true
            }

            # Per-field criteria
            foreach ($fd in $script:FilterDefinitions) {
                if ($fd.Name -eq $ExcludeProp) { continue }
                if ($script:VisibleColumns -notcontains $fd.Name) { continue }

                switch ($fd.Type) {
                    'ComboBox' {
                        # Multi-select: collect unchecked values
                        $cbs = $fd.Control.CheckBoxes
                        $total = $cbs.Count
                        $unchecked = [System.Collections.Generic.HashSet[string]]::new()
                        foreach ($c in $cbs) {
                            if (-not $c.IsChecked) { [void]$unchecked.Add($c.Content.ToString()) }
                        }
                        # Update toggle button label
                        $checkedCount = $total - $unchecked.Count
                        if ($checkedCount -eq $total -or $checkedCount -eq 0) {
                            $fd.Control.ToggleButton.Content = if ($checkedCount -eq $total) { '(All)' } else { '(None)' }
                        }
                        elseif ($checkedCount -eq 1) {
                            $checkedCb = $cbs | Where-Object { $_.IsChecked } | Select-Object -First 1
                            $fd.Control.ToggleButton.Content = if ($checkedCb.Content.ToString().Length -gt 25) { $checkedCb.Content.ToString().Substring(0, 22) + "..." } else { $checkedCb.Content.ToString() }
                        }
                        else {
                            $fd.Control.ToggleButton.Content = "{0} of {1} selected" -f $checkedCount, $total
                        }
                        if ($unchecked.Count -gt 0) {
                            $criteria.Add(@{ Type = 'Combo'; PropName = $fd.Name; ExcludedValues = $unchecked })
                        }
                    }
                    'TextBox' {
                        $val = $fd.Control.Text.Trim()
                        if ($val) {
                            $criteria.Add(@{ Type = 'Text'; PropName = $fd.Name; Pattern = [regex]::Escape($val) })
                        }
                    }
                    'DateTime' {
                        $dpFrom = $fd.Control
                        $dpTo = $fd.ExtraControl.DatePickerTo
                        $txtTimeFrom = $fd.ExtraControl.TimeFrom
                        $txtTimeTo = $fd.ExtraControl.TimeTo

                        $fromDT = $null
                        $toDT = $null
                        if ($dpFrom.SelectedDate) {
                            $fromDate = [DateTime]$dpFrom.SelectedDate
                            $fromTime = [DateTime]::Today
                            if ($txtTimeFrom.Text) { try { $fromTime = [DateTime]::Parse($txtTimeFrom.Text) } catch {} }
                            $fromDT = [DateTime]::new($fromDate.Year, $fromDate.Month, $fromDate.Day, $fromTime.Hour, $fromTime.Minute, 0)
                        }
                        if ($dpTo.SelectedDate) {
                            $toDate = [DateTime]$dpTo.SelectedDate
                            $toTime = [DateTime]::Today.AddHours(23).AddMinutes(59)
                            if ($txtTimeTo.Text) { try { $toTime = [DateTime]::Parse($txtTimeTo.Text) } catch {} }
                            $toDT = [DateTime]::new($toDate.Year, $toDate.Month, $toDate.Day, $toTime.Hour, $toTime.Minute, 59)
                        }
                        if ($fromDT -or $toDT) {
                            $criteria.Add(@{ Type = 'DateTime'; PropName = $fd.Name; From = $fromDT; To = $toDT })
                        }
                    }
                }
            }

            #  Single pass over all items 
            $result = [System.Collections.Generic.List[PSCustomObject]]::new()
            $hasCriteria = ($criteria.Count -gt 0)
            $hasSearch = ($null -ne $searchRegex)
            $visibleCols = $script:VisibleColumns

            foreach ($item in $script:AllItems) {
                $pass = $true

                # Global search
                if ($hasSearch) {
                    $found = $false
                    if ($null -ne $script:SearchCache -and $script:SearchCache.ContainsKey($item)) {
                        if ($searchRegex.IsMatch($script:SearchCache[$item])) {
                            $found = $true
                        }
                    }
                    else {
                        foreach ($colName in $visibleCols) {
                            $v = $item.$colName
                            if ($null -ne $v -and $searchRegex.IsMatch($v.ToString())) {
                                $found = $true
                                break
                            }
                        }
                    }
                    if (-not $found) { $pass = $false }
                }

                # Per-field criteria
                if ($pass -and $hasCriteria) {
                    foreach ($c in $criteria) {
                        $propVal = $item."$($c.PropName)"
                        switch ($c.Type) {
                            'Combo' {
                                $isEmpty = ($null -eq $propVal -or $propVal.ToString().Trim() -eq '')
                                $propValStr = if ($isEmpty) { '(Empty)' } else { $propVal.ToString() }
                                if ($c.ExcludedValues.Contains($propValStr)) { $pass = $false }
                            }
                            'Text' {
                                if ($null -eq $propVal -or -not ($propVal.ToString() -match $c.Pattern)) { $pass = $false }
                            }
                            'DateTime' {
                                if ($null -eq $propVal) { $pass = $false }
                                else {
                                    $eventDate = $null
                                    try { $eventDate = [DateTime]$propVal } catch {}
                                    if (-not $eventDate) { $pass = $false }
                                    elseif ($c.From -and $eventDate -lt $c.From) { $pass = $false }
                                    elseif ($c.To -and $eventDate -gt $c.To) { $pass = $false }
                                }
                            }
                        }
                        if (-not $pass) { break }  # short-circuit on first failure
                    }
                }

                if ($pass) { $result.Add($item) }
            }

            return , @($result)
        }

        #  Apply Filters 
        function global:Apply-Filters {
            $items = script:Get-FilteredItems
            $script:FilteredItems = $items
            $dgData.ItemsSource = $script:FilteredItems
            $lblCount.Text = '{0} items' -f $script:FilteredItems.Count

            if ($txtSearchAll) {
                if ($script:SearchRegexValid) {
                    $txtSearchAll.SetResourceReference([System.Windows.Controls.Control]::BackgroundProperty, "BgControl")
                    Update-StatusText ('Showing {0} of {1} items.' -f $script:FilteredItems.Count, $script:AllItems.Count)
                }
                else {
                    $txtSearchAll.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(0xFE, 0xE2, 0xE2))
                    Update-StatusText ('Invalid search Regex. Showing {0} of {1} items.' -f $script:FilteredItems.Count, $script:AllItems.Count)
                }
            }
            else {
                Update-StatusText ('Showing {0} of {1} items.' -f $script:FilteredItems.Count, $script:AllItems.Count)
            }

            script:Update-EmptyState
            script:Update-DetailPane
            script:Update-FooterSummary

            # Defer Group By rebuild to avoid blocking the UI during rapid filter changes
            if (-not $script:GroupByDebounceTimer) {
                $script:GroupByDebounceTimer = [System.Windows.Threading.DispatcherTimer]::new()
                $script:GroupByDebounceTimer.Interval = [TimeSpan]::FromMilliseconds(400)
                $script:GroupByDebounceTimer.Add_Tick({
                        $script:GroupByDebounceTimer.Stop()
                        script:Update-GroupByPanel
                    })
            }
            $script:GroupByDebounceTimer.Stop()
            $script:GroupByDebounceTimer.Start()
        }

        #  Empty State 
        function script:Update-EmptyState {
            if ($null -eq $txtEmptyState) { return }
            if ($script:FilteredItems.Count -eq 0) {
                $txtEmptyState.Visibility = 'Visible'
                if ($script:AllItems.Count -eq 0) {
                    $txtEmptyState.Text = 'No data loaded. Pass data via -Data parameter or click Refresh.'
                }
                else {
                    $txtEmptyState.Text = 'No items match the current filters. Try clearing some filters.'
                }
            }
            else {
                $txtEmptyState.Visibility = 'Collapsed'
            }
        }

        #  Detail Pane 
        function script:Update-DetailPane {
            if ($null -eq $txtDetail) { return }
            if ($dgData.SelectedItem) {
                $r = $dgData.SelectedItem
                # Show all properties
                $lines = @()
                foreach ($prop in $r.PSObject.Properties) {
                    $lines += '{0}: {1}' -f $prop.Name, $prop.Value
                }
                $txtDetail.Text = ($lines -join [Environment]::NewLine)
            }
            elseif ($script:FilteredItems.Count -eq 0) {
                if ($script:AllItems.Count -eq 0) {
                    $txtDetail.Text = 'No data loaded.'
                }
                else {
                    $txtDetail.Text = 'No items match filters.'
                }
            }
            else {
                $txtDetail.Text = 'Select a row to view full details.'
            }
        }

        # ── Footer Summary ──────────────────────────────────────────────────────────
        function script:Update-FooterSummary {
            if ($null -eq $pnlFooter -or $null -eq $txtFooterSummary) { return }
            if ($script:FilteredItems.Count -eq 0) {
                $pnlFooter.Visibility = 'Collapsed'
                return
            }

            # Find numeric columns among visible columns
            $numericCols = @()
            foreach ($col in $script:VisibleColumns) {
                $isNum = $true
                $hasVal = $false
                for ($i = 0; $i -lt [Math]::Min(50, $script:FilteredItems.Count); $i++) {
                    $val = $script:FilteredItems[$i].$col
                    if ($null -ne $val -and $val.ToString().Trim() -ne '') {
                        $hasVal = $true
                        if ($val -isnot [int] -and $val -isnot [double] -and $val -isnot [decimal] -and $val -isnot [long]) {
                            $testNum = 0.0
                            if (-not [double]::TryParse($val.ToString(), [ref]$testNum)) {
                                $isNum = $false
                                break
                            }
                        }
                    }
                }
                if ($isNum -and $hasVal) { $numericCols += $col }
            }

            if ($numericCols.Count -eq 0) {
                $pnlFooter.Visibility = 'Collapsed'
                return
            }

            $summaryParts = @()
            foreach ($col in $numericCols) {
                $values = [System.Collections.Generic.List[double]]::new()
                $sum = 0.0
                foreach ($item in $script:FilteredItems) {
                    $val = $item.$col
                    if ($null -ne $val -and $val.ToString().Trim() -ne '') {
                        $parsed = 0.0
                        if ([double]::TryParse($val.ToString(), [ref]$parsed)) {
                            $values.Add($parsed)
                            $sum += $parsed
                        }
                    }
                }
                if ($values.Count -gt 0) {
                    $values.Sort()
                    $count = $values.Count
                    $min = $values[0]
                    $max = $values[$count - 1]
                    $avg = $sum / $count
                    
                    $mid = [Math]::Floor($count / 2)
                    $median = if ($count % 2 -eq 0) { ($values[$mid - 1] + $values[$mid]) / 2.0 } else { $values[$mid] }
                    
                    $p95Idx = [Math]::Floor(0.95 * $count)
                    if ($p95Idx -ge $count) { $p95Idx = $count - 1 }
                    $p95 = $values[$p95Idx]
                    
                    $stdDev = 0.0
                    if ($count -gt 1) {
                        $sumSq = 0.0
                        foreach ($v in $values) { $sumSq += [Math]::Pow($v - $avg, 2) }
                        $stdDev = [Math]::Sqrt($sumSq / ($count - 1))
                    }
                    
                    $summaryParts += "{0}: Cnt={1}, Sum={2:N2}, Avg={3:N2}, Min={4:N2}, Max={5:N2}, Med={6:N2}, P95={7:N2}, Std={8:N2}" -f $col, $count, $sum, $avg, $min, $max, $median, $p95, $stdDev
                }
            }

            if ($summaryParts.Count -gt 0) {
                $txtFooterSummary.Text = "Summary >  " + ($summaryParts -join "  |  ")
                $pnlFooter.Visibility = 'Visible'
            }
            else {
                $pnlFooter.Visibility = 'Collapsed'
            }
        }

        #  Build Grid Columns 
        function script:Build-GridColumns {
            $dgData.Columns.Clear()

            foreach ($colName in $script:VisibleColumns) {
                $col = [System.Windows.Controls.DataGridTextColumn]::new()
                $col.Header = $colName
                $binding = [System.Windows.Data.Binding]::new($colName)
                if ($AllowEdit) {
                    $binding.Mode = [System.Windows.Data.BindingMode]::TwoWay
                    $binding.UpdateSourceTrigger = [System.Windows.Data.UpdateSourceTrigger]::LostFocus
                }
                $col.Binding = $binding
                $col.Width = [System.Windows.Controls.DataGridLength]::new(1, [System.Windows.Controls.DataGridLengthUnitType]::Auto)

                # For long text fields, add ellipsis trimming
                $style = [System.Windows.Style]::new([System.Windows.Controls.TextBlock])
                $style.Setters.Add([System.Windows.Setter]::new([System.Windows.Controls.TextBlock]::TextWrappingProperty, [System.Windows.TextWrapping]::NoWrap))
                $style.Setters.Add([System.Windows.Setter]::new([System.Windows.Controls.TextBlock]::TextTrimmingProperty, [System.Windows.TextTrimming]::CharacterEllipsis))
                $style.Setters.Add([System.Windows.Setter]::new([System.Windows.Controls.TextBlock]::MaxWidthProperty, [double]600))
                $col.ElementStyle = $style

                [void]$dgData.Columns.Add($col)
            }
        }

        #  Update Filter Control Visibilities 
        function script:Update-FilterControlVisibilities {
            foreach ($fd in $script:FilterDefinitions) {
                if ($script:VisibleColumns -contains $fd.Name) {
                    $fd.ContainerControl.Visibility = [System.Windows.Visibility]::Visible
                }
                else {
                    $fd.ContainerControl.Visibility = [System.Windows.Visibility]::Collapsed
                }
            }
        }

        #  Column Chooser Dialog 
        function script:Show-ColumnChooser {
            $dialogXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Choose Columns" Height="500" Width="400"
        WindowStartupLocation="CenterOwner" ResizeMode="CanResizeWithGrip"
        Background="{DynamicResource BgApp}" Foreground="{DynamicResource TextPrimary}" FontFamily="Segoe UI" FontSize="13">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="ListBox">
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
        </Style>
    </Window.Resources>
    <Grid Margin="16">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="Select and reorder columns to display:" FontWeight="SemiBold" Margin="0,0,0,10"/>

        <ListBox x:Name="lbColumns" Grid.Row="1" SelectionMode="Single" Margin="0,0,0,10"/>

        <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,0,0,10">
            <Button x:Name="btnMoveUp" Width="80" Margin="0,0,6,0" Padding="8,5">▲ Up</Button>
            <Button x:Name="btnMoveDown" Width="80" Margin="0,0,6,0" Padding="8,5">▼ Down</Button>
            <Button x:Name="btnSelectAll" Width="80" Margin="0,0,6,0" Padding="8,5">Select All</Button>
            <Button x:Name="btnDeselectAll" Width="80" Padding="8,5">Deselect All</Button>
        </StackPanel>

        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right">
            <Button x:Name="btnCancel" Width="90" Margin="0,0,8,0">Cancel</Button>
            <Button x:Name="btnOk" Width="90" Background="#0F766E" Foreground="White">Apply</Button>
        </StackPanel>
    </Grid>
</Window>
"@
            [xml]$dXaml = $dialogXaml
            $dReader = [System.Xml.XmlNodeReader]::new($dXaml)
            $dlg = [Windows.Markup.XamlReader]::Load($dReader)
            foreach ($key in $window.Resources.Keys) { $dlg.Resources[$key] = $window.Resources[$key] }
            $dlg.SetResourceReference([System.Windows.Controls.Control]::BackgroundProperty, "BgApp")
            $dlg.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, "TextPrimary")
            if ($script:IsDarkMode) {
                $val = 1; try { $helper = [System.Windows.Interop.WindowInteropHelper]::new($dlg); [void]$helper.EnsureHandle(); [Dwm]::DwmSetWindowAttribute($helper.Handle, 20, [ref]$val, 4); [Dwm]::DwmSetWindowAttribute($helper.Handle, 19, [ref]$val, 4) } catch {}
            }

            $lbCols = $dlg.FindName('lbColumns')
            $btnUp = $dlg.FindName('btnMoveUp')
            $btnDown = $dlg.FindName('btnMoveDown')
            $btnSelAll = $dlg.FindName('btnSelectAll')
            $btnDeselAll = $dlg.FindName('btnDeselectAll')
            $btnOk = $dlg.FindName('btnOk')
            $btnCancel = $dlg.FindName('btnCancel')

            # Populate with CheckBoxes
            # Show visible columns first (in order), then ALL discovered fields
            $orderedFields = @($script:VisibleColumns)
            foreach ($f in $script:AllDiscoveredFields) {
                if ($orderedFields -notcontains $f) { $orderedFields += $f }
            }

            foreach ($fieldName in $orderedFields) {
                $cb = [System.Windows.Controls.CheckBox]::new()
                $cb.Content = $fieldName
                $cb.IsChecked = ($script:VisibleColumns -contains $fieldName)
                $cb.Tag = $fieldName
                $cb.Margin = [System.Windows.Thickness]::new(4, 3, 4, 3)
                $cb.FontSize = 13
                $cb.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, "TextPrimary")
                [void]$lbCols.Items.Add($cb)
            }

            $btnUp.Add_Click({
                    $idx = $lbCols.SelectedIndex
                    if ($idx -le 0) { return }
                    $item = $lbCols.Items[$idx]
                    $lbCols.Items.RemoveAt($idx)
                    $lbCols.Items.Insert($idx - 1, $item)
                    $lbCols.SelectedIndex = $idx - 1
                }.GetNewClosure())

            $btnDown.Add_Click({
                    $idx = $lbCols.SelectedIndex
                    if ($idx -lt 0 -or $idx -ge ($lbCols.Items.Count - 1)) { return }
                    $item = $lbCols.Items[$idx]
                    $lbCols.Items.RemoveAt($idx)
                    $lbCols.Items.Insert($idx + 1, $item)
                    $lbCols.SelectedIndex = $idx + 1
                }.GetNewClosure())

            $btnSelAll.Add_Click({
                    foreach ($item in $lbCols.Items) { $item.IsChecked = $true }
                }.GetNewClosure())

            $btnDeselAll.Add_Click({
                    foreach ($item in $lbCols.Items) { $item.IsChecked = $false }
                }.GetNewClosure())

            $global:ColumnDialogResult = $false
            $btnCancel.Add_Click({ $dlg.Close() }.GetNewClosure())
            $btnOk.Add_Click({
                    $global:ColumnDialogResult = $true
                    $dlg.Close()
                }.GetNewClosure())

            $dlg.Owner = $script:MainWindow
            $dlg.ShowDialog() | Out-Null

            if ($global:ColumnDialogResult) {
                $newVisible = @()
                foreach ($item in $lbCols.Items) {
                    if ($item.IsChecked) {
                        $newVisible += $item.Tag
                    }
                }
                if ($newVisible.Count -eq 0) {
                    [System.Windows.MessageBox]::Show('At least one column must be selected.', 'Column Selection') | Out-Null
                    return
                }
                $script:VisibleColumns = $newVisible
                script:Build-GridColumns
                script:Update-FilterControlVisibilities
                global:Apply-Filters
            }
        }

        #  Configuration Dialog 
        function script:Show-ConfigDialog {
            if (-not $script:Configuration) { return }

            $configDialogXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Configuration" Height="460" Width="480"
        WindowStartupLocation="CenterOwner" ResizeMode="CanResizeWithGrip"
        Background="{DynamicResource BgApp}" Foreground="{DynamicResource TextPrimary}" FontFamily="Segoe UI" FontSize="13">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
        </Style>
        <Style TargetType="DatePicker">
            <Setter Property="Background" Value="{DynamicResource BgControl}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource StrokeMid}"/>
        </Style>
    </Window.Resources>
    <Grid Margin="16">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="Edit configuration values used by the Refresh script:" FontWeight="SemiBold" Margin="0,0,0,12"/>

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Margin="0,0,0,12">
            <StackPanel x:Name="pnlConfigFields"/>
        </ScrollViewer>

        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right">
            <Button x:Name="btnCfgCancel" Width="90" Margin="0,0,8,0">Cancel</Button>
            <Button x:Name="btnCfgApply" Width="90" Background="#0F766E" Foreground="White">Apply</Button>
        </StackPanel>
    </Grid>
</Window>
"@
            [xml]$cfgXaml = $configDialogXaml
            $cfgReader = [System.Xml.XmlNodeReader]::new($cfgXaml)
            $cfgDlg = [Windows.Markup.XamlReader]::Load($cfgReader)
            foreach ($key in $window.Resources.Keys) { $cfgDlg.Resources[$key] = $window.Resources[$key] }
            $cfgDlg.SetResourceReference([System.Windows.Controls.Control]::BackgroundProperty, "BgApp")
            $cfgDlg.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, "TextPrimary")
            if ($script:IsDarkMode) {
                $val = 1; try { $helper = [System.Windows.Interop.WindowInteropHelper]::new($cfgDlg); [void]$helper.EnsureHandle(); [Dwm]::DwmSetWindowAttribute($helper.Handle, 20, [ref]$val, 4); [Dwm]::DwmSetWindowAttribute($helper.Handle, 19, [ref]$val, 4) } catch {}
            }

            $pnlConfigFields = $cfgDlg.FindName('pnlConfigFields')
            $btnCfgApply = $cfgDlg.FindName('btnCfgApply')
            $btnCfgCancel = $cfgDlg.FindName('btnCfgCancel')

            # Build a control for each configuration key
            # configControls values are either:
            #   - a TextBox  (for text, number, bool, array)
            #   - a hashtable @{ Type='DateTime'; DatePicker=<dp>; TimeBox=<tb|$null> }  (for DateTime)
            $configControls = @{}
            foreach ($key in ($script:Configuration.Keys | Sort-Object)) {
                $val = $script:Configuration[$key]

                # Label
                $lbl = [System.Windows.Controls.TextBlock]::new()
                $lbl.Text = $key
                $lbl.FontSize = 11
                $lbl.FontWeight = 'SemiBold'
                $lbl.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextMuted")
                $lbl.Margin = [System.Windows.Thickness]::new(0, 8, 0, 3)
                [void]$pnlConfigFields.Children.Add($lbl)

                # Detect whether the value is a DateTime
                $isDateTime = ($val -is [DateTime])
                if (-not $isDateTime -and $val -is [string] -and $val.Trim()) {
                    $testDt = [DateTime]::MinValue
                    $isDateTime = [DateTime]::TryParse($val, [ref]$testDt)
                    if ($isDateTime) {
                        # Promote string to actual DateTime so the rest of the logic works
                        $val = $testDt
                        $script:Configuration[$key] = $val
                    }
                }

                # Type hint shown as a subtle tag
                $typeHint = [System.Windows.Controls.TextBlock]::new()
                $typeHint.FontSize = 9
                $typeHint.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextMuted")
                $typeHint.Margin = [System.Windows.Thickness]::new(0, 0, 0, 3)

                if ($isDateTime) {
                    # Determine if the value has a meaningful time component
                    $hasTime = ($val.Hour -ne 0 -or $val.Minute -ne 0 -or $val.Second -ne 0)
                    $typeHint.Text = if ($hasTime) { 'DateTime' } else { 'Date' }
                    [void]$pnlConfigFields.Children.Add($typeHint)

                    # Container for DatePicker (+ optional time TextBox)
                    $dtPanel = [System.Windows.Controls.StackPanel]::new()
                    $dtPanel.Orientation = 'Horizontal'

                    $dp = [System.Windows.Controls.DatePicker]::new()
                    $dp.SelectedDate = [DateTime]$val
                    $dp.Width = 160
                    $dp.SetResourceReference([System.Windows.Controls.Control]::BackgroundProperty, "BgControl")
                    $dp.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, "TextPrimary")
                    $dp.SetResourceReference([System.Windows.Controls.Control]::BorderBrushProperty, "StrokeMid")
                    $dp.BorderThickness = [System.Windows.Thickness]::new(1)
                    [void]$dtPanel.Children.Add($dp)

                    $timeBox = $null
                    if ($hasTime) {
                        $timeLbl = [System.Windows.Controls.TextBlock]::new()
                        $timeLbl.Text = 'Time:'
                        $timeLbl.VerticalAlignment = 'Center'
                        $timeLbl.Margin = [System.Windows.Thickness]::new(10, 0, 4, 0)
                        $timeLbl.FontSize = 11
                        $timeLbl.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextMuted")
                        [void]$dtPanel.Children.Add($timeLbl)

                        $timeBox = [System.Windows.Controls.TextBox]::new()
                        $timeBox.Text = ([DateTime]$val).ToString('HH:mm:ss')
                        $timeBox.Width = 80
                        $timeBox.Padding = [System.Windows.Thickness]::new(6, 4, 6, 4)
                        $timeBox.VerticalAlignment = 'Center'
                        $timeBox.SetResourceReference([System.Windows.Controls.Control]::BorderBrushProperty, "StrokeMid")
                        $timeBox.BorderThickness = [System.Windows.Thickness]::new(1)
                        [void]$dtPanel.Children.Add($timeBox)
                    }

                    [void]$pnlConfigFields.Children.Add($dtPanel)
                    $configControls[$key] = @{ Type = 'DateTime'; DatePicker = $dp; TimeBox = $timeBox }
                }
                elseif ($val -is [array]) {
                    $typeHint.Text = 'Array - separate values with commas'
                    [void]$pnlConfigFields.Children.Add($typeHint)

                    $tb = [System.Windows.Controls.TextBox]::new()
                    $tb.Padding = [System.Windows.Thickness]::new(6, 4, 6, 4)
                    $tb.SetResourceReference([System.Windows.Controls.Control]::BorderBrushProperty, "StrokeMid")
                    $tb.BorderThickness = [System.Windows.Thickness]::new(1)
                    $tb.Text = ($val | ForEach-Object { $_.ToString() }) -join ', '
                    [void]$pnlConfigFields.Children.Add($tb)
                    $configControls[$key] = $tb
                }
                elseif ($val -is [int] -or $val -is [long] -or $val -is [double] -or $val -is [decimal]) {
                    $typeHint.Text = 'Number'
                    [void]$pnlConfigFields.Children.Add($typeHint)

                    $tb = [System.Windows.Controls.TextBox]::new()
                    $tb.Padding = [System.Windows.Thickness]::new(6, 4, 6, 4)
                    $tb.SetResourceReference([System.Windows.Controls.Control]::BorderBrushProperty, "StrokeMid")
                    $tb.BorderThickness = [System.Windows.Thickness]::new(1)
                    $tb.Text = $val.ToString()
                    [void]$pnlConfigFields.Children.Add($tb)
                    $configControls[$key] = $tb
                }
                elseif ($val -is [bool]) {
                    $typeHint.Text = 'Boolean - true / false'
                    [void]$pnlConfigFields.Children.Add($typeHint)

                    $tb = [System.Windows.Controls.TextBox]::new()
                    $tb.Padding = [System.Windows.Thickness]::new(6, 4, 6, 4)
                    $tb.SetResourceReference([System.Windows.Controls.Control]::BorderBrushProperty, "StrokeMid")
                    $tb.BorderThickness = [System.Windows.Thickness]::new(1)
                    $tb.Text = $val.ToString()
                    [void]$pnlConfigFields.Children.Add($tb)
                    $configControls[$key] = $tb
                }
                else {
                    $typeHint.Text = 'Text'
                    [void]$pnlConfigFields.Children.Add($typeHint)

                    $tb = [System.Windows.Controls.TextBox]::new()
                    $tb.Padding = [System.Windows.Thickness]::new(6, 4, 6, 4)
                    $tb.SetResourceReference([System.Windows.Controls.Control]::BorderBrushProperty, "StrokeMid")
                    $tb.BorderThickness = [System.Windows.Thickness]::new(1)
                    $tb.Text = if ($null -ne $val) { $val.ToString() } else { '' }
                    [void]$pnlConfigFields.Children.Add($tb)
                    $configControls[$key] = $tb
                }
            }

            $global:ConfigDialogResult = $false
            $btnCfgCancel.Add_Click({ $cfgDlg.Close() }.GetNewClosure())
            $btnCfgApply.Add_Click({
                    $global:ConfigDialogResult = $true
                    $cfgDlg.Close()
                }.GetNewClosure())

            $cfgDlg.Owner = $script:MainWindow
            $cfgDlg.ShowDialog() | Out-Null

            if ($global:ConfigDialogResult) {
                foreach ($key in $configControls.Keys) {
                    $ctrl = $configControls[$key]
                    $originalVal = $script:Configuration[$key]

                    # DateTime controls store a hashtable with DatePicker and optional TimeBox
                    if ($ctrl -is [hashtable] -and $ctrl.Type -eq 'DateTime') {
                        $dp = $ctrl.DatePicker
                        $timeBox = $ctrl.TimeBox
                        if ($dp.SelectedDate) {
                            $dtVal = [DateTime]$dp.SelectedDate
                            if ($timeBox -and $timeBox.Text.Trim()) {
                                $timeParsed = [DateTime]::MinValue
                                if ([DateTime]::TryParse($timeBox.Text.Trim(), [ref]$timeParsed)) {
                                    $dtVal = [DateTime]::new($dtVal.Year, $dtVal.Month, $dtVal.Day, $timeParsed.Hour, $timeParsed.Minute, $timeParsed.Second)
                                }
                            }
                            $script:Configuration[$key] = $dtVal
                        }
                        continue
                    }

                    # All other control types are plain TextBoxes
                    $textVal = $ctrl.Text

                    # Parse back to the original type
                    if ($originalVal -is [array]) {
                        # Split on commas, trim whitespace, keep non-empty
                        $parts = @($textVal -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
                        # Try to preserve element types (int, etc.)
                        if ($parts.Count -gt 0 -and $originalVal.Count -gt 0) {
                            $elemType = $originalVal[0].GetType()
                            $typed = @($parts | ForEach-Object {
                                    try { [System.Convert]::ChangeType($_, $elemType) } catch { $_ }
                                })
                            $script:Configuration[$key] = $typed
                        }
                        else {
                            $script:Configuration[$key] = $parts
                        }
                    }
                    elseif ($originalVal -is [int]) {
                        $parsed = 0; if ([int]::TryParse($textVal, [ref]$parsed)) { $script:Configuration[$key] = $parsed } else { $script:Configuration[$key] = $textVal }
                    }
                    elseif ($originalVal -is [long]) {
                        $parsed = [long]0; if ([long]::TryParse($textVal, [ref]$parsed)) { $script:Configuration[$key] = $parsed } else { $script:Configuration[$key] = $textVal }
                    }
                    elseif ($originalVal -is [double]) {
                        $parsed = [double]0; if ([double]::TryParse($textVal, [ref]$parsed)) { $script:Configuration[$key] = $parsed } else { $script:Configuration[$key] = $textVal }
                    }
                    elseif ($originalVal -is [bool]) {
                        $script:Configuration[$key] = ($textVal -match '^(true|1|yes)$')
                    }
                    else {
                        $script:Configuration[$key] = $textVal
                    }
                }
                Update-StatusText 'Configuration updated.'
            }
        }

        #  Group By Panel 
        # Optimised: builds all facet dictionaries in a single pass over FilteredItems
        # instead of calling Get-FilteredItems once per ComboBox field.
        function script:Update-GroupByPanel {
            # Read TopN from textbox
            $topN = $script:GroupByTopN
            $topNText = $txtTopN.Text.Trim()
            if ($topNText -match '^\d+$') {
                $topN = [int]$topNText
                if ($topN -lt 1) { $topN = 10 }
                $script:GroupByTopN = $topN
            }

            $pnlGroupBy.Children.Clear()

            # "All rows" header - click resets all filters
            $totalTb = [System.Windows.Controls.TextBlock]::new()
            $totalTb.Text = 'All rows: {0}' -f $script:AllItems.Count
            $totalTb.FontWeight = 'SemiBold'
            $totalTb.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "Accent")
            $totalTb.Cursor = [System.Windows.Input.Cursors]::Hand
            $totalTb.Margin = [System.Windows.Thickness]::new(0, 0, 0, 8)
            $totalTb.Padding = [System.Windows.Thickness]::new(4, 2, 4, 2)
            $totalTb.Tag = [PSCustomObject]@{ Prop = '__ALL__'; Value = ''; Selected = $false }
            $totalTb.Add_MouseEnter({ if (-not $this.Tag.Selected) { $this.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(0xCE, 0xDC, 0xD8)) } })
            $totalTb.Add_MouseLeave({ if ($this.Tag.Selected) { $this.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(0x9E, 0xC9, 0xC4)) } else { $this.Background = [System.Windows.Media.Brushes]::Transparent } })
            $totalTb.Add_MouseLeftButtonUp({
                    # Reset all filters
                    foreach ($fd in $script:FilterDefinitions) {
                        switch ($fd.Type) {
                            'ComboBox' { if ($fd.Control.Items.Count -gt 0) { $fd.Control.SelectedIndex = 0 } }
                            'TextBox' { $fd.Control.Text = '' }
                            'DateTime' {
                                $fd.Control.SelectedDate = $null
                                $fd.ExtraControl.DatePickerTo.SelectedDate = $null
                                $fd.ExtraControl.TimeFrom.Text = '00:00'
                                $fd.ExtraControl.TimeTo.Text = '23:59'
                            }
                        }
                    }
                    global:Apply-Filters
                })
            [void]$pnlGroupBy.Children.Add($totalTb)

            if ($script:AllItems.Count -eq 0) { return }

            # Identify ComboBox fields that need faceted counts
            $comboFields = @($script:FilterDefinitions | Where-Object {
                    $_.Type -eq 'ComboBox' -and $script:VisibleColumns -contains $_.Name
                })
            if ($comboFields.Count -eq 0) {
                script:Update-GroupByHighlight
                return
            }

            # Build all facet counts in a single pass over FilteredItems
            # For proper faceted counts, we use FilteredItems (already filtered)
            # and simply group by each combo field.
            $facetDicts = @{}  # fieldName â†’ Dictionary<string, int>
            foreach ($fd in $comboFields) {
                $facetDicts[$fd.Name] = [System.Collections.Generic.Dictionary[string, int]]::new()
            }

            foreach ($item in $script:FilteredItems) {
                foreach ($fd in $comboFields) {
                    $v = $item."$($fd.Name)"
                    if ($null -ne $v) {
                        $vs = $v.ToString()
                        $dict = $facetDicts[$fd.Name]
                        if ($dict.ContainsKey($vs)) { $dict[$vs]++ }
                        else { $dict[$vs] = 1 }
                    }
                }
            }

            # Render the group-by sections
            foreach ($fd in $comboFields) {
                $capturedProp = $fd.Name
                $dict = $facetDicts[$capturedProp]

                # Section header
                $hdr = [System.Windows.Controls.TextBlock]::new()
                $hdr.Text = "By $capturedProp"
                $hdr.FontSize = 13
                $hdr.FontWeight = 'SemiBold'
                $hdr.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "Accent")
                $hdr.Margin = [System.Windows.Thickness]::new(0, 10, 0, 4)
                [void]$pnlGroupBy.Children.Add($hdr)

                # Sort by count descending, take top N
                $sorted = @($dict.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First $topN)

                foreach ($entry in $sorted) {
                    $capturedValue = $entry.Key
                    $capturedCount = $entry.Value
                    $capturedFD = $fd

                    $tb = [System.Windows.Controls.TextBlock]::new()
                    $tb.Text = '[{0}] {1}' -f $capturedCount, $capturedValue
                    $tb.FontSize = 12
                    $tb.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextPrimary")
                    $tb.Cursor = [System.Windows.Input.Cursors]::Hand
                    $tb.Padding = [System.Windows.Thickness]::new(6, 2, 6, 2)
                    $tb.Margin = [System.Windows.Thickness]::new(0, 1, 0, 1)
                    $tb.Tag = [PSCustomObject]@{ Prop = $capturedProp; Value = $capturedValue; Selected = $false }

                    $tb.Add_MouseEnter({
                            if (-not $this.Tag.Selected) {
                                $this.Background = [System.Windows.Media.SolidColorBrush]::new(
                                    [System.Windows.Media.Color]::FromRgb(0xCE, 0xDC, 0xD8))
                            }
                        })
                    $tb.Add_MouseLeave({
                            if ($this.Tag.Selected) {
                                $this.Background = [System.Windows.Media.SolidColorBrush]::new(
                                    [System.Windows.Media.Color]::FromRgb(0x9E, 0xC9, 0xC4))
                            }
                            else {
                                $this.Background = [System.Windows.Media.Brushes]::Transparent
                            }
                        })

                    # Click handler: toggle filter on the CheckBox
                    $clickHandler = {
                        $cbs = $capturedFD.Control.CheckBoxes
                        $targetCb = $cbs | Where-Object { $_.Content.ToString() -eq $capturedValue } | Select-Object -First 1

                        if ($targetCb) {
                            $isCtrlDown = [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftCtrl) -or [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightCtrl)
                            $checkedCbs = @($cbs | Where-Object { $_.IsChecked })

                            if ($isCtrlDown) {
                                if ($checkedCbs.Count -eq $cbs.Count) {
                                    # If all are checked, a Ctrl+Click implies we want to start a custom selection with just this one (or toggle off?).
                                    # Usually we uncheck all others and keep this one.
                                    foreach ($c in $cbs) { $c.IsChecked = ($c -eq $targetCb) }
                                }
                                else {
                                    # Toggle the state of the target checkbox
                                    $targetCb.IsChecked = -not $targetCb.IsChecked
                                    
                                    # If none are checked now, reset to "All"
                                    if (($cbs | Where-Object { $_.IsChecked }).Count -eq 0) {
                                        foreach ($c in $cbs) { $c.IsChecked = $true }
                                    }
                                }
                            }
                            else {
                                # Normal click
                                # If it's the only one checked, clicking it again should "reset to all"
                                if ($targetCb.IsChecked -and $checkedCbs.Count -eq 1) {
                                    foreach ($c in $cbs) { $c.IsChecked = $true }
                                }
                                else {
                                    # Otherwise, uncheck all others and check this one
                                    foreach ($c in $cbs) { $c.IsChecked = ($c -eq $targetCb) }
                                }
                            }
                        }
                        global:Apply-Filters
                    }.GetNewClosure()

                    $tb.Add_MouseLeftButtonUp($clickHandler)
                    [void]$pnlGroupBy.Children.Add($tb)
                }
            }

            # Highlight active selections
            script:Update-GroupByHighlight
        }

        function script:Update-GroupByHighlight {
            if ($null -eq $pnlGroupBy) { return }
            $selColor = [System.Windows.Media.Color]::FromRgb(0x9E, 0xC9, 0xC4)

            # Check if any filter is active
            $anyFilter = $false
            foreach ($fd in $script:FilterDefinitions) {
                switch ($fd.Type) {
                    'ComboBox' {
                        $unchecked = @($fd.Control.CheckBoxes | Where-Object { -not $_.IsChecked })
                        if ($unchecked.Count -gt 0) { $anyFilter = $true }
                    }
                    'TextBox' { if ($fd.Control.Text.Trim()) { $anyFilter = $true } }
                    'DateTime' {
                        if ($fd.Control.SelectedDate -or $fd.ExtraControl.DatePickerTo.SelectedDate) { $anyFilter = $true }
                    }
                }
            }

            foreach ($child in $pnlGroupBy.Children) {
                if ($child -isnot [System.Windows.Controls.TextBlock]) { continue }
                if ($null -eq $child.Tag) { continue }

                $isSel = $false
                if ($child.Tag.Prop -eq '__ALL__') {
                    $isSel = -not $anyFilter
                }
                else {
                    # Find the filter definition for this property
                    $matchingFD = $script:FilterDefinitions | Where-Object { $_.Name -eq $child.Tag.Prop -and $_.Type -eq 'ComboBox' } | Select-Object -First 1
                    if ($matchingFD) {
                        # Highlight if not ALL are checked, and THIS one IS checked
                        $uncheckedCbs = @($matchingFD.Control.CheckBoxes | Where-Object { -not $_.IsChecked })
                        if ($uncheckedCbs.Count -gt 0) {
                            $checkedCbs = @($matchingFD.Control.CheckBoxes | Where-Object { $_.IsChecked })
                            $isSel = ($checkedCbs | Where-Object { $_.Content.ToString() -eq $child.Tag.Value }) -ne $null
                        }
                    }
                }

                $child.Tag.Selected = $isSel
                if ($isSel) {
                    $child.Background = [System.Windows.Media.SolidColorBrush]::new($selColor)
                    $child.FontWeight = 'Bold'
                }
                else {
                    $child.Background = [System.Windows.Media.Brushes]::Transparent
                    if ($child.Tag.Prop -ne '__ALL__') { $child.FontWeight = 'Normal' }
                }
            }
        }

        #  Copy Functions 
        function script:Copy-SelectedRow {
            if (-not $dgData.SelectedItem) {
                Update-StatusText 'Select a row to copy.'
                return
            }
            $row = $dgData.SelectedItem
            $lines = @()
            foreach ($prop in $row.PSObject.Properties) {
                $val = if ($prop.Name -match '(?i)password|secret|token|apikey|jwt|certificate') { '********' } else { $prop.Value }
                $lines += '{0}: {1}' -f $prop.Name, $val
            }
            [System.Windows.Clipboard]::SetText(($lines -join [Environment]::NewLine)) | Out-Null
            Update-StatusText 'Copied selected row to clipboard.'
        }

        function script:Copy-SelectedDetails {
            if (-not $dgData.SelectedItem) {
                Update-StatusText 'Select a row to copy details.'
                return
            }
            $clone = [ordered]@{}
            foreach ($prop in $dgData.SelectedItem.PSObject.Properties) {
                $clone[$prop.Name] = if ($prop.Name -match '(?i)password|secret|token|apikey|jwt|certificate') { '********' } else { $prop.Value }
            }
            $text = ([PSCustomObject]$clone | Format-List * | Out-String).TrimEnd()
            [System.Windows.Clipboard]::SetText($text) | Out-Null
            Update-StatusText 'Copied selected details to clipboard.'
        }

        #  Pivot 
        function script:Initialize-PivotFields {
            $lbAvailableFields.Items.Clear()
            $lbRowFields.Items.Clear()
            $lbColumnFields.Items.Clear()
            foreach ($f in $script:AllDiscoveredFields) {
                [void]$lbAvailableFields.Items.Add($f)
            }
        }

        function script:Move-ListBoxItem {
            param($LB, $Dir)
            if ($null -eq $LB.SelectedItem) { return }
            $idx = $LB.SelectedIndex
            $new = $idx + $Dir
            if ($new -lt 0 -or $new -ge $LB.Items.Count) { return }
            $item = $LB.SelectedItem
            $LB.Items.RemoveAt($idx)
            $LB.Items.Insert($new, $item)
            $LB.SelectedIndex = $new
        }

        function script:Add-FieldToList {
            param($Target)
            if ($null -eq $lbAvailableFields.SelectedItem) { return }
            $f = $lbAvailableFields.SelectedItem.ToString()
            $existing = @($Target.Items | ForEach-Object { $_.ToString() })
            if ($existing -notcontains $f) { [void]$Target.Items.Add($f) }
        }

        function script:Build-PivotData {
            if ($script:FilteredItems.Count -eq 0) {
                $dgPivot.ItemsSource = $null
                Update-StatusText 'No data to pivot.'
                return
            }
            if ($script:PivotBuildJob -and $script:PivotBuildJob.State -in @('Running', 'NotStarted')) { return }

            $rowFields = @($lbRowFields.Items | ForEach-Object { $_.ToString() })
            $colFields = @($lbColumnFields.Items | ForEach-Object { $_.ToString() })
            if ($rowFields.Count -eq 0) {
                $dgPivot.ItemsSource = $null
                Update-StatusText 'Add row fields to pivot.'
                return
            }

            $jobScript = {
                param($Events, $RowFields, $ColFields, $ShowTotals)
                if ($null -eq $Events -or $Events.Count -eq 0) { return @() }

                if ($ColFields.Count -eq 0) {
                    $rows = @($Events | Group-Object -Property $RowFields | Sort-Object Count -Descending | ForEach-Object {
                            $parts = $_.Name -split ', '
                            $o = [ordered]@{}
                            for ($i = 0; $i -lt $RowFields.Count; $i++) { $o[$RowFields[$i]] = $parts[$i] }
                            $o['Count'] = $_.Count
                            [PSCustomObject]$o
                        })
                    if ($ShowTotals) {
                        $tr = [ordered]@{}
                        foreach ($rf in $RowFields) { $tr[$rf] = 'TOTAL' }
                        $tr['Count'] = $Events.Count
                        $rows += [PSCustomObject]$tr
                    }
                    return @($rows)
                }

                $rowGroups = $Events | Group-Object -Property $RowFields | Sort-Object Name
                $colKeys = $Events | Group-Object -Property $ColFields | Sort-Object Name | Select-Object -ExpandProperty Name
                $rows = @($rowGroups | ForEach-Object {
                        $rparts = $_.Name -split ', '
                        $o = [ordered]@{}
                        for ($i = 0; $i -lt $RowFields.Count; $i++) { $o[$RowFields[$i]] = $rparts[$i] }
                        $total = 0
                        foreach ($ck in $colKeys) {
                            $cnt = ($_.Group | Group-Object -Property $ColFields | Where-Object { $_.Name -eq $ck } | Select-Object -ExpandProperty Count -First 1)
                            if ($null -eq $cnt) { $cnt = 0 }
                            $o[$ck] = $cnt
                            $total += $cnt
                        }
                        if ($ShowTotals) { $o['TOTAL'] = $total }
                        [PSCustomObject]$o
                    })
                if ($ShowTotals) {
                    $sortedRows = @($rows | Sort-Object -Property $RowFields)
                    $tr = [ordered]@{}
                    foreach ($rf in $RowFields) { $tr[$rf] = 'TOTAL' }
                    foreach ($ck in $colKeys) {
                        $tr[$ck] = ($Events | Group-Object -Property $ColFields | Where-Object { $_.Name -eq $ck } | Select-Object -ExpandProperty Count -First 1)
                    }
                    $tr['TOTAL'] = $Events.Count
                    $sortedRows += [PSCustomObject]$tr
                    return @($sortedRows)
                }
                return @($rows | Sort-Object -Property $RowFields)
            }

            Update-StatusText 'Building pivot...'
            $script:PivotBuildJob = Start-Job -Name 'DynamicPivotBuild' -ScriptBlock $jobScript -ArgumentList @($script:FilteredItems), $rowFields, $colFields, ([bool]$chkShowTotals.IsChecked)

            if (-not $script:PivotBuildTimer) {
                $script:PivotBuildTimer = [System.Windows.Threading.DispatcherTimer]::new()
                $script:PivotBuildTimer.Interval = [TimeSpan]::FromMilliseconds(250)
                $script:PivotBuildTimer.Add_Tick({
                        if (-not $script:PivotBuildJob) { return }
                        if ($script:PivotBuildJob.State -eq 'Completed') {
                            try {
                                $pivotResult = @(Receive-Job -Job $script:PivotBuildJob -Keep)
                                # Remove PS job metadata
                                $script:PivotData = @($pivotResult | ForEach-Object {
                                        if ($null -eq $_) { return }
                                        $sanitized = [ordered]@{}
                                        foreach ($property in $_.PSObject.Properties) {
                                            if ($property.Name -notmatch '^PS' -and $property.Name -notin @('RunspaceId', 'PSComputerName', 'PSShowComputerName')) {
                                                $sanitized[$property.Name] = $property.Value
                                            }
                                        }
                                        [PSCustomObject]$sanitized
                                    })
                                $dgPivot.ItemsSource = $script:PivotData
                                Update-StatusText 'Pivot applied.'
                            }
                            catch {
                                $script:PivotData = @()
                                $dgPivot.ItemsSource = $null
                                Update-StatusText 'Pivot build failed.'
                                [System.Windows.MessageBox]::Show($_.Exception.Message, 'Pivot Error') | Out-Null
                            }
                            finally {
                                if ($script:PivotBuildJob) { Remove-Job -Job $script:PivotBuildJob -Force | Out-Null }
                                $script:PivotBuildJob = $null
                                $script:PivotBuildTimer.Stop()
                            }
                        }
                        elseif ($script:PivotBuildJob.State -in @('Failed', 'Stopped')) {
                            $script:PivotData = @()
                            $dgPivot.ItemsSource = $null
                            Update-StatusText 'Pivot build failed.'
                            if ($script:PivotBuildJob) { Remove-Job -Job $script:PivotBuildJob -Force | Out-Null }
                            $script:PivotBuildJob = $null
                            $script:PivotBuildTimer.Stop()
                        }
                    })
            }
            $script:PivotBuildTimer.Start()
        }

        #  Export 
        function script:Export-Collection {
            param([array]$Data, [string]$Default)
            if ($Data.Count -eq 0) {
                [System.Windows.MessageBox]::Show('No data to export.', 'Export') | Out-Null
                return
            }
            $d = New-Object Microsoft.Win32.SaveFileDialog
            $d.Filter = 'CSV files (*.csv)|*.csv'
            $d.FileName = $Default
            if ($d.ShowDialog()) {
                # Sanitize data to prevent Excel Formula Injection
                $sanitizedData = foreach ($item in $Data) {
                    if ($null -eq $item) { continue }
                    $clone = [ordered]@{}
                    foreach ($p in $item.PSObject.Properties) {
                        $val = $p.Value
                        if ($val -is [string] -and $val -match '^(=|\+|-|@)') {
                            $clone[$p.Name] = "'$val"
                        }
                        else {
                            $clone[$p.Name] = $val
                        }
                    }
                    [PSCustomObject]$clone
                }
                $sanitizedData | Export-Csv $d.FileName -Delimiter ';' -NoTypeInformation -Encoding UTF8
                $folder = Split-Path $d.FileName -Parent
                if ($folder -and (Test-Path $folder)) {
                    try { Start-Process -FilePath 'explorer.exe' -ArgumentList "/select,`"$($d.FileName)`"" -WindowStyle Hidden | Out-Null } catch {}
                }
                Update-StatusText ('Exported {0} rows to {1}' -f $Data.Count, $d.FileName)
            }
        }

        function script:Format-Value {
            param($val)
            if ($null -eq $val) { return '' }
            if ($val -is [string] -or $val -is [int] -or $val -is [long] -or $val -is [double] -or $val -is [decimal] -or $val -is [bool] -or $val -is [DateTime]) {
                return $val
            }
            if ($val -is [System.Collections.IEnumerable] -and $val -isnot [string]) {
                try {
                    $arr = [System.Collections.Generic.List[string]]::new()
                    foreach ($item in $val) {
                        $s = script:Format-Value -val $item
                        if ($null -ne $s -and $s.ToString() -ne '') { $arr.Add($s.ToString()) }
                        if ($arr.Count -ge 50) { $arr.Add("... (truncated)"); break }
                    }
                    return ($arr -join ', ')
                }
                catch {
                    return "(Collection)"
                }
            }
            
            try {
                $str = $val.ToString()
                $typeName = $val.GetType().FullName
                
                $isDefaultToString = ($null -eq $typeName) -or ($str -eq $typeName) -or ($str.StartsWith("$typeName ")) -or ($str.StartsWith("$typeName("))
                
                if ($isDefaultToString) {
                    if ($val -is [System.Runtime.InteropServices.SafeHandle]) {
                        if ($val.IsInvalid) { return 'Invalid Handle' }
                        if ($val.IsClosed) { return 'Closed Handle' }
                        return "Handle: $($val.DangerousGetHandle())"
                    }

                    foreach ($propName in @('ModuleName', 'DisplayName', 'Name', 'FileName', 'Title', 'Value', 'Id')) {
                        if ($null -ne $val.PSObject.Properties[$propName]) {
                            $pVal = $val.PSObject.Properties[$propName].Value
                            if ($null -ne $pVal) {
                                $innerVal = if ($pVal -is [string]) { $pVal } else { $pVal.ToString() }
                                return $innerVal
                            }
                        }
                    }
                }
                return $str
            }
            catch {
                return "(Error reading value)"
            }
        }

        #  Load Data 
        function script:Load-Data {
            param([array]$Items)

            $isRefresh = ($script:AllDiscoveredFields -and $script:AllDiscoveredFields.Count -gt 0)
            
            # Save Selection Signature
            $selectedSignature = $null
            if ($isRefresh -and $dgData.SelectedItem -and $script:SearchCache -and $script:SearchCache.ContainsKey($dgData.SelectedItem)) {
                $selectedSignature = $script:SearchCache[$dgData.SelectedItem]
            }

            if ($null -eq $script:SearchCache) {
                $script:SearchCache = [System.Collections.Generic.Dictionary[object, string]]::new()
            }
            else {
                $script:SearchCache.Clear()
            }

            # Flatten arrays to strings
            $processedItems = foreach ($item in $Items) {
                if ($null -eq $item) { continue }
                $clone = [ordered]@{}
                $txt = [System.Text.StringBuilder]::new()
                foreach ($p in $item.PSObject.Properties) {
                    $val = script:Format-Value -val $p.Value
                    $clone[$p.Name] = $val
                    [void]$txt.Append($val)
                    [void]$txt.Append(' ')
                }
                $obj = [PSCustomObject]$clone
                $script:SearchCache[$obj] = $txt.ToString()
                $obj
            }

            $script:AllItems = @($processedItems)
            $script:FilteredItems = @($processedItems)

            if ($Items.Count -eq 0) {
                $pnlFilterContent.Children.Clear()
                $script:FilterDefinitions = @()
                $dgData.Columns.Clear()
                $dgData.ItemsSource = $null
                $lbAvailableFields.Items.Clear()
                $lblCount.Text = '0 items'
                Update-StatusText 'No data loaded.'
                script:Update-EmptyState
                script:Update-DetailPane
                return
            }

            # Save state
            $savedFilters = @{}
            $savedSorts = @()
            $savedCols = @{}
            if ($isRefresh) {
                # Save Sort
                if ($dgData.Items.SortDescriptions) {
                    foreach ($sd in $dgData.Items.SortDescriptions) { $savedSorts += $sd }
                }
                
                # Save Columns Order and Size
                $sortedCols = @($dgData.Columns | Sort-Object DisplayIndex)
                $newVisible = [System.Collections.Generic.List[string]]::new()
                foreach ($col in $sortedCols) {
                    $header = $col.Header.ToString()
                    $newVisible.Add($header)
                    $savedCols[$header] = @{
                        Width = if ($col.Width.IsAbsolute) { $col.Width.Value } elseif ($col.Width.IsAuto) { 'Auto' } elseif ($col.Width.IsSizeToCells) { 'SizeToCells' } elseif ($col.Width.IsSizeToHeader) { 'SizeToHeader' } elseif ($col.Width.IsStar) { 'Star' } else { 'Auto' }
                    }
                }
                foreach ($vc in $script:VisibleColumns) {
                    if (-not $newVisible.Contains($vc)) { $newVisible.Add($vc) }
                }
                $script:VisibleColumns = $newVisible
                
                # Save Filters
                foreach ($fd in $script:FilterDefinitions) {
                    $state = @{}
                    switch ($fd.Type) {
                        'TextBox' { $state.Text = $fd.Control.Text }
                        'ComboBox' {
                            $state.Unchecked = @()
                            foreach ($c in $fd.Control.CheckBoxes) {
                                if (-not $c.IsChecked) { $state.Unchecked += $c.Content.ToString() }
                            }
                        }
                        'DateTime' {
                            $state.FromDate = $fd.Control.SelectedDate
                            $state.ToDate = $fd.ExtraControl.DatePickerTo.SelectedDate
                            $state.FromTime = $fd.ExtraControl.TimeFrom.Text
                            $state.ToTime = $fd.ExtraControl.TimeTo.Text
                        }
                    }
                    $savedFilters[$fd.Name] = $state
                }
            }

            # Detect schema
            $schema = script:Initialize-DynamicSchema -Items $processedItems

            # Preserve the full discovered field list (never filtered)
            $script:AllDiscoveredFields = @($script:AllFieldNames)

            # Build filter controls (for ALL fields so they remain available)
            script:Build-FilterControls -Schema $schema -Items $processedItems

            if ($isRefresh) {
                # Restore Filters
                foreach ($fd in $script:FilterDefinitions) {
                    if ($savedFilters.Contains($fd.Name)) {
                        $state = $savedFilters[$fd.Name]
                        switch ($fd.Type) {
                            'TextBox' { $fd.Control.Text = $state.Text }
                            'ComboBox' {
                                foreach ($c in $fd.Control.CheckBoxes) {
                                    if ($state.Unchecked -contains $c.Content.ToString()) {
                                        $c.IsChecked = $false
                                    }
                                }
                            }
                            'DateTime' {
                                $fd.Control.SelectedDate = $state.FromDate
                                $fd.ExtraControl.DatePickerTo.SelectedDate = $state.ToDate
                                $fd.ExtraControl.TimeFrom.Text = $state.FromTime
                                $fd.ExtraControl.TimeTo.Text = $state.ToTime
                            }
                        }
                    }
                }
                
                # We do not reset $script:VisibleColumns to ALL Discovered fields here,
                # we keep it to what was saved from the previous DataGrid state!
                # Just ensure any visible column actually exists in the new schema:
                $script:VisibleColumns = @($script:VisibleColumns | Where-Object { $script:AllDiscoveredFields -contains $_ })
                if ($script:VisibleColumns.Count -eq 0) { $script:VisibleColumns = @($script:AllDiscoveredFields) }
            }
            else {
                # Column initialization logic ...
                # If -Columns was supplied, pre-select only matching columns;
                # otherwise prefer the source object's default display properties when available.
                $defaultVisibleColumns = @(
                    script:Get-DefaultVisibleColumns -Items $Items |
                    Where-Object { $script:AllDiscoveredFields -contains $_ }
                )

                if ($script:RequestedColumns -and $script:RequestedColumns.Count -gt 0) {
                    $validCols = @($script:RequestedColumns | Where-Object { $script:AllDiscoveredFields -contains $_ })
                    if ($validCols.Count -gt 0) {
                        $script:VisibleColumns = $validCols
                    }
                    else {
                        $script:VisibleColumns = @($script:AllDiscoveredFields)
                    }
                }
                elseif ($defaultVisibleColumns.Count -gt 0) {
                    $script:VisibleColumns = @($defaultVisibleColumns)
                }
                else {
                    $script:VisibleColumns = @($script:AllDiscoveredFields)
                }
            }

            script:Build-GridColumns
            
            if ($isRefresh) {
                # Restore column widths
                foreach ($col in $dgData.Columns) {
                    $header = $col.Header.ToString()
                    if ($savedCols.Contains($header)) {
                        $w = $savedCols[$header].Width
                        if ($w -is [double] -or $w -is [int]) {
                            $col.Width = [System.Windows.Controls.DataGridLength]::new([double]$w)
                        }
                        elseif ($w -is [string]) {
                            switch ($w) {
                                'Auto' { $col.Width = [System.Windows.Controls.DataGridLength]::new(1, [System.Windows.Controls.DataGridLengthUnitType]::Auto) }
                                'SizeToCells' { $col.Width = [System.Windows.Controls.DataGridLength]::new(1, [System.Windows.Controls.DataGridLengthUnitType]::SizeToCells) }
                                'SizeToHeader' { $col.Width = [System.Windows.Controls.DataGridLength]::new(1, [System.Windows.Controls.DataGridLengthUnitType]::SizeToHeader) }
                                'Star' { $col.Width = [System.Windows.Controls.DataGridLength]::new(1, [System.Windows.Controls.DataGridLengthUnitType]::Star) }
                            }
                        }
                    }
                }
            }
            
            script:Update-FilterControlVisibilities

            # Populate pivot available fields
            script:Initialize-PivotFields

            # Populate chart available fields
            $cmbChartField.Items.Clear()
            foreach ($f in $script:AllDiscoveredFields) { [void]$cmbChartField.Items.Add($f) }
            if ($cmbChartField.Items.Count -gt 0) { $cmbChartField.SelectedIndex = 0 }

            # Show data
            $dgData.ItemsSource = $script:FilteredItems
            
            # Restore sort
            if ($isRefresh -and $savedSorts.Count -gt 0) {
                foreach ($sd in $savedSorts) {
                    $dgData.Items.SortDescriptions.Add($sd)
                }
            }
            
            # Restore Selection
            if ($null -ne $selectedSignature) {
                foreach ($item in $script:FilteredItems) {
                    if ($script:SearchCache.ContainsKey($item) -and $script:SearchCache[$item] -eq $selectedSignature) {
                        $dgData.SelectedItem = $item
                        try { $dgData.ScrollIntoView($item) } catch {}
                        break
                    }
                }
            }
            
            # Apply ColorMapping if provided
            if ($script:ColorMapping) {
                # Remove existing handler to avoid duplicates
                $dgData.Remove_LoadingRow($script:ColorMappingHandler)
                $script:ColorMappingHandler = {
                    param($sender, $e)
                    $row = $e.Row
                    $item = $row.Item
                    if ($null -eq $item -or $item -isnot [PSCustomObject]) { return }

                    $matchedColor = $null
                    foreach ($prop in $script:ColorMapping.Keys) {
                        $mapping = $script:ColorMapping[$prop]
                        if ($mapping -isnot [hashtable]) { continue }
                        
                        $val = $item.$prop
                        if ($null -eq $val) { continue }
                        $valStr = $val.ToString()
                        
                        if ($mapping.ContainsKey($valStr)) {
                            $matchedColor = $mapping[$valStr]
                            break
                        }
                    }

                    if ($matchedColor) {
                        try {
                            $brush = [System.Windows.Media.SolidColorBrush]::new(
                                [System.Windows.Media.ColorConverter]::ConvertFromString($matchedColor)
                            )
                            $row.Background = $brush
                            $row.Foreground = [System.Windows.Media.Brushes]::Black
                        }
                        catch {}
                    }
                    else {
                        $row.ClearValue([System.Windows.Controls.Control]::BackgroundProperty)
                        $row.ClearValue([System.Windows.Controls.Control]::ForegroundProperty)
                    }
                }
                $dgData.Add_LoadingRow($script:ColorMappingHandler)
            }

            $lblCount.Text = '{0} items' -f $Items.Count
            Update-StatusText ('Loaded {0} items with {1} fields.' -f $Items.Count, $script:AllFieldNames.Count)
            script:Update-EmptyState
            script:Update-DetailPane
            script:Update-GroupByPanel
        }

        #  Charts 
        function script:Build-Chart {
            $canvasChart.Children.Clear()
            if ($script:FilteredItems.Count -eq 0) {
                Update-StatusText 'No data to chart.'
                return
            }

            $fieldName = $null
            if ($cmbChartField.SelectedItem) { $fieldName = $cmbChartField.SelectedItem.ToString() }
            if (-not $fieldName) { return }

            $chartType = $cmbChartType.SelectedItem.ToString()
            $topN = 15
            if ($txtChartTopN.Text -match '^\d+$') { $topN = [int]$txtChartTopN.Text }
            if ($topN -le 0) { $topN = 15 }

            $showOther = ([bool]$chkChartShowOther.IsChecked)

            Update-StatusText 'Building chart...'

            $totalCount = $script:FilteredItems.Count
            $chartData = [System.Collections.Generic.List[PSCustomObject]]::new()

            if ($chartType -eq 'Line') {
                # Line chart: sort by Name/Date ascending, plot all points up to a limit
                $groups = $script:FilteredItems | Group-Object -Property $fieldName | Sort-Object Name
                $limit = [Math]::Max($topN, 100) # Plot at least 100 points, or TopN if larger
                $pts = if ($groups.Count -gt $limit) { $groups | Select-Object -First $limit } else { $groups }
                foreach ($g in $pts) {
                    $name = $g.Name
                    if ([string]::IsNullOrWhiteSpace($name)) { $name = '(Empty)' }
                    $chartData.Add([PSCustomObject]@{
                            Name    = $name
                            Count   = $g.Count
                            Percent = ($g.Count / $totalCount) * 100
                        })
                }
            }
            else {
                # Group and count for other charts
                $groups = $script:FilteredItems | Group-Object -Property $fieldName | Sort-Object Count -Descending
                $otherCount = 0
                for ($i = 0; $i -lt $groups.Count; $i++) {
                    if ($i -lt $topN) {
                        $name = $groups[$i].Name
                        if ([string]::IsNullOrWhiteSpace($name)) { $name = '(Empty)' }
                        $chartData.Add([PSCustomObject]@{
                                Name    = $name
                                Count   = $groups[$i].Count
                                Percent = ($groups[$i].Count / $totalCount) * 100
                            })
                    }
                    else {
                        $otherCount += $groups[$i].Count
                    }
                }

                if ($showOther -and $otherCount -gt 0) {
                    $chartData.Add([PSCustomObject]@{
                            Name    = 'Other'
                            Count   = $otherCount
                            Percent = ($otherCount / $totalCount) * 100
                        })
                }
            }

            if ($chartData.Count -eq 0) { return }

            $maxCount = ($chartData | Measure-Object -Property Count -Maximum).Maximum
            if ($maxCount -eq 0) { return }

            # Render logic
            $canvasWidth = if ($canvasChart.ActualWidth -gt 0) { $canvasChart.ActualWidth } else { 800 }
            $canvasHeight = if ($canvasChart.ActualHeight -gt 0) { $canvasChart.ActualHeight } else { 400 }
            $margin = 40

            switch ($chartType) {
                'Bar' {
                    $usableWidth = $canvasWidth - ($margin * 2)
                    $usableHeight = $canvasHeight - ($margin * 2)
                    $barWidth = ($usableWidth / $chartData.Count) * 0.8
                    $spacing = ($usableWidth / $chartData.Count) * 0.2
                    $startX = $margin + ($spacing / 2)

                    for ($i = 0; $i -lt $chartData.Count; $i++) {
                        $item = $chartData[$i]
                        $barHeight = ($item.Count / $maxCount) * $usableHeight
                        $colorHex = $script:ChartColors[$i % $script:ChartColors.Count]
                        $brush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($colorHex))

                        $rect = [System.Windows.Controls.Border]::new()
                        $rect.Background = $brush
                        $rect.Width = $barWidth
                        $rect.Height = $barHeight
                        $rect.CornerRadius = [System.Windows.CornerRadius]::new(4, 4, 0, 0)
                        $rect.ToolTip = "{0}: {1} ({2:N1}%)" -f $item.Name, $item.Count, $item.Percent

                        [System.Windows.Controls.Canvas]::SetLeft($rect, $startX)
                        [System.Windows.Controls.Canvas]::SetTop($rect, $canvasHeight - $margin - $barHeight)
                        [void]$canvasChart.Children.Add($rect)

                        # Label (rotated if needed, for simplicity just a TextBlock here)
                        $lbl = [System.Windows.Controls.TextBlock]::new()
                        $lbl.Text = if ($item.Name.Length -gt 15) { $item.Name.Substring(0, 12) + "..." } else { $item.Name }
                        $lbl.Width = $barWidth + $spacing
                        $lbl.TextAlignment = 'Center'
                        $lbl.FontSize = 11
                        $lbl.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextPrimary")
                        
                        [System.Windows.Controls.Canvas]::SetLeft($lbl, $startX - ($spacing / 2))
                        [System.Windows.Controls.Canvas]::SetTop($lbl, $canvasHeight - $margin + 5)
                        [void]$canvasChart.Children.Add($lbl)

                        # Value text
                        $valTxt = [System.Windows.Controls.TextBlock]::new()
                        $valTxt.Text = $item.Count.ToString()
                        $valTxt.FontSize = 10
                        $valTxt.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextMuted")
                        $valTxt.Width = $barWidth
                        $valTxt.TextAlignment = 'Center'
                        [System.Windows.Controls.Canvas]::SetLeft($valTxt, $startX)
                        [System.Windows.Controls.Canvas]::SetTop($valTxt, $canvasHeight - $margin - $barHeight - 15)
                        [void]$canvasChart.Children.Add($valTxt)

                        $startX += $barWidth + $spacing
                    }
                }

                'Horizontal Bar' {
                    $usableWidth = $canvasWidth - ($margin * 2) - 100 # extra margin for labels
                    $usableHeight = $canvasHeight - ($margin * 2)
                    $barHeight = ($usableHeight / $chartData.Count) * 0.8
                    $spacing = ($usableHeight / $chartData.Count) * 0.2
                    $startY = $margin + ($spacing / 2)

                    for ($i = 0; $i -lt $chartData.Count; $i++) {
                        $item = $chartData[$i]
                        $barWidth = ($item.Count / $maxCount) * $usableWidth
                        $colorHex = $script:ChartColors[$i % $script:ChartColors.Count]
                        $brush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($colorHex))

                        # Label
                        $lbl = [System.Windows.Controls.TextBlock]::new()
                        $lbl.Text = if ($item.Name.Length -gt 20) { $item.Name.Substring(0, 17) + "..." } else { $item.Name }
                        $lbl.Width = 100
                        $lbl.TextAlignment = 'Right'
                        $lbl.FontSize = 11
                        $lbl.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextPrimary")
                        [System.Windows.Controls.Canvas]::SetLeft($lbl, $margin - 10)
                        [System.Windows.Controls.Canvas]::SetTop($lbl, $startY + ($barHeight / 2) - 8)
                        [void]$canvasChart.Children.Add($lbl)

                        $rect = [System.Windows.Controls.Border]::new()
                        $rect.Background = $brush
                        $rect.Height = $barHeight
                        $rect.Width = $barWidth
                        $rect.CornerRadius = [System.Windows.CornerRadius]::new(0, 4, 4, 0)
                        $rect.ToolTip = "{0}: {1} ({2:N1}%)" -f $item.Name, $item.Count, $item.Percent

                        [System.Windows.Controls.Canvas]::SetLeft($rect, $margin + 100)
                        [System.Windows.Controls.Canvas]::SetTop($rect, $startY)
                        [void]$canvasChart.Children.Add($rect)

                        # Value text
                        $valTxt = [System.Windows.Controls.TextBlock]::new()
                        $valTxt.Text = $item.Count.ToString()
                        $valTxt.FontSize = 10
                        $valTxt.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextMuted")
                        [System.Windows.Controls.Canvas]::SetLeft($valTxt, $margin + 100 + $barWidth + 5)
                        [System.Windows.Controls.Canvas]::SetTop($valTxt, $startY + ($barHeight / 2) - 7)
                        [void]$canvasChart.Children.Add($valTxt)

                        $startY += $barHeight + $spacing
                    }
                }

                'Pie' {
                    $centerX = $canvasWidth / 2
                    $centerY = $canvasHeight / 2
                    $radius = [Math]::Min($canvasWidth, $canvasHeight) / 2.5
                    $currentAngle = 0

                    $legendX = $centerX + $radius + 40
                    $legendY = $centerY - $radius

                    for ($i = 0; $i -lt $chartData.Count; $i++) {
                        $item = $chartData[$i]
                        if ($item.Count -eq 0) { continue }

                        $sweepAngle = ($item.Count / $totalCount) * 360
                        if ($sweepAngle -eq 360) { $sweepAngle = 359.99 } # WPF arc rendering bug workaround
                        
                        $endAngle = $currentAngle + $sweepAngle
                        
                        $startRad = [Math]::PI * ($currentAngle - 90) / 180.0
                        $endRad = [Math]::PI * ($endAngle - 90) / 180.0
                        
                        $startX = $centerX + $radius * [Math]::Cos($startRad)
                        $startY = $centerY + $radius * [Math]::Sin($startRad)
                        $endX = $centerX + $radius * [Math]::Cos($endRad)
                        $endY = $centerY + $radius * [Math]::Sin($endRad)

                        $isLargeArc = $sweepAngle -gt 180
                        
                        $colorHex = $script:ChartColors[$i % $script:ChartColors.Count]
                        $brush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($colorHex))

                        $path = [System.Windows.Shapes.Path]::new()
                        $path.Fill = $brush
                        $path.ToolTip = "{0}: {1} ({2:N1}%)" -f $item.Name, $item.Count, $item.Percent
                        
                        $geom = [System.Windows.Media.PathGeometry]::new()
                        $fig = [System.Windows.Media.PathFigure]::new()
                        $fig.StartPoint = [System.Windows.Point]::new($centerX, $centerY)
                        $fig.IsClosed = $true
                        
                        $fig.Segments.Add([System.Windows.Media.LineSegment]::new([System.Windows.Point]::new($startX, $startY), $false))
                        
                        $arc = [System.Windows.Media.ArcSegment]::new()
                        $arc.Point = [System.Windows.Point]::new($endX, $endY)
                        $arc.Size = [System.Windows.Size]::new($radius, $radius)
                        $arc.IsLargeArc = $isLargeArc
                        $arc.SweepDirection = [System.Windows.Media.SweepDirection]::Clockwise
                        $fig.Segments.Add($arc)
                        
                        $geom.Figures.Add($fig)
                        $path.Data = $geom
                        
                        [void]$canvasChart.Children.Add($path)

                        # Legend
                        $legRect = [System.Windows.Controls.Border]::new()
                        $legRect.Background = $brush
                        $legRect.Width = 12
                        $legRect.Height = 12
                        [System.Windows.Controls.Canvas]::SetLeft($legRect, $legendX)
                        [System.Windows.Controls.Canvas]::SetTop($legRect, $legendY)
                        [void]$canvasChart.Children.Add($legRect)
                        
                        $legLbl = [System.Windows.Controls.TextBlock]::new()
                        $legTxt = if ($item.Name.Length -gt 25) { $item.Name.Substring(0, 22) + "..." } else { $item.Name }
                        $legLbl.Text = "{0} ({1:N1}%)" -f $legTxt, $item.Percent
                        $legLbl.FontSize = 11
                        $legLbl.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextPrimary")
                        [System.Windows.Controls.Canvas]::SetLeft($legLbl, $legendX + 20)
                        [System.Windows.Controls.Canvas]::SetTop($legLbl, $legendY - 2)
                        [void]$canvasChart.Children.Add($legLbl)
                        
                        $legendY += 20
                        $currentAngle = $endAngle
                    }
                }

                'Line' {
                    $usableWidth = $canvasWidth - ($margin * 2)
                    $usableHeight = $canvasHeight - ($margin * 2)
                    
                    $stepX = if ($chartData.Count -gt 1) { $usableWidth / ($chartData.Count - 1) } else { $usableWidth }
                    
                    $points = [System.Windows.Media.PointCollection]::new()
                    $brushLine = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#0F766E'))

                    for ($i = 0; $i -lt $chartData.Count; $i++) {
                        $item = $chartData[$i]
                        $px = $margin + ($i * $stepX)
                        $py = $canvasHeight - $margin - (($item.Count / $maxCount) * $usableHeight)
                        $points.Add([System.Windows.Point]::new($px, $py))
                        
                        # Data point circle
                        $ellipse = [System.Windows.Shapes.Ellipse]::new()
                        $ellipse.Width = 8
                        $ellipse.Height = 8
                        $ellipse.Fill = $brushLine
                        $ellipse.ToolTip = "{0}: {1} ({2:N1}%)" -f $item.Name, $item.Count, $item.Percent
                        [System.Windows.Controls.Canvas]::SetLeft($ellipse, $px - 4)
                        [System.Windows.Controls.Canvas]::SetTop($ellipse, $py - 4)
                        [void]$canvasChart.Children.Add($ellipse)

                        # Label (skip some if too many to prevent overlapping)
                        $skipRate = [Math]::Ceiling($chartData.Count / 20.0)
                        if ($i % $skipRate -eq 0) {
                            $lbl = [System.Windows.Controls.TextBlock]::new()
                            $lbl.Text = if ($item.Name.Length -gt 12) { $item.Name.Substring(0, 10) + ".." } else { $item.Name }
                            $lbl.FontSize = 10
                            $lbl.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "TextPrimary")
                            $lbl.RenderTransform = [System.Windows.Media.RotateTransform]::new(-45)
                            [System.Windows.Controls.Canvas]::SetLeft($lbl, $px - 10)
                            [System.Windows.Controls.Canvas]::SetTop($lbl, $canvasHeight - $margin + 5)
                            [void]$canvasChart.Children.Add($lbl)
                        }
                    }
                    
                    $polyline = [System.Windows.Shapes.Polyline]::new()
                    $polyline.Points = $points
                    $polyline.Stroke = $brushLine
                    $polyline.StrokeThickness = 2
                    [void]$canvasChart.Children.Add($polyline)
                }
            }
            Update-StatusText 'Chart built.'
        }

        #endregion

        #region Wire Events

        if (-not ([System.Management.Automation.PSTypeName]'Dwm').Type) {
            try {
                Add-Type -TypeDefinition @"
                using System;
                using System.Runtime.InteropServices;
                public class Dwm {
                    [DllImport("dwmapi.dll", PreserveSig = true)]
                    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);
                }
"@ -ErrorAction Ignore
            }
            catch {}
        }

        # Settings
        $script:SettingsPath = Join-Path $env:APPDATA 'DynamicDataViewer'
        $script:SettingsFile = Join-Path $script:SettingsPath 'settings.json'

        function script:Load-Settings {
            try {
                if (Test-Path $script:SettingsFile) {
                    $json = Get-Content $script:SettingsFile -Raw -ErrorAction Stop
                    $settings = $json | ConvertFrom-Json -ErrorAction Stop
                    if ($null -ne $settings.IsDarkMode) {
                        $script:IsDarkMode = [bool]$settings.IsDarkMode
                    }
                }
            }
            catch {
                Write-Warning "Failed to load settings: $($_.Exception.Message)"
            }
        }

        function script:Save-Settings {
            try {
                if (-not (Test-Path $script:SettingsPath)) {
                    New-Item -ItemType Directory -Path $script:SettingsPath -Force -ErrorAction Stop | Out-Null
                }
                $settings = @{ IsDarkMode = $script:IsDarkMode }
                $settings | ConvertTo-Json -Depth 2 -ErrorAction Stop | Set-Content $script:SettingsFile -Encoding UTF8 -ErrorAction Stop
            }
            catch {
                Write-Warning "Failed to save settings: $($_.Exception.Message)"
            }
        }

        function script:Apply-Theme {
            $win = $script:MainWindow
            $btn = $win.FindName('btnTheme')
            if ($script:IsDarkMode) {
                $btn.Content = '☀️ Light Mode'
                $val = 1; 
                try { $helper = [System.Windows.Interop.WindowInteropHelper]::new($win); $null = [Dwm]::DwmSetWindowAttribute($helper.Handle, 20, [ref]$val, 4); $null = [Dwm]::DwmSetWindowAttribute($helper.Handle, 19, [ref]$val, 4) } catch {}
                $win.Resources['BgApp'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#0F172A'))
                $win.Resources['BgPanel'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#1E293B'))
                $win.Resources['BgSubtle'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#0F172A'))
                $win.Resources['BgControl'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#334155'))
                $win.Resources['BgControlHover'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#475569'))
                $win.Resources['TextPrimary'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#F8FAFC'))
                $win.Resources['TextMuted'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#94A3B8'))
                $win.Resources['StrokeSoft'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#334155'))
                $win.Resources['StrokeMid'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#475569'))
            }
            else {
                $btn.Content = '🌙 Dark Mode'
                $val = 0; 
                try { $helper = [System.Windows.Interop.WindowInteropHelper]::new($win); $null = [Dwm]::DwmSetWindowAttribute($helper.Handle, 20, [ref]$val, 4); $null = [Dwm]::DwmSetWindowAttribute($helper.Handle, 19, [ref]$val, 4) } catch {}
                $win.Resources['BgApp'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#F3F5F7'))
                $win.Resources['BgPanel'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#FFFFFF'))
                $win.Resources['BgSubtle'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#F8FAFC'))
                $win.Resources['BgControl'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#FFFFFF'))
                $win.Resources['BgControlHover'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#EEF2F7'))
                $win.Resources['TextPrimary'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#111827'))
                $win.Resources['TextMuted'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#6B7280'))
                $win.Resources['StrokeSoft'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#E5E7EB'))
                $win.Resources['StrokeMid'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString('#D1D5DB'))
            }
        }

        script:Load-Settings
        script:Apply-Theme

        # Theme Toggle
        $btnTheme.Add_Click({
                $script:IsDarkMode = -not $script:IsDarkMode
                script:Apply-Theme
                script:Save-Settings
            })

        # Toggle filter panel
        $btnToggleFilterPanel.Add_Click({
                $isCollapsed = ($pnlFilterContent.Visibility -eq [System.Windows.Visibility]::Collapsed)
                $pnlFilterContent.Visibility = if ($isCollapsed) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
                $btnToggleFilterPanel.Content = if ($isCollapsed) { 'Hide Filters' } else { 'Show Filters' }
            }.GetNewClosure())

        # Reset filters
        $btnReset.Add_Click({
                if ($txtSearchAll) { $txtSearchAll.Text = '' }
                foreach ($fd in $script:FilterDefinitions) {
                    switch ($fd.Type) {
                        'ComboBox' {
                            foreach ($c in $fd.Control.CheckBoxes) { $c.IsChecked = $true }
                            $fd.Control.ToggleButton.Content = '(All)'
                            $fd.Control.ToggleButton.IsChecked = $false
                            $fd.Control.Popup.IsOpen = $false
                        }
                        'TextBox' { $fd.Control.Text = '' }
                        'DateTime' {
                            $fd.Control.SelectedDate = $null
                            $fd.ExtraControl.DatePickerTo.SelectedDate = $null
                            $fd.ExtraControl.TimeFrom.Text = '00:00'
                            $fd.ExtraControl.TimeTo.Text = '23:59'
                        }
                    }
                }
                global:Apply-Filters
                Update-StatusText 'Filters reset.'
            })

        # Refresh button - runs the RefreshScript asynchronously via Start-Job
        $btnRefresh.Add_Click({
                if ($script:RefreshScript) {
                    # Prevent double-clicks while a refresh is already running
                    if ($script:RefreshJob -and $script:RefreshJob.State -eq 'Running') {
                        Update-StatusText 'Refresh already in progress!'
                        return
                    }

                    $pbLoading.Visibility = 'Visible'
                    $btnRefresh.IsEnabled = $false
                    $script:RefreshStartTime = [DateTime]::Now
                    Update-StatusText 'Refreshing data in background!'

                    # Build a wrapper scriptblock that injects configuration
                    # variables so the user's RefreshScript can use $Servers, $MaxElements, etc.
                    $jobScript = $script:RefreshScript
                    if ($script:Configuration -and $script:Configuration.Count -gt 0) {
                        $preambleLines = @()
                        foreach ($cfgKey in $script:Configuration.Keys) {
                            $cfgVal = $script:Configuration[$cfgKey]
                            if ($cfgVal -is [array]) {
                                # Build an array literal: @('val1','val2')
                                $escaped = @($cfgVal | ForEach-Object { "'$($_.ToString().Replace("'","''"))'" })
                                $preambleLines += "`$$cfgKey = @($($escaped -join ','))"
                            }
                            elseif ($cfgVal -is [DateTime]) {
                                # Serialize as a round-trippable DateTime literal
                                $dtStr = ([DateTime]$cfgVal).ToString('o')
                                $preambleLines += "`$$cfgKey = [DateTime]::Parse('$dtStr')"
                            }
                            elseif ($cfgVal -is [int] -or $cfgVal -is [long]) {
                                $preambleLines += "`$$cfgKey = $cfgVal"
                            }
                            elseif ($cfgVal -is [double] -or $cfgVal -is [decimal]) {
                                $preambleLines += "`$$cfgKey = $cfgVal"
                            }
                            elseif ($cfgVal -is [bool]) {
                                $preambleLines += "`$$cfgKey = `$$($cfgVal.ToString().ToLower())"
                            }
                            else {
                                $preambleLines += "`$$cfgKey = '$($cfgVal.ToString().Replace("'","''"))'"
                            }
                        }
                        $fullBody = ($preambleLines -join "`n") + "`n" + $script:RefreshScript.ToString()
                        $jobScript = [scriptblock]::Create($fullBody)
                    }

                    # Launch the scriptblock in a background job
                    $script:RefreshJob = Start-Job -Name 'DataViewerRefresh' -ScriptBlock $jobScript

                    # Set up a DispatcherTimer to poll the job and update the status bar
                    if (-not $script:RefreshTimer) {
                        $script:RefreshTimer = [System.Windows.Threading.DispatcherTimer]::new()
                        $script:RefreshTimer.Interval = [TimeSpan]::FromMilliseconds(300)
                        $script:RefreshTimer.Add_Tick({
                                if (-not $script:RefreshJob) { $script:RefreshTimer.Stop(); return }

                                # Show elapsed time in the status bar
                                $elapsed = ([DateTime]::Now - $script:RefreshStartTime)
                                $elapsedText = '{0:mm\:ss}' -f $elapsed
                                $lblStatus.Text = 'Refreshing data! ({0})' -f $elapsedText

                                # Check for timeout (e.g. 5 minutes)
                                if ($elapsed.TotalMinutes -gt 5) {
                                    $script:RefreshTimer.Stop()
                                    Stop-Job -Job $script:RefreshJob -Force | Out-Null
                                    Remove-Job -Job $script:RefreshJob -Force | Out-Null
                                    $script:RefreshJob = $null
                                    $pbLoading.Visibility = 'Collapsed'
                                    $btnRefresh.IsEnabled = $true
                                    Update-StatusText 'Refresh timed out after 5 minutes.'
                                    [System.Windows.MessageBox]::Show('The background refresh job exceeded the 5-minute timeout limit and was canceled.', 'Timeout', 'OK', 'Warning') | Out-Null
                                    return
                                }

                                if ($script:RefreshJob.State -eq 'Completed') {
                                    $script:RefreshTimer.Stop()
                                    try {
                                        $newData = @(Receive-Job -Job $script:RefreshJob)
                                        # Strip PS job metadata properties
                                        $cleanData = @($newData | ForEach-Object {
                                                if ($null -eq $_) { return }
                                                $clean = [ordered]@{}
                                                foreach ($p in $_.PSObject.Properties) {
                                                    if ($p.Name -notmatch '^PS' -and $p.Name -notin @('RunspaceId', 'PSComputerName', 'PSShowComputerName')) {
                                                        $clean[$p.Name] = $p.Value
                                                    }
                                                }
                                                [PSCustomObject]$clean
                                            })
                                        script:Load-Data -Items $cleanData
                                        $lastRefresh = (Get-Date).ToString('HH:mm:ss')
                                        Update-StatusText ('Last refreshed: {0} | Duration: {1}' -f $lastRefresh, $elapsedText)
                                    }
                                    catch {
                                        Update-StatusText ('Refresh error: {0}' -f $_.Exception.Message)
                                        [System.Windows.MessageBox]::Show($_.Exception.Message, 'Refresh Error') | Out-Null
                                    }
                                    finally {
                                        Remove-Job -Job $script:RefreshJob -Force -ErrorAction SilentlyContinue | Out-Null
                                        $script:RefreshJob = $null
                                        $pbLoading.Visibility = 'Collapsed'
                                        $btnRefresh.IsEnabled = $true
                                    }
                                }
                                elseif ($script:RefreshJob.State -in @('Failed', 'Stopped')) {
                                    $script:RefreshTimer.Stop()
                                    $errMsg = 'Refresh job failed.'
                                    try {
                                        $jobError = Receive-Job -Job $script:RefreshJob -ErrorAction SilentlyContinue 2>&1
                                        if ($jobError) { $errMsg = ($jobError | Out-String).Trim() }
                                    }
                                    catch {}
                                    Update-StatusText ('Refresh failed after {0}: {1}' -f $elapsedText, $errMsg)
                                    Remove-Job -Job $script:RefreshJob -Force -ErrorAction SilentlyContinue | Out-Null
                                    $script:RefreshJob = $null
                                    $pbLoading.Visibility = 'Collapsed'
                                    $btnRefresh.IsEnabled = $true
                                }
                            })
                    }
                    $script:RefreshTimer.Start()
                }
                else {
                    Update-StatusText 'No RefreshScript provided. Pass -RefreshScript parameter.'
                }
            })

        # Auto-Refresh Timer
        if ($script:RefreshScript) {
            $script:AutoRefreshTimer = [System.Windows.Threading.DispatcherTimer]::new()
            $script:AutoRefreshTimer.Add_Tick({
                    $btn = $script:MainWindow.FindName('btnRefresh')
                    if ($btn -and $btn.IsEnabled) {
                        $btn.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                    }
                })
            $cmbAutoRefresh.Add_SelectionChanged({
                    $script:AutoRefreshTimer.Stop()
                    $idx = $this.SelectedIndex
                    if ($idx -eq 1) {
                        $script:AutoRefreshTimer.Interval = [TimeSpan]::FromSeconds(5)
                        $script:AutoRefreshTimer.Start()
                    }
                    elseif ($idx -eq 2) {
                        $script:AutoRefreshTimer.Interval = [TimeSpan]::FromSeconds(30)
                        $script:AutoRefreshTimer.Start()
                    }
                    elseif ($idx -eq 3) {
                        $script:AutoRefreshTimer.Interval = [TimeSpan]::FromMinutes(1)
                        $script:AutoRefreshTimer.Start()
                    }
                })
        }
        else {
            $cmbAutoRefresh.Visibility = 'Collapsed'
        }

        # Column chooser
        $btnColumns.Add_Click({ script:Show-ColumnChooser })

        # Configuration dialog
        $btnConfig.Add_Click({ script:Show-ConfigDialog })

        # Copy buttons
        $btnCopyRow.Add_Click({ script:Copy-SelectedRow })
        $btnCopyDetails.Add_Click({ script:Copy-SelectedDetails })

        # ──────────────────────────────────────────────────────────────────────
        #region Custom Actions
        $script:RowActionButtons = @()

        if ($Actions -and $Actions.Count -gt 0) {
            foreach ($action in $Actions) {
                $actionName = if ($action.Icon) { "$($action.Icon) $($action.Name)" } else { $action.Name }
                $actionScope = if ($action.Scope) { $action.Scope } else { 'Row' }
                $actionScript = $action.Script
                $returnToGrid = [bool]$action.ReturnToGrid

                if ($actionScope -eq 'DoubleClick') {
                    $dgData.Tag = @{ Script = $actionScript; ReturnToGrid = $returnToGrid }
                    $dgData.Add_MouseDoubleClick({
                            param($sender, $e)
                            if (-not $sender.SelectedItem) { return }
                            $meta = $sender.Tag
                            $sb = $meta.Script
                            $rtg = $meta.ReturnToGrid
                            
                            $actionContext = @{
                                SelectedRow   = $sender.SelectedItem
                                AllData       = $script:AllItems
                                FilteredData  = $script:FilteredItems
                                Window        = $script:MainWindow
                                Configuration = $script:Configuration
                            }

                            try {
                                $result = & $sb $sender.SelectedItem $actionContext
                                if ($rtg) {
                                    $btnRef = $script:MainWindow.FindName('btnRefresh')
                                    if ($btnRef -and $btnRef.IsEnabled) {
                                        $btnRef.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                                    }
                                    if ($result -and $result -is [string]) { Update-StatusText $result }
                                }
                                elseif ($result) {
                                    if ($result -is [string]) {
                                        [System.Windows.MessageBox]::Show($result, 'Action Result', 'OK', 'Information') | Out-Null
                                    }
                                    else {
                                        $text = ($result | Out-String).Trim()
                                        [System.Windows.MessageBox]::Show($text, 'Action Result', 'OK', 'Information') | Out-Null
                                    }
                                }
                            }
                            catch {
                                [System.Windows.MessageBox]::Show("Action failed: $($_.Exception.Message)", "Error", "OK", "Error") | Out-Null
                            }
                        })
                    continue
                }

                $btn = [System.Windows.Controls.Button]::new()
                $btn.Content = $actionName
                $btn.Padding = [System.Windows.Thickness]::new(10, 6, 10, 6)
                $btn.Margin = [System.Windows.Thickness]::new(0, 0, 6, 0)
                $btn.Tag = @{ Script = $actionScript; Scope = $actionScope; ReturnToGrid = $returnToGrid }

                $btn.Add_Click({
                        param($sender, $e)
                        $meta = $sender.Tag
                        $scope = $meta.Scope
                        $sb = $meta.Script
                        $rtg = $meta.ReturnToGrid

                        try {
                            $actionContext = @{
                                SelectedRow   = $dgData.SelectedItem
                                AllData       = $script:AllItems
                                FilteredData  = $script:FilteredItems
                                Window        = $script:MainWindow
                                Configuration = $script:Configuration
                            }

                            if ($scope -eq 'Row') {
                                $selectedItem = $dgData.SelectedItem
                                if (-not $selectedItem) {
                                    [System.Windows.MessageBox]::Show('Please select a row first.', 'No Row Selected', 'OK', 'Information') | Out-Null
                                    return
                                }
                                $result = & $sb $selectedItem $actionContext
                            }
                            else {
                                $result = & $sb $script:FilteredItems $actionContext
                            }

                            # Handle results
                            if ($rtg) {
                                # Refresh the grid to reflect property changes
                                $dgData.Items.Refresh()
                                # Check if new columns were added and rebuild if needed
                                $sampleItem = if ($scope -eq 'Row') { $dgData.SelectedItem } else { $script:FilteredItems | Select-Object -First 1 }
                                if ($sampleItem) {
                                    $newProps = @($sampleItem.PSObject.Properties.Name | Where-Object { $_ -notin $script:AllDiscoveredFields })
                                    if ($newProps.Count -gt 0) {
                                        foreach ($propName in $newProps) {
                                            $script:AllDiscoveredFields += $propName
                                            $script:AllFieldNames += $propName
                                            $script:VisibleColumns += $propName
                                        }
                                    
                                        $schema = script:Initialize-DynamicSchema -Items $script:AllItems
                                        script:Build-FilterControls -Schema $schema -Items $script:AllItems
                                        script:Build-GridColumns
                                        script:Update-FilterControlVisibilities
                                        script:Initialize-PivotFields
                                    
                                        $cmbChartField.Items.Clear()
                                        foreach ($f in $script:AllDiscoveredFields) { [void]$cmbChartField.Items.Add($f) }
                                        if ($cmbChartField.Items.Count -gt 0) { $cmbChartField.SelectedIndex = 0 }
                                    }
                                }
                                if ($result -and $result -is [string]) {
                                    Update-StatusText $result
                                }
                                else {
                                    Update-StatusText ('Action completed. Grid refreshed.')
                                }
                            }
                            elseif ($result) {
                                if ($result -is [string]) {
                                    [System.Windows.MessageBox]::Show($result, 'Action Result', 'OK', 'Information') | Out-Null
                                }
                                else {
                                    $text = ($result | Out-String).Trim()
                                    [System.Windows.MessageBox]::Show($text, 'Action Result', 'OK', 'Information') | Out-Null
                                }
                            }
                            else {
                                Update-StatusText 'Action completed.'
                            }
                        }
                        catch {
                            [System.Windows.MessageBox]::Show("Action failed: $($_.Exception.Message)", 'Action Error', 'OK', 'Error') | Out-Null
                        }
                    })

                if ($actionScope -eq 'Row' -or $actionScope -eq 'Both') {
                    $pnlRowActions.Children.Add($btn)
                    $script:RowActionButtons += $btn
                    if ($actionScope -eq 'Row') {
                        $btn.IsEnabled = $false  # Disabled until a row is selected
                    }
                }
                if ($actionScope -eq 'Dataset' -or $actionScope -eq 'Both') {
                    if ($actionScope -eq 'Both') {
                        # Clone the button for the dataset panel
                        $btn2 = [System.Windows.Controls.Button]::new()
                        $btn2.Content = $actionName
                        $btn2.Padding = [System.Windows.Thickness]::new(10, 6, 10, 6)
                        $btn2.Margin = [System.Windows.Thickness]::new(0, 0, 6, 0)
                        $btn2.Tag = @{ Script = $actionScript; Scope = 'Dataset'; ReturnToGrid = $returnToGrid }
                        $btn2.Add_Click({
                                param($sender, $e)
                                $meta = $sender.Tag
                                $sb = $meta.Script
                                $rtg = $meta.ReturnToGrid

                                try {
                                    $actionContext = @{
                                        SelectedRow  = $dgData.SelectedItem
                                        AllData      = $script:AllItems
                                        FilteredData = $script:FilteredItems
                                        Window       = $script:MainWindow
                                    }
                                    $result = & $sb $script:FilteredItems $actionContext

                                    if ($rtg) {
                                        $dgData.Items.Refresh()
                                    
                                        # Check if new columns were added and rebuild if needed
                                        $sampleItem = $script:FilteredItems | Select-Object -First 1
                                        if ($sampleItem) {
                                            $newProps = @($sampleItem.PSObject.Properties.Name | Where-Object { $_ -notin $script:AllDiscoveredFields })
                                            if ($newProps.Count -gt 0) {
                                                foreach ($propName in $newProps) {
                                                    $script:AllDiscoveredFields += $propName
                                                    $script:AllFieldNames += $propName
                                                    $script:VisibleColumns += $propName
                                                }
                                            
                                                $schema = script:Initialize-DynamicSchema -Items $script:AllItems
                                                script:Build-FilterControls -Schema $schema -Items $script:AllItems
                                                script:Build-GridColumns
                                                script:Update-FilterControlVisibilities
                                                script:Initialize-PivotFields
                                            
                                                $cmbChartField.Items.Clear()
                                                foreach ($f in $script:AllDiscoveredFields) { [void]$cmbChartField.Items.Add($f) }
                                                if ($cmbChartField.Items.Count -gt 0) { $cmbChartField.SelectedIndex = 0 }
                                            }
                                        }

                                        if ($result -and $result -is [string]) { Update-StatusText $result }
                                        else { Update-StatusText 'Action completed. Grid refreshed.' }
                                    }
                                    elseif ($result) {
                                        if ($result -is [string]) {
                                            [System.Windows.MessageBox]::Show($result, 'Action Result', 'OK', 'Information') | Out-Null
                                        }
                                        else {
                                            $text = ($result | Out-String).Trim()
                                            [System.Windows.MessageBox]::Show($text, 'Action Result', 'OK', 'Information') | Out-Null
                                        }
                                    }
                                    else { Update-StatusText 'Action completed.' }
                                }
                                catch {
                                    [System.Windows.MessageBox]::Show("Action failed: $($_.Exception.Message)", 'Action Error', 'OK', 'Error') | Out-Null
                                }
                            })
                        $pnlDatasetActions.Children.Add($btn2)
                    }
                    else {
                        $pnlDatasetActions.Children.Add($btn)
                    }
                }
            }

            # Show containers if they have children
            if ($pnlRowActions.Children.Count -gt 0) {
                $sepRowActions.Visibility = 'Visible'
                $pnlRowActions.Visibility = 'Visible'
            }
            if ($pnlDatasetActions.Children.Count -gt 0) {
                $sepDatasetActions.Visibility = 'Visible'
                $pnlDatasetActions.Visibility = 'Visible'
            }
        }
        #endregion

        # DataGrid selection → detail pane + enable/disable row action buttons
        $dgData.Add_SelectionChanged({
                script:Update-DetailPane
                $hasSelection = ($null -ne $dgData.SelectedItem)
                foreach ($btn in $script:RowActionButtons) {
                    $btn.IsEnabled = $hasSelection
                }
            })

        # DataGrid cell-edit commit → manually push value & update filters/group-by
        $dgData.Add_CellEditEnding({
                param($s, $e)
                if ($e.EditAction -eq [System.Windows.Controls.DataGridEditAction]::Commit) {
                    # Get the column name from the header
                    $colName = $e.Column.Header.ToString()
                    # Get the editing element (TextBox) and read the new value
                    $editElement = $e.EditingElement
                    $newValue = $null
                    if ($editElement -is [System.Windows.Controls.TextBox]) {
                        $newValue = $editElement.Text
                    }
                    # Get the row item and push the value manually
                    $rowItem = $e.Row.Item
                    if ($rowItem -and $colName -and $null -ne $newValue) {
                        $rowItem."$colName" = $newValue
                    }
                    # Use dispatcher to refresh after the DataGrid finishes its internal commit
                    $script:MainWindow.Dispatcher.InvokeAsync([Action] {
                            script:Update-DynamicFilters
                            global:Apply-Filters
                        }, [System.Windows.Threading.DispatcherPriority]::Background) | Out-Null
                }
            })

        # Export buttons
        $btnExportRows.Add_Click({ script:Export-Collection $script:FilteredItems ('DataExport_{0}.csv' -f (Get-Date -Format 'yyyyMMdd_HHmmss')) })
        $btnExportPivot.Add_Click({ script:Export-Collection $script:PivotData ('PivotExport_{0}.csv' -f (Get-Date -Format 'yyyyMMdd_HHmmss')) })

        # Pivot buttons
        $btnAddRowField.Add_Click({ script:Add-FieldToList $lbRowFields })
        $btnAddColumnField.Add_Click({ script:Add-FieldToList $lbColumnFields })
        $btnRemoveRowField.Add_Click({ if ($lbRowFields.SelectedItem) { $lbRowFields.Items.Remove($lbRowFields.SelectedItem) } })
        $btnRemoveColumnField.Add_Click({ if ($lbColumnFields.SelectedItem) { $lbColumnFields.Items.Remove($lbColumnFields.SelectedItem) } })
        $btnMoveRowUp.Add_Click({ script:Move-ListBoxItem $lbRowFields -1 })
        $btnMoveRowDown.Add_Click({ script:Move-ListBoxItem $lbRowFields 1 })
        $btnMoveColumnUp.Add_Click({ script:Move-ListBoxItem $lbColumnFields -1 })
        $btnMoveColumnDown.Add_Click({ script:Move-ListBoxItem $lbColumnFields 1 })
        $btnClearPivotFields.Add_Click({ $lbRowFields.Items.Clear(); $lbColumnFields.Items.Clear(); $dgPivot.ItemsSource = $null })
        $btnApplyPivot.Add_Click({ script:Build-PivotData })

        # Chart buttons
        $btnRefreshChart.Add_Click({ script:Build-Chart })
        $btnExportChart.Add_Click({
                if ($canvasChart.Children.Count -eq 0) {
                    Update-StatusText 'No chart to export.'
                    return
                }
                $d = New-Object Microsoft.Win32.SaveFileDialog
                $d.Filter = 'PNG Image (*.png)|*.png'
                $d.FileName = 'ChartExport_{0}.png' -f (Get-Date -Format 'yyyyMMdd_HHmmss')
                if ($d.ShowDialog()) {
                    try {
                        $width = [int]$canvasChart.ActualWidth
                        $height = [int]$canvasChart.ActualHeight
                        if ($width -eq 0 -or $height -eq 0) {
                            Update-StatusText 'Chart size is zero, cannot export.'
                            return
                        }
                    
                        $canvasChart.Measure([System.Windows.Size]::new($width, $height))
                        $canvasChart.Arrange([System.Windows.Rect]::new(0, 0, $width, $height))

                        $rtb = [System.Windows.Media.Imaging.RenderTargetBitmap]::new($width, $height, 96, 96, [System.Windows.Media.PixelFormats]::Pbgra32)
                        $rtb.Render($canvasChart)
                    
                        $encoder = [System.Windows.Media.Imaging.PngBitmapEncoder]::new()
                        $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($rtb))
                    
                        $fs = [System.IO.File]::Create($d.FileName)
                        $encoder.Save($fs)
                        $fs.Close()
                    
                        Update-StatusText ('Chart exported to {0}' -f $d.FileName)
                    }
                    catch {
                        [System.Windows.MessageBox]::Show("Failed to export chart: $($_.Exception.Message)", 'Export Error') | Out-Null
                    }
                }
            })

        # TopN change triggers group-by refresh
        $txtTopN.Add_TextChanged({ script:Schedule-FilterApply })

        # Global Search TextBox TextChanged
        if ($txtSearchAll) {
            $txtSearchAll.Add_TextChanged({ script:Schedule-FilterApply })
        }

        # Keyboard shortcut: Ctrl+F focuses the global Search TextBox or first TextBox filter
        $window.Add_KeyDown({
                if ($_.Key -eq [System.Windows.Input.Key]::F -and [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftCtrl)) {
                    if ($txtSearchAll) {
                        $txtSearchAll.Focus() | Out-Null
                        $txtSearchAll.SelectAll()
                    }
                    else {
                        $firstTextFilter = $script:FilterDefinitions | Where-Object { $_.Type -eq 'TextBox' } | Select-Object -First 1
                        if ($firstTextFilter) {
                            $firstTextFilter.Control.Focus() | Out-Null
                            $firstTextFilter.Control.SelectAll()
                        }
                    }
                    $_.Handled = $true
                }
            })

        #endregion

        #region Initial Data Load
        if ($inputData.Count -gt 0) {
            script:Load-Data -Items $inputData
        }
        else {
            script:Update-EmptyState
        }
        #endregion
        
        # Clean up background jobs when the window closes
        $window.Add_Closed({
                if ($script:RefreshTimer) { $script:RefreshTimer.Stop() }
                if ($script:RefreshJob) {
                    Stop-Job -Job $script:RefreshJob -ErrorAction SilentlyContinue | Out-Null
                    Remove-Job -Job $script:RefreshJob -Force -ErrorAction SilentlyContinue | Out-Null
                    $script:RefreshJob = $null
                }
                if ($script:PivotBuildTimer) { $script:PivotBuildTimer.Stop() }
                if ($script:PivotBuildJob) {
                    Stop-Job -Job $script:PivotBuildJob -ErrorAction SilentlyContinue | Out-Null
                    Remove-Job -Job $script:PivotBuildJob -Force -ErrorAction SilentlyContinue | Out-Null
                    $script:PivotBuildJob = $null
                }
            })

        $window.ShowDialog() | Out-Null
    }
}