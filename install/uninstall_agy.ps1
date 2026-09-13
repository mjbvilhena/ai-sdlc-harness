<#
.SYNOPSIS
Uninstalls all sdlc-* skills and agents from the Antigravity (agy) config.

.DESCRIPTION
Removes sdlc- artifacts from ~/.gemini/antigravity-cli/builtin/skills/sdlc-<skill-name>/.

.EXAMPLE
.\uninstall_agy.ps1
.\uninstall_agy.ps1 -DryRun
#>
param(
    [string]$Workspace = "",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "lib\sdlc_names.ps1")


if ([string]::IsNullOrWhiteSpace($Workspace)) {
    $DestDir = Join-Path $env:USERPROFILE ".gemini\antigravity-cli\builtin\skills"
} else {
    $Workspace = (Resolve-Path $Workspace).ProviderPath
    $DestDir = Join-Path $Workspace ".agents\skills"
}

$DestDir = $DestDir

Write-Host "============================================="
Write-Host " AI SDLC Harness — Antigravity (agy) Uninstaller"
Write-Host "============================================="
Write-Host " Destination: $DestDir"
Write-Host ""

Remove-SdlcDirs -DestDir $DestDir -DryRun:$DryRun

Write-Host ""
Write-Host "---------------------------------------------"
if ($DryRun) {
    Write-Host " Dry-run complete."
} else {
    Write-Host " Done."
}
Write-Host "============================================="
