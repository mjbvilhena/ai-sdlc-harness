#!/usr/bin/env bash
# =============================================================================
# uninstall_agy.sh — AI SDLC Harness uninstaller for Antigravity (agy)
#
# Removes all sdlc-* skills and agents from the Antigravity configuration directory at:
#   ~/.gemini/antigravity-cli/builtin/skills/sdlc-<skill-name>/
#
# Usage:
#   ./uninstall_agy.sh           # Uninstall
#   ./uninstall_agy.sh --dry-run # Preview what would be removed (no changes)
#   ./uninstall_agy.sh --workspace <path> # Uninstall from workspace instead of global
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE=""
DRY_RUN=false

. "${SCRIPT_DIR}/lib/sdlc_names.sh"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --workspace requires a path argument." >&2
        exit 1
      fi
      WORKSPACE="$2"
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

if [[ -n "$WORKSPACE" ]]; then
  WORKSPACE="$(cd "$WORKSPACE" && pwd)"
  DEST_DIR="${WORKSPACE}/.agents/skills"
  MCP_CONFIG_FILE="${WORKSPACE}/.agents/mcp_config.json"
else
  DEST_DIR="${HOME}/.gemini/antigravity-cli/builtin/skills"
  MCP_CONFIG_FILE="${HOME}/.gemini/config/mcp_config.json"
fi


echo "============================================="
echo " AI SDLC Harness — Antigravity (agy) Uninstaller"
echo "============================================="
echo " Destination: ${DEST_DIR}"
echo ""

remove_sdlc_dirs "${DEST_DIR}" "${DRY_RUN}"

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
