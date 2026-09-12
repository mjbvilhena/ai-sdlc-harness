#!/usr/bin/env bash
# =============================================================================
# install_claude.sh — AI SDLC Harness installer for Claude Code
#
# Installs all skills and agents from this repo as custom slash commands into
# the local Claude Code configuration directory at:
#   ~/.claude/commands/
#
# Each skill's claude/command.md is installed as:
#   ~/.claude/commands/<skill-name>.md
#
# Usage:
#   ./install_claude.sh           # Install all skills and agents
#   ./install_claude.sh --dry-run # Preview what would be installed (no changes)
#
# Requirements: bash >= 3.2, cp, mkdir (standard Unix utilities only)
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Absolute path to the root of this repository (directory containing this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Claude Code custom commands destination directory
CLAUDE_COMMANDS_DIR="${HOME}/.claude/commands"

# Target harness subdirectory name (within each skill/agent folder)
HARNESS="claude"

# The filename inside each claude/ subdirectory that becomes the slash command
COMMAND_FILE="command.md"

# Dry-run mode flag
DRY_RUN=false

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      echo "[dry-run] No files will be modified."
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--dry-run]" >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

install_item() {
  local item_dir="$1"   # e.g. skills/code-reviewer or agents/my-agent
  local item_name
  item_name="$(basename "$item_dir")"
  local harness_dir="${item_dir}/${HARNESS}"
  local source_file="${harness_dir}/${COMMAND_FILE}"
  local dest_file="${CLAUDE_COMMANDS_DIR}/${item_name}.md"

  # Skip if this skill/agent has no claude/ subdirectory
  if [[ ! -d "$harness_dir" ]]; then
    echo "  [skip] ${item_name} — no ${HARNESS}/ subdirectory found"
    return
  fi

  # Skip if the expected command file doesn't exist
  if [[ ! -f "$source_file" ]]; then
    echo "  [skip] ${item_name} — no ${HARNESS}/${COMMAND_FILE} found"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [dry-run] Would install: ${item_name}"
    echo "            Source:      ${source_file}"
    echo "            Destination: ${dest_file}"
    return
  fi

  # Create destination directory if it doesn't exist
  mkdir -p "$CLAUDE_COMMANDS_DIR"

  # Copy the command file to the destination as <skill-name>.md
  cp "${source_file}" "${dest_file}"

  echo "  [ok] Installed: ${item_name} → ${dest_file}"
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

echo "=================================================="
echo " AI SDLC Harness — Claude Code Installer"
echo "=================================================="
echo ""

install_count=0
skip_count=0

# Install skills
if [[ -d "${SCRIPT_DIR}/skills" ]]; then
  echo "Installing skills..."
  for skill_dir in "${SCRIPT_DIR}/skills"/*/; do
    [[ -d "$skill_dir" ]] || continue
    install_item "$skill_dir"
    if [[ -f "${skill_dir}/${HARNESS}/${COMMAND_FILE}" ]]; then
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
    if [[ -f "${agent_dir}/${HARNESS}/${COMMAND_FILE}" ]]; then
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
    if [[ -f "${rule_dir}/${HARNESS}/${COMMAND_FILE}" ]]; then
      (( install_count++ )) || true
    else
      (( skip_count++ )) || true
    fi
  done
else
  echo "  [info] No rules/ directory found — skipping rules."
fi

echo ""
echo "--------------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete. ${install_count} item(s) would be installed, ${skip_count} skipped."
else
  echo " Done. ${install_count} item(s) installed to: ${CLAUDE_COMMANDS_DIR}"
  echo " ${skip_count} item(s) skipped (no ${HARNESS}/${COMMAND_FILE})."
fi
echo "=================================================="
