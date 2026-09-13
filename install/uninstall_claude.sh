#!/usr/bin/env bash
# =============================================================================
# uninstall_claude.sh — AI SDLC Harness uninstaller for Claude Desktop
#
# Removes all sdlc-*.json skills and agents from the Claude Desktop config at:
#   ~/.claude/commands/sdlc-*.json
#
# Usage:
#   ./uninstall_claude.sh           # Uninstall
#   ./uninstall_claude.sh --dry-run # Preview what would be removed (no changes)

# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_WORKSPACE=""
DRY_RUN=false

# shellcheck disable=SC1091
. "${SCRIPT_DIR}/lib/sdlc_names.sh"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --workspace requires a path argument." >&2
        exit 1
      fi
      _WORKSPACE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: $0 [--workspace <path>] [--dry-run]" >&2
      exit 1
      ;;
  esac
done
DEST_DIR="${HOME}/.claude/commands"
MCP_CONFIG_FILE="${HOME}/.claude/claude_desktop_config.json"

echo "============================================="
echo " AI SDLC Harness — Claude Desktop Uninstaller"
echo "============================================="
echo " Destination: ${DEST_DIR}"
echo ""

remove_sdlc_files "${DEST_DIR}" "sdlc-*.json" "${DRY_RUN}"

if [[ -f "$MCP_CONFIG_FILE" && "$DRY_RUN" == false ]]; then
  echo "Cleaning MCP Server configuration..."
  python3 -c '
import sys, json
try:
    with open(sys.argv[1], "r") as f: data = json.load(f)
    modified = False
    if "mcpServers" in data and "sdlc-knowledge" in data["mcpServers"]:
        del data["mcpServers"]["sdlc-knowledge"]
        modified = True
        if not data["mcpServers"]: del data["mcpServers"]
    if modified:
        with open(sys.argv[1], "w") as f: json.dump(data, f, indent=2)
        print("  [ok] Removed sdlc-knowledge MCP server from " + sys.argv[1])
except Exception:
    pass
' "$MCP_CONFIG_FILE"
elif [[ -f "$MCP_CONFIG_FILE" && "$DRY_RUN" == true ]]; then
  echo "  [dry-run] Would remove sdlc-knowledge MCP server from $MCP_CONFIG_FILE (if present)"
fi


echo ""
echo "---------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete."
else
  echo " Done."
fi
echo "============================================="
