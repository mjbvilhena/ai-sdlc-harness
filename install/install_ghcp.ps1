<#
.SYNOPSIS
install_ghcp.ps1 — AI SDLC Harness installer for GitHub Copilot (ghcp)

.DESCRIPTION
Installs all skills and agents from this repo as GitHub Copilot instruction
files into the target workspace's .github\instructions\ directory.

Each skill's ghcp/instructions.md is installed as:
  <workspace>\.github\instructions\<skill-name>.instructions.md

Note: GitHub Copilot instructions are WORKSPACE-SCOPED. You must specify the
workspace you want to install into. If no -Workspace parameter is given, the
current working directory ($PWD) is used as the workspace root.

.PARAMETER Workspace
Target workspace directory to install rules into

.PARAMETER DryRun
Preview what would be installed (no changes)

.EXAMPLE
.\install_ghcp.ps1
Install to current working directory workspace

.EXAMPLE
.\install_ghcp.ps1 -Workspace "C:\path\to\repo"
Install to specific workspace

.EXAMPLE
.\install_ghcp.ps1 -DryRun
Preview only
#>

param(
    [string]$Workspace = $PWD.Path,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path -Path $ScriptDir -Parent

# Resolve workspace to absolute path
$Workspace = (Resolve-Path $Workspace).Path

# GitHub Copilot instructions destination directory (inside the workspace)
$GhcpInstructionsDir = Join-Path $Workspace ".github\instructions"

# Target harness subdirectory name (within each skill/agent folder)
$Harness = "ghcp"

# The filename inside each ghcp/ subdirectory to install
$InstructionsFile = "instructions.md"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

function Install-Item {
    param (
        [string]$ItemDir
    )

    $ItemName = Split-Path -Leaf $ItemDir
    $HarnessDir = Join-Path $ItemDir $Harness
    $SourceFile = Join-Path $HarnessDir $InstructionsFile
    $DestFile = Join-Path $GhcpInstructionsDir "${ItemName}.instructions.md"

    if (-not (Test-Path -Path $HarnessDir -PathType Container)) {
        Write-Host "  [skip] $ItemName — no ${Harness}\ subdirectory found"
        return $false
    }

    if (-not (Test-Path -Path $SourceFile -PathType Leaf)) {
        Write-Host "  [skip] $ItemName — no ${Harness}\${InstructionsFile} found"
        return $false
    }

    if ($DryRun) {
        Write-Host "  [dry-run] Would install: $ItemName"
        Write-Host "            Source:      $SourceFile"
        Write-Host "            Destination: $DestFile"
        return $true
    }

    if (-not (Test-Path -Path $GhcpInstructionsDir)) {
        $null = New-Item -ItemType Directory -Force -Path $GhcpInstructionsDir
    }

    Copy-Item -Path $SourceFile -Destination $DestFile -Force

    Write-Host "  [ok] Installed: $ItemName → $DestFile"
    return $true
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

Write-Host "======================================================="
Write-Host " AI SDLC Harness — GitHub Copilot (ghcp) Installer"
Write-Host "======================================================="
Write-Host " Workspace: $Workspace"
Write-Host " Destination: $GhcpInstructionsDir"
Write-Host ""

if ($DryRun) {
    Write-Host "[dry-run] No files will be modified."
}

$InstallCount = 0
$SkipCount = 0

function Process-Category {
    param([string]$Category)
    
    $CategoryDir = Join-Path $ProjectRoot $Category
    if (Test-Path -Path $CategoryDir -PathType Container) {
        Write-Host "Installing $Category..."
        $Dirs = Get-ChildItem -Path $CategoryDir -Directory
        foreach ($Dir in $Dirs) {
            $Installed = Install-Item -ItemDir $Dir.FullName
            if ($Installed) {
                $script:InstallCount++
            } else {
                $script:SkipCount++
            }
        }
    } else {
        Write-Host "  [info] No ${Category}\ directory found — skipping ${Category}."
    }
    Write-Host ""
}

Process-Category "skills"
Process-Category "agents"
Process-Category "rules"

# ---------------------------------------------------------------------------
# Configure MCP Server (VS Code / GitHub Copilot workspace)
# ---------------------------------------------------------------------------
# GitHub Copilot Chat in VS Code reads workspace MCP servers from
# `.vscode\mcp.json` using a top-level `servers` key (not `mcpServers`).
# See: https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp-in-your-ide/extend-copilot-chat-with-mcp
if ($DryRun) {
    Write-Host "[dry-run] Would configure MCP Server in .vscode\mcp.json"
} else {
    Write-Host "Configuring MCP Server..."
    $McpConfigDir = Join-Path $Workspace ".vscode"
    if (-not (Test-Path -Path $McpConfigDir)) {
        New-Item -ItemType Directory -Force -Path $McpConfigDir | Out-Null
    }
    $McpConfigFile = Join-Path $McpConfigDir "mcp.json"
    $McpServerPath = Join-Path $ProjectRoot "mcp-server\src\server.py"

    if (-not (Test-Path -Path $McpConfigFile)) {
        $JsonContent = @"
{
  "servers": {
    "sdlc-knowledge": {
      "command": "python3",
      "args": ["$($McpServerPath -replace '\', '\\')"]
    }
  }
}
"@
        Set-Content -Path $McpConfigFile -Value $JsonContent
        Write-Host "  [ok] Created MCP configuration: $McpConfigFile"
    } else {
        Write-Host "  [info] MCP configuration already exists at $McpConfigFile."
        Write-Host "  [info] Please ensure 'sdlc-knowledge' server is registered pointing to $McpServerPath."
    }
}
Write-Host ""
Write-Host "-------------------------------------------------------"
if ($DryRun) {
    Write-Host " Dry-run complete. $InstallCount item(s) would be installed, $SkipCount skipped."
} else {
    Write-Host " Done. $InstallCount item(s) installed to: $GhcpInstructionsDir"
    Write-Host " $SkipCount item(s) skipped (no ${Harness}\${InstructionsFile})."
    Write-Host ""
    Write-Host " NOTE: Remember to commit .github\instructions\ and .vscode\mcp.json"
    Write-Host "       to your workspace repo so GitHub Copilot can read them."
}
Write-Host "======================================================="
