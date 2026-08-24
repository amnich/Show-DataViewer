---
script_name: json_manager.ps1
relative_path: Show-DataViewer/Examples/json_manager.ps1
category: Examples
webjea_enabled: true
parameters:
  - None
---

# json_manager.ps1

## Purpose
json_manager.ps1

## Parameters
| Parameter | Type | Mandatory | Default |
| :--- | :--- | :--- | :--- |
| None | N/A | N/A | N/A |

## Execution & Cmdlets Used
* `Add-Member`
* `Add-NodeRow`
* `Add-Type`
* `ConvertFrom-Json`
* `ConvertFrom-JsonEditedValue`
* `ConvertTo-Json`
* `ConvertTo-JsonLeafString`
* `Get-Content`
* `Get-JsonNodeByPath`
* `Get-JsonRows`
* `Get-NodeChildCount`
* `Get-NodeTypeName`
* `Get-ParentJsonPath`
* `Join-Path`
* `New-Object`
* `Select-Object`
* `Set-Clipboard`
* `Set-Content`
* `Set-JsonNodeByPath`
* `Show-DataViewer`
* `Split-PathLeafLike`
* `Test-Path`
* `Where-Object`
* WebJEA detection signals: HTML or JSON-oriented output.

## Security & Impact Notes
* Impact level: Medium - state-changing operations detected.
* Delegation/permission guidance: No explicit permissions guidance was found in comment-based help; validate the WebJEA/JEA run identity and apply least privilege.
