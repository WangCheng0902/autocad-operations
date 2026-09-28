[CmdletBinding()]
param(
    [switch]$RemoveMcp,
    [switch]$RemoveDependencies,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'
$marketplaceName = 'autocad-operations-marketplace'
$dataRoot = Join-Path $env:LOCALAPPDATA 'autocad-operations'

function Confirm-Step([string]$Message) {
    if ($Yes) { return $true }
    return (Read-Host "$Message [y/N]") -match '^(y|yes)$'
}

& codex plugin remove "autocad-operations@$marketplaceName"
& codex plugin marketplace remove $marketplaceName

if ($RemoveMcp -and (Confirm-Step 'Remove the multicad MCP registration?')) {
    & codex mcp remove multicad
}

if ($RemoveDependencies -and (Test-Path -LiteralPath $dataRoot) -and
    (Confirm-Step "Remove plugin-managed dependencies and logs under $dataRoot?")) {
    $resolved = (Resolve-Path -LiteralPath $dataRoot).Path
    $expected = (Join-Path $env:LOCALAPPDATA 'autocad-operations')
    if ($resolved -ne $expected) { throw "Refusing to remove unexpected path: $resolved" }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}

Write-Host 'Uninstall completed. Existing Codex configuration backups were preserved.' -ForegroundColor Green
