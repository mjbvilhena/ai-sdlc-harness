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

if ($null -ne $McpConfigFile -and (Test-Path $McpConfigFile)) {
    if ($DryRun) {
        Write-Host "  [dry-run] Would remove sdlc-knowledge MCP server from $McpConfigFile (if present)"
    } else {
        Write-Host "Cleaning MCP Server configuration..."
        try {
            $json = Get-Content $McpConfigFile -Raw | ConvertFrom-Json
            if ($null -ne $json.mcpServers -and $null -ne $json.mcpServers.'sdlc-knowledge') {
                $json.mcpServers.PSObject.Properties.Remove('sdlc-knowledge')
                $json | ConvertTo-Json -Depth 100 | Set-Content $McpConfigFile -Encoding UTF8
                Write-Host "  [ok] Removed sdlc-knowledge MCP server from $McpConfigFile"
            }
        } catch {
            Write-Host "  [error] Failed to parse or modify $McpConfigFile"
        }
    }
}


Write-Host ""
Write-Host "---------------------------------------------"
if ($DryRun) {
    Write-Host " Dry-run complete."
} else {
    Write-Host " Done."
}
Write-Host "============================================="
