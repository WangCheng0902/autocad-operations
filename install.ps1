[CmdletBinding()]
param(
    [switch]$Yes,
    [switch]$DryRun,
    [string]$MultiCadPath
)

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot
$marketplaceName = 'autocad-operations-marketplace'
$pluginSelector = "autocad-operations@$marketplaceName"
$dataRoot = Join-Path $env:LOCALAPPDATA 'autocad-operations'
$logRoot = Join-Path $dataRoot 'logs'
$dependencyRoot = Join-Path $dataRoot 'dependencies'
$defaultMultiCad = Join-Path $dependencyRoot 'multiCAD-mcp'
$venvRoot = Join-Path $dataRoot 'venvs\multicad'
$configPath = Join-Path $env:USERPROFILE '.codex\config.toml'

function Write-Step([string]$Message) {
    Write-Host "[autocad-operations] $Message" -ForegroundColor Cyan
}

function Confirm-Step([string]$Message) {
    if ($Yes) { return $true }
    $answer = Read-Host "$Message [y/N]"
    return $answer -match '^(y|yes)$'
}

function Invoke-Checked([string]$Command, [string[]]$Arguments) {
    if ($DryRun) {
        Write-Host "DRY-RUN: $Command $($Arguments -join ' ')"
        return
    }
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed ($LASTEXITCODE): $Command $($Arguments -join ' ')"
    }
}

if ($env:OS -ne 'Windows_NT') {
    throw 'Version 0.1 supports Windows 11 only.'
}

$os = Get-CimInstance Win32_OperatingSystem
if ([version]$os.Version -lt [version]'10.0.22000') {
    throw "Windows 11 is required. Detected: $($os.Caption) $($os.Version)"
}

foreach ($command in @('git', 'codex', 'python')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command is missing: $command"
    }
}

$pythonVersion = & python -c "import sys; print('.'.join(map(str, sys.version_info[:3])))"
if ([version]$pythonVersion -lt [version]'3.10.0') {
    throw "Python 3.10 or newer is required. Detected: $pythonVersion"
}

$acadCandidates = @(
    'C:\Program Files\Autodesk\AutoCAD 2023\acad.exe',
    'C:\Program Files\Autodesk\AutoCAD 2023\accoreconsole.exe'
)
if (-not ($acadCandidates | Where-Object { Test-Path -LiteralPath $_ })) {
    Write-Warning 'AutoCAD 2023 was not found at the standard location. Installation will continue, but CAD operations may be unavailable.'
}

