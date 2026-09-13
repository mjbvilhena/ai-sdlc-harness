#!/usr/bin/env bash
# =============================================================================
# install_claude.sh — AI SDLC Harness installer for Claude Code
#
# Installs all skills and agents from this repo as custom slash commands into
# the local Claude Code configuration directory at:
#   ~/.claude/commands/
#
# Each skill's claude/command.md is installed as:
#   ~/.claude/commands/sdlc-<skill-name>.md
#
# Naming: destination filenames are always sdlc- prefixed (source folder
# basename is used as-is when it already starts with sdlc-).
# Cleanup: before installing, existing sdlc-*.md files in the commands dir
# are removed (dry-run prints them only). Non-sdlc-* files are left alone.
#
# Usage:
#   ./install_claude.sh           # Install all skills and agents
#   ./install_claude.sh --dry-run # Preview what would be installed (no changes)
#
# Requirements: bash >= 3.2, cp, mkdir, cat, grep, mktemp (standard Unix utilities)
# Expands {{SKILL_BODY}} / {{RULE_BODY}} from sibling CONTENT.md at install time.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Absolute path to the root of this repository (directory containing this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Claude Code custom commands destination directory (default global)
CLAUDE_COMMANDS_DIR="${HOME}/.claude/commands"
WORKSPACE=""

# Target harness subdirectory name (within each skill/agent folder)
HARNESS="claude"

# The filename inside each claude/ subdirectory that becomes the slash command
COMMAND_FILE="command.md"

# Dry-run mode flag
DRY_RUN=false

# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/expand_content.sh
. "${SCRIPT_DIR}/lib/expand_content.sh"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/sdlc_names.sh
. "${SCRIPT_DIR}/lib/sdlc_names.sh"

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
      WORKSPACE="$(cd "$WORKSPACE" && pwd)"
      CLAUDE_COMMANDS_DIR="${WORKSPACE}/.claude/commands"
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

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

install_item() {
  local item_dir="$1"   # e.g. skills/sdlc-code-reviewer or agents/my-agent
  local item_name
  item_name="$(sdlc_prefixed_name "$(basename "$item_dir")")"
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
    echo "            Source:      ${source_file} + CONTENT.md"
    echo "            Destination: ${dest_file}"
    validate_item_content "$item_dir" "$item_name" "$source_file"
    return
  fi

  expand_harness_file "$item_dir" "$source_file" "$dest_file" "$item_name"
  ensure_sdlc_frontmatter_name "$dest_file" "$item_name"

  echo "  [ok] Installed: ${item_name} → ${dest_file}"
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

echo "=================================================="
echo " AI SDLC Harness — Claude Code Installer"
echo "=================================================="
echo ""

remove_sdlc_files "${CLAUDE_COMMANDS_DIR}" "sdlc-*.md" "${DRY_RUN}"
echo ""

install_count=0
skip_count=0

# Install skills
if [[ -d "${PROJECT_ROOT}/skills" ]]; then
  echo "Installing skills..."
  for skill_dir in "${PROJECT_ROOT}/skills"/*/; do
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
if [[ -d "${PROJECT_ROOT}/agents" ]]; then
  echo "Installing agents..."
  for agent_dir in "${PROJECT_ROOT}/agents"/*/; do
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
if [[ -d "${PROJECT_ROOT}/rules" ]]; then
  echo "Installing rules..."
  for rule_dir in "${PROJECT_ROOT}/rules"/*/; do
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

# ---------------------------------------------------------------------------
# Configure MCP Server
# ---------------------------------------------------------------------------
if [[ "$DRY_RUN" == true ]]; then
  echo "[dry-run] Would configure MCP Server in claude.json"
else
  echo "Configuring MCP Server..."
  if [[ -n "$WORKSPACE" ]]; then
    MCP_CONFIG_DIR="${WORKSPACE}"
  else
    MCP_CONFIG_DIR="${HOME}/.claude"

  echo "Configuring MCP Server..."
  if [[ -n "$MCP_CONFIG_DIR" ]]; then
    mkdir -p "$MCP_CONFIG_DIR"
    MCP_CONFIG_FILE="${MCP_CONFIG_DIR}/claude_desktop_config.json"
    MCP_SERVER_PATH="${PROJECT_ROOT}/mcp-server/src/server.py"

    python3 -c '
import sys, json, os
config_path = sys.argv[1]
server_path = sys.argv[2]

if os.path.exists(config_path):
    try:
        with open(config_path, "r") as f:
            data = json.load(f)
    except Exception:
        data = {}
else:
    data = {}

if "mcpServers" not in data:
    data["mcpServers"] = {}

data["mcpServers"]["sdlc-knowledge"] = {
    "command": sys.argv[3],
    "args": [server_path]
}

with open(config_path, "w") as f:
    json.dump(data, f, indent=2)
print("  [ok] Registered sdlc-knowledge MCP server in " + config_path)
' "$MCP_CONFIG_FILE" "$MCP_SERVER_PATH" "${PROJECT_ROOT}/mcp-server/venv/bin/python"
  else
    echo "  [info] Global MCP config must be managed manually in this environment."
  fi

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
