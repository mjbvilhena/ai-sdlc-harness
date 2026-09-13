<#
.SYNOPSIS
Uninstalls all sdlc-*.md skills and agents from the Cursor config.

.DESCRIPTION
Removes sdlc- artifacts from .cursor/prompts/sdlc-*.md.

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

Remove-SdlcFiles -DestDir $DestDir -Pattern "sdlc-*.md" -DryRun:$DryRun

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