New-Item -ItemType Directory -Force -Path $logRoot, $dependencyRoot, (Split-Path $venvRoot -Parent) | Out-Null
$transcriptPath = Join-Path $logRoot ("install-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
if (-not $DryRun) { Start-Transcript -LiteralPath $transcriptPath | Out-Null }

try {
    Write-Step 'Backing up the current Codex configuration.'
    if (Test-Path -LiteralPath $configPath) {
        $backupPath = "$configPath.autocad-operations.$(Get-Date -Format 'yyyyMMdd-HHmmss').bak"
        if ($DryRun) { Write-Host "DRY-RUN: backup $configPath -> $backupPath" }
        else { Copy-Item -LiteralPath $configPath -Destination $backupPath -Force }
    }

    if (-not $MultiCadPath) {
        $sibling = Join-Path (Split-Path $repoRoot -Parent) 'multiCAD-mcp'
        if (Test-Path -LiteralPath (Join-Path $sibling 'pyproject.toml')) { $MultiCadPath = $sibling }
        elseif (Test-Path -LiteralPath (Join-Path $defaultMultiCad 'pyproject.toml')) { $MultiCadPath = $defaultMultiCad }
        else { $MultiCadPath = $defaultMultiCad }
    }

    if (-not (Test-Path -LiteralPath (Join-Path $MultiCadPath 'pyproject.toml'))) {
        Write-Step "Cloning multiCAD-mcp to $MultiCadPath"
        Invoke-Checked 'git' @('clone', 'https://github.com/AnCode666/multiCAD-mcp.git', $MultiCadPath)
    } else {
        Write-Step "Using existing multiCAD-mcp: $MultiCadPath"
    }

    Write-Step 'Creating or refreshing the isolated Python environment.'
    if (-not (Test-Path -LiteralPath (Join-Path $venvRoot 'Scripts\python.exe'))) {
        Invoke-Checked 'python' @('-m', 'venv', $venvRoot)
    }
    $venvPython = Join-Path $venvRoot 'Scripts\python.exe'
    Invoke-Checked $venvPython @('-m', 'pip', 'install', '--upgrade', 'pip')
    Invoke-Checked $venvPython @('-m', 'pip', 'install', '-e', $MultiCadPath)

    $serverPath = Join-Path $MultiCadPath 'src\server.py'
    if (-not $DryRun -and -not (Test-Path -LiteralPath $serverPath)) {
        throw "multiCAD-mcp server was not found: $serverPath"
    }

    $existingMcp = $null
    if (-not $DryRun) {
        $rawMcp = & codex mcp get multicad --json 2>$null
        if ($LASTEXITCODE -eq 0 -and $rawMcp) { $existingMcp = $rawMcp | ConvertFrom-Json }
    }
    if ($existingMcp) {
        if (-not (Confirm-Step 'A multicad MCP configuration already exists. Replace it after backup?')) {
            throw 'Installation cancelled before replacing the existing MCP configuration.'
        }
        Invoke-Checked 'codex' @('mcp', 'remove', 'multicad')
    }
    Write-Step 'Registering multiCAD-mcp through the Codex CLI.'
    Invoke-Checked 'codex' @('mcp', 'add', 'multicad', '--', $venvPython, $serverPath)

    Write-Step 'Registering the local plugin marketplace.'
    $marketplaces = $null
    if (-not $DryRun) {
        $rawMarketplaces = & codex plugin marketplace list --json 2>$null
        if ($LASTEXITCODE -eq 0 -and $rawMarketplaces) { $marketplaces = $rawMarketplaces | ConvertFrom-Json }
    }
    $existingMarketplace = $null
    if ($marketplaces -and $marketplaces.marketplaces) {
        $existingMarketplace = $marketplaces.marketplaces | Where-Object { $_.name -eq $marketplaceName } | Select-Object -First 1
    }
    if ($existingMarketplace) {
        $existingRoot = [IO.Path]::GetFullPath([string]$existingMarketplace.root).TrimEnd('\')
        $requestedRoot = [IO.Path]::GetFullPath($repoRoot).TrimEnd('\')
        if ($existingRoot -ieq $requestedRoot) {
            Write-Step "Using existing local marketplace: $existingRoot"
        } else {
            if (-not (Confirm-Step "Marketplace $marketplaceName points to $existingRoot. Replace it with $requestedRoot?")) {
                throw 'Installation cancelled before replacing the marketplace source.'
            }
            Invoke-Checked 'codex' @('plugin', 'marketplace', 'remove', $marketplaceName)
            Invoke-Checked 'codex' @('plugin', 'marketplace', 'add', $repoRoot)
        }
    } else {
        Invoke-Checked 'codex' @('plugin', 'marketplace', 'add', $repoRoot)
    }

    Write-Step 'Installing the plugin.'
    Invoke-Checked 'codex' @('plugin', 'add', $pluginSelector)

    Write-Step 'Running environment diagnostics.'
    Invoke-Checked $venvPython @((Join-Path $repoRoot 'scripts\check_environment.py'), '--multi-cad', $MultiCadPath)

    Write-Host ''
    Write-Host 'Installation completed. Restart Codex Desktop and open a new chat before testing the plugin.' -ForegroundColor Green
    if (-not $DryRun) { Write-Host "Installation log: $transcriptPath" }
}
finally {
    if (-not $DryRun) { try { Stop-Transcript | Out-Null } catch {} }
}
