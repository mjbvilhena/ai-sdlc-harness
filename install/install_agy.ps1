<#
.SYNOPSIS
install_agy.ps1 — AI SDLC Harness installer for Antigravity (agy)

.DESCRIPTION
Installs all skills and agents from this repo into the local Antigravity
configuration directory at:
  ~\.gemini\antigravity-cli\builtin\skills\<skill-name>\

.PARAMETER DryRun
Preview what would be installed (no changes)

.EXAMPLE
.\install_agy.ps1
Install all skills and agents

.EXAMPLE
.\install_agy.ps1 -DryRun
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
    $AgySkillsDir = Join-Path $Workspace ".antigravity\skills"
} else {
    $AgySkillsDir = Join-Path $HOME ".gemini\antigravity-cli\builtin\skills"
}
$Harness = "agy"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

function Install-Item {
    param (
        [string]$ItemDir
    )

    $ItemName = Split-Path -Leaf $ItemDir
    $HarnessDir = Join-Path $ItemDir $Harness
    $Dest = Join-Path $AgySkillsDir $ItemName

    if (-not (Test-Path -Path $HarnessDir -PathType Container)) {
        Write-Host "  [skip] $ItemName — no ${Harness}\ subdirectory found"
        return $false
    }

    if ($DryRun) {
        Write-Host "  [dry-run] Would install: $ItemName"
        Write-Host "            Source:      ${HarnessDir}\"
        Write-Host "            Destination: ${Dest}\"
        return $true
    }

    if (-not (Test-Path -Path $Dest)) {
        $null = New-Item -ItemType Directory -Force -Path $Dest
    }

    Copy-Item -Path "$HarnessDir\*" -Destination $Dest -Recurse -Force

    Write-Host "  [ok] Installed: $ItemName → ${Dest}\"
    return $true
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

Write-Host "============================================="
Write-Host " AI SDLC Harness — Antigravity (agy) Installer"
Write-Host "============================================="
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

Write-Host "---------------------------------------------"
if ($DryRun) {
    Write-Host " Dry-run complete. $InstallCount item(s) would be installed, $SkipCount skipped."
} else {
    Write-Host " Done. $InstallCount item(s) installed to: $AgySkillsDir"
    Write-Host " $SkipCount item(s) skipped (no ${Harness}\ subdirectory)."
}
Write-Host "============================================="
