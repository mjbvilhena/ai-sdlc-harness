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
DEST_DIR="${HOME}/.claude/commands"
DEST_DIR="${DEST_DIR}"

echo "============================================="
echo " AI SDLC Harness — Claude Desktop Uninstaller"
echo "============================================="
echo " Destination: ${DEST_DIR}"
echo ""

remove_sdlc_files "${DEST_DIR}" "sdlc-*.json" "${DRY_RUN}"

echo ""
echo "---------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete."
else
  echo " Done."
fi
echo "============================================="
