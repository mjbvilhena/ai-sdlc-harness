#!/usr/bin/env bash
# =============================================================================
# install_ghcp.sh — AI SDLC Harness installer for GitHub Copilot (ghcp)
#
# Installs all skills and agents from this repo as GitHub Copilot instruction
# files into the target workspace's .github/instructions/ directory.
#
# Each skill's ghcp/instructions.md is installed as:
#   <workspace>/.github/instructions/<skill-name>.instructions.md
#
# Note: GitHub Copilot instructions are WORKSPACE-SCOPED. You must specify the
# workspace you want to install into. If no --workspace flag is given, the
# current working directory ($PWD) is used as the workspace root.
#
# Usage:
#   ./install_ghcp.sh                            # Install to $PWD workspace
#   ./install_ghcp.sh --workspace /path/to/repo  # Install to specific workspace
#   ./install_ghcp.sh --dry-run                  # Preview only (no changes)
#
# Requirements: bash >= 3.2, cp, mkdir (standard Unix utilities only)
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Absolute path to the root of this repository (directory containing this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default workspace: the current working directory
WORKSPACE="${PWD}"

# Target harness subdirectory name (within each skill/agent folder)
HARNESS="ghcp"

# The filename inside each ghcp/ subdirectory to install
INSTRUCTIONS_FILE="instructions.md"

# Dry-run mode flag
DRY_RUN=false

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

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
      echo "[dry-run] No files will be modified."
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: $0 [--workspace <path>] [--dry-run]" >&2
      exit 1
      ;;
  esac
done

# Resolve workspace to absolute path
WORKSPACE="$(cd "$WORKSPACE" && pwd)"

# GitHub Copilot instructions destination directory (inside the workspace)
GHCP_INSTRUCTIONS_DIR="${WORKSPACE}/.github/instructions"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

install_item() {
  local item_dir="$1"   # e.g. skills/code-reviewer or agents/my-agent
  local item_name
  item_name="$(basename "$item_dir")"
  local harness_dir="${item_dir}/${HARNESS}"
  local source_file="${harness_dir}/${INSTRUCTIONS_FILE}"
  # GHCP instruction files use the .instructions.md suffix convention
  local dest_file="${GHCP_INSTRUCTIONS_DIR}/${item_name}.instructions.md"

  # Skip if this skill/agent has no ghcp/ subdirectory
  if [[ ! -d "$harness_dir" ]]; then
    echo "  [skip] ${item_name} — no ${HARNESS}/ subdirectory found"
    return
  fi

  # Skip if the expected instructions file doesn't exist
  if [[ ! -f "$source_file" ]]; then
    echo "  [skip] ${item_name} — no ${HARNESS}/${INSTRUCTIONS_FILE} found"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [dry-run] Would install: ${item_name}"
    echo "            Source:      ${source_file}"
    echo "            Destination: ${dest_file}"
    return
  fi

  # Create destination directory if it doesn't exist
  mkdir -p "$GHCP_INSTRUCTIONS_DIR"

  # Copy the instructions file to the destination
  cp "${source_file}" "${dest_file}"

  echo "  [ok] Installed: ${item_name} → ${dest_file}"
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

echo "======================================================="
echo " AI SDLC Harness — GitHub Copilot (ghcp) Installer"
echo "======================================================="
echo " Workspace: ${WORKSPACE}"
echo " Destination: ${GHCP_INSTRUCTIONS_DIR}"
echo ""

install_count=0
skip_count=0

# Install skills
if [[ -d "${SCRIPT_DIR}/skills" ]]; then
  echo "Installing skills..."
  for skill_dir in "${SCRIPT_DIR}/skills"/*/; do
    [[ -d "$skill_dir" ]] || continue
    install_item "$skill_dir"
    if [[ -f "${skill_dir}/${HARNESS}/${INSTRUCTIONS_FILE}" ]]; then
      (( install_count++ )) || true
    else
      (( skip_count++ )) || true
    fi
  done
else
  echo "  [info] No skills/ directory found — skipping skills."
fi

echo ""

# Install agents
if [[ -d "${SCRIPT_DIR}/agents" ]]; then
  echo "Installing agents..."
  for agent_dir in "${SCRIPT_DIR}/agents"/*/; do
    [[ -d "$agent_dir" ]] || continue
    install_item "$agent_dir"
    if [[ -f "${agent_dir}/${HARNESS}/${INSTRUCTIONS_FILE}" ]]; then
      (( install_count++ )) || true
    else
      (( skip_count++ )) || true
    fi
  done
else
  echo "  [info] No agents/ directory found — skipping agents."
fi

echo ""

# Install rules
if [[ -d "${SCRIPT_DIR}/rules" ]]; then
  echo "Installing rules..."
  for rule_dir in "${SCRIPT_DIR}/rules"/*/; do
    [[ -d "$rule_dir" ]] || continue
    install_item "$rule_dir"
    if [[ -f "${rule_dir}/${HARNESS}/${INSTRUCTIONS_FILE}" ]]; then
      (( install_count++ )) || true
    else
      (( skip_count++ )) || true
    fi
  done
else
  echo "  [info] No rules/ directory found — skipping rules."
fi

echo ""
echo "-------------------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete. ${install_count} item(s) would be installed, ${skip_count} skipped."
else
  echo " Done. ${install_count} item(s) installed to: ${GHCP_INSTRUCTIONS_DIR}"
  echo " ${skip_count} item(s) skipped (no ${HARNESS}/${INSTRUCTIONS_FILE})."
  echo ""
  echo " NOTE: Remember to commit .github/instructions/ to your workspace repo"
  echo "       so that GitHub Copilot can read the instruction files."
fi
echo "======================================================="
