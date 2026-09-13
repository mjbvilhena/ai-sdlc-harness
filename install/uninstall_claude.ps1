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
