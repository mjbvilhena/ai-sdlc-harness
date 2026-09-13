<#
.SYNOPSIS
Uninstalls all sdlc-*.json skills and agents from the Claude Desktop config.

.DESCRIPTION
Removes sdlc- artifacts from ~/.claude/commands/sdlc-*.json.

.EXAMPLE
.\uninstall_claude.ps1
.\uninstall_claude.ps1 -DryRun
#>
param(
    [string]$Workspace = "",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "lib\sdlc_names.ps1")

$DestDir = Join-Path $env:USERPROFILE ".claude\commands"
$DestDir = $DestDir

Write-Host "============================================="
Write-Host " AI SDLC Harness — Claude Desktop Uninstaller"
Write-Host "============================================="
Write-Host " Destination: $DestDir"
Write-Host ""

Remove-SdlcFiles -DestDir $DestDir -Pattern "sdlc-*.json" -DryRun:$DryRun

Write-Host ""
Write-Host "---------------------------------------------"
if ($DryRun) {
    Write-Host " Dry-run complete."
} else {
    Write-Host " Done."
}
Write-Host "============================================="
