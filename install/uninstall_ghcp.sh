#!/usr/bin/env bash
# =============================================================================
# uninstall_ghcp.sh — AI SDLC Harness uninstaller for GitHub Copilot
#
# Removes all sdlc-*.md skills and agents from the GitHub Copilot instructions at:
#   .github/instructions/sdlc-*.md
#
# Usage:
#   ./uninstall_ghcp.sh           # Uninstall
#   ./uninstall_ghcp.sh --dry-run # Preview what would be removed (no changes)
#   ./uninstall_ghcp.sh --workspace <path> # Uninstall from specific workspace
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
DEST_DIR="${WORKSPACE}/.github/instructions"
DEST_DIR="${DEST_DIR}"

echo "============================================="
echo " AI SDLC Harness — GitHub Copilot Uninstaller"
echo "============================================="
echo " Destination: ${DEST_DIR}"
echo ""

remove_sdlc_files "${DEST_DIR}" "sdlc-*.md" "${DRY_RUN}"

echo ""
echo "---------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete."
else
  echo " Done."
fi
echo "============================================="
