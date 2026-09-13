<#
.SYNOPSIS
Uninstalls all sdlc-*.mdc skills and agents from the Cursor config.

.DESCRIPTION
Removes sdlc- artifacts from .cursor/rules/sdlc-*.mdc.

.EXAMPLE
.\uninstall_cursor.ps1
.\uninstall_cursor.ps1 -DryRun
#>
param(
    [string]$Workspace = "$PWD",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "lib\sdlc_names.ps1")

$Workspace = (Resolve-Path $Workspace).ProviderPath
$DestDir = Join-Path $Workspace ".cursor\rules"
$DestDir = $DestDir

Write-Host "============================================="
Write-Host " AI SDLC Harness — Cursor Uninstaller"
Write-Host "============================================="
Write-Host " Destination: $DestDir"
Write-Host ""

Remove-SdlcFiles -DestDir $DestDir -Pattern "sdlc-*.mdc" -DryRun:$DryRun

Write-Host ""
Write-Host "---------------------------------------------"
if ($DryRun) {
    Write-Host " Dry-run complete."
} else {
    Write-Host " Done."
}
Write-Host "============================================="
