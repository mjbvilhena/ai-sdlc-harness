<#
.SYNOPSIS
install_cursor.ps1 — AI SDLC Harness installer for Cursor

.DESCRIPTION
Installs all skills and agents from this repo as Cursor rule
files into the target workspace's .cursor\rules\ directory.

Each skill's cursor/rule.mdc is installed as:
  <workspace>\.cursor\rules\<skill-name>.mdc

Note: Cursor rules are WORKSPACE-SCOPED. You must specify the
workspace you want to install into. If no -Workspace parameter is given, the
current working directory ($PWD) is used as the workspace root.

.PARAMETER Workspace
Target workspace directory to install rules into

.PARAMETER DryRun
Preview what would be installed (no changes)

.EXAMPLE
.\install_cursor.ps1
Install to current working directory workspace

.EXAMPLE
.\install_cursor.ps1 -Workspace "C:\path\to\repo"
Install to specific workspace

.EXAMPLE
.\install_cursor.ps1 -DryRun
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

# Resolve workspace to absolute path
$Workspace = (Resolve-Path $Workspace).Path

# Cursor rules destination directory (inside the workspace)
$CursorRulesDir = Join-Path $Workspace ".cursor\rules"

# Target harness subdirectory name (within each skill/agent folder)
$Harness = "cursor"

# The filename inside each cursor/ subdirectory to install
$RuleFile = "rule.mdc"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

function Install-Item {
    param (
        [string]$ItemDir
    )

    $ItemName = Split-Path -Leaf $ItemDir
    $HarnessDir = Join-Path $ItemDir $Harness
    $SourceFile = Join-Path $HarnessDir $RuleFile
    $DestFile = Join-Path $CursorRulesDir "${ItemName}.mdc"

    if (-not (Test-Path -Path $HarnessDir -PathType Container)) {
        Write-Host "  [skip] $ItemName — no ${Harness}\ subdirectory found"
        return $false
    }

    if (-not (Test-Path -Path $SourceFile -PathType Leaf)) {
        Write-Host "  [skip] $ItemName — no ${Harness}\${RuleFile} found"
        return $false
    }

    if ($DryRun) {
        Write-Host "  [dry-run] Would install: $ItemName"
        Write-Host "            Source:      $SourceFile"
        Write-Host "            Destination: $DestFile"
        return $true
    }

    if (-not (Test-Path -Path $CursorRulesDir)) {
        $null = New-Item -ItemType Directory -Force -Path $CursorRulesDir
    }

    Copy-Item -Path $SourceFile -Destination $DestFile -Force

    Write-Host "  [ok] Installed: $ItemName → $DestFile"
    return $true
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

Write-Host "======================================================="
Write-Host " AI SDLC Harness — Cursor Installer"
Write-Host "======================================================="
Write-Host " Workspace: $Workspace"
Write-Host " Destination: $CursorRulesDir"
Write-Host ""

if ($DryRun) {
    Write-Host "[dry-run] No files will be modified."
}

$InstallCount = 0
$SkipCount = 0

function Process-Category {
    param([string]$Category)
    
    $CategoryDir = Join-Path $ScriptDir $Category
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

Write-Host "-------------------------------------------------------"
if ($DryRun) {
    Write-Host " Dry-run complete. $InstallCount item(s) would be installed, $SkipCount skipped."
} else {
    Write-Host " Done. $InstallCount item(s) installed to: $CursorRulesDir"
    Write-Host " $SkipCount item(s) skipped (no ${Harness}\${RuleFile})."
    Write-Host ""
    Write-Host " NOTE: Remember to commit .cursor\rules\ to your workspace repo"
    Write-Host "       so that Cursor can read the rule files."
}
Write-Host "======================================================="
