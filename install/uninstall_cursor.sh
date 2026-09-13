#!/usr/bin/env bash
# =============================================================================
# uninstall_cursor.sh — AI SDLC Harness uninstaller for Cursor
#
# Removes all sdlc-*.mdc skills and agents from the workspace rules directory at:
#   .cursor/rules/sdlc-*.mdc
#
# Usage:
#   ./uninstall_cursor.sh           # Uninstall
#   ./uninstall_cursor.sh --dry-run # Preview what would be removed (no changes)
#   ./uninstall_cursor.sh --workspace <path> # Uninstall from specific workspace
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="${PWD}"
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
WORKSPACE="$(cd "$WORKSPACE" && pwd)"
DEST_DIR="${WORKSPACE}/.cursor/rules"
DEST_DIR="${DEST_DIR}"

echo "============================================="
echo " AI SDLC Harness — Cursor Uninstaller"
echo "============================================="
echo " Destination: ${DEST_DIR}"
echo ""

remove_sdlc_files "${DEST_DIR}" "sdlc-*.mdc" "${DRY_RUN}"

echo ""
echo "---------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete."
else
  echo " Done."
fi
echo "============================================="
