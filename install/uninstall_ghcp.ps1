<#
.SYNOPSIS
Uninstalls all sdlc-*.md skills and agents from the GitHub Copilot config.

.DESCRIPTION
Removes sdlc- artifacts from .github/instructions/sdlc-*.md.

.EXAMPLE
.\uninstall_ghcp.ps1
.\uninstall_ghcp.ps1 -DryRun
#>
param(
    [string]$Workspace = "$PWD",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "lib\sdlc_names.ps1")

$Workspace = (Resolve-Path $Workspace).ProviderPath
$DestDir = Join-Path $Workspace ".github\instructions"
$DestDir = $DestDir

Write-Host "============================================="
Write-Host " AI SDLC Harness — GitHub Copilot Uninstaller"
Write-Host "============================================="
Write-Host " Destination: $DestDir"
Write-Host ""

Remove-SdlcFiles -DestDir $DestDir -Pattern "sdlc-*.md" -DryRun:$DryRun

Write-Host ""
Write-Host "---------------------------------------------"
if ($DryRun) {
    Write-Host " Dry-run complete."
} else {
    Write-Host " Done."
}
Write-Host "============================================="
