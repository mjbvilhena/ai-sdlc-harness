<#
.SYNOPSIS
install_claude.ps1 — AI SDLC Harness installer for Claude Code

.DESCRIPTION
Installs all skills and agents from this repo as custom slash commands into
the local Claude Code configuration directory at:
  ~\.claude\commands\

Each skill's claude/command.md is installed as:
  ~\.claude\commands\<skill-name>.md

.PARAMETER DryRun
Preview what would be installed (no changes)

.EXAMPLE
.\install_claude.ps1
Install all skills and agents

.EXAMPLE
.\install_claude.ps1 -DryRun
Preview only
#>

param(
    [string]$Workspace = "",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path -Path $ScriptDir -Parent
if ($Workspace) {
    $Workspace = (Resolve-Path $Workspace).Path
    $ClaudeCommandsDir = Join-Path $Workspace ".claude\commands"
} else {
    $ClaudeCommandsDir = Join-Path $HOME ".claude\commands"
}
$Harness = "claude"
$CommandFile = "command.md"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

function Install-Item {
    param (
        [string]$ItemDir
    )

    $ItemName = Split-Path -Leaf $ItemDir
    $HarnessDir = Join-Path $ItemDir $Harness
    $SourceFile = Join-Path $HarnessDir $CommandFile
    $DestFile = Join-Path $ClaudeCommandsDir "${ItemName}.md"

    if (-not (Test-Path -Path $HarnessDir -PathType Container)) {
        Write-Host "  [skip] $ItemName — no ${Harness}\ subdirectory found"
        return $false
    }

    if (-not (Test-Path -Path $SourceFile -PathType Leaf)) {
        Write-Host "  [skip] $ItemName — no ${Harness}\${CommandFile} found"
        return $false
    }

    if ($DryRun) {
        Write-Host "  [dry-run] Would install: $ItemName"
        Write-Host "            Source:      $SourceFile"
        Write-Host "            Destination: $DestFile"
        return $true
    }

    if (-not (Test-Path -Path $ClaudeCommandsDir)) {
        $null = New-Item -ItemType Directory -Force -Path $ClaudeCommandsDir
    }

    Copy-Item -Path $SourceFile -Destination $DestFile -Force

    Write-Host "  [ok] Installed: $ItemName → $DestFile"
    return $true
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

Write-Host "=================================================="
Write-Host " AI SDLC Harness — Claude Code Installer"
Write-Host "=================================================="
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

Write-Host "--------------------------------------------------"
if ($DryRun) {
    Write-Host " Dry-run complete. $InstallCount item(s) would be installed, $SkipCount skipped."
} else {
    Write-Host " Done. $InstallCount item(s) installed to: $ClaudeCommandsDir"
    Write-Host " $SkipCount item(s) skipped (no ${Harness}\${CommandFile})."
}
Write-Host "=================================================="
