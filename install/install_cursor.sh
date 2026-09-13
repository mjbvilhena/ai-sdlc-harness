#!/usr/bin/env bash
# =============================================================================
# install_cursor.sh — AI SDLC Harness installer for Cursor
#
# Installs all skills and agents from this repo as Cursor rule
# files into the target workspace's .cursor/rules/ directory.
#
# Each skill's cursor/rule.mdc is installed as:
#   <workspace>/.cursor/rules/<skill-name>.mdc
#
# Note: Cursor rules are WORKSPACE-SCOPED. You must specify the
# workspace you want to install into. If no --workspace flag is given, the
# current working directory ($PWD) is used as the workspace root.
#
# Usage:
#   ./install_cursor.sh                            # Install to $PWD workspace
#   ./install_cursor.sh --workspace /path/to/repo  # Install to specific workspace
#   ./install_cursor.sh --dry-run                  # Preview only (no changes)
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

# Default workspace: the current working directory
WORKSPACE="${PWD}"

# Target harness subdirectory name (within each skill/agent folder)
HARNESS="cursor"

# The filename inside each cursor/ subdirectory to install
RULE_FILE="rule.mdc"

# Dry-run mode flag
DRY_RUN=false

# shellcheck source=lib/expand_content.sh
. "${SCRIPT_DIR}/lib/expand_content.sh"

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

# Cursor rules destination directory (inside the workspace)
CURSOR_RULES_DIR="${WORKSPACE}/.cursor/rules"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

install_item() {
  local item_dir="$1"   # e.g. skills/code-reviewer or agents/my-agent
  local item_name
  item_name="$(basename "$item_dir")"
  local harness_dir="${item_dir}/${HARNESS}"
  local source_file="${harness_dir}/${RULE_FILE}"
  # Cursor rule files use the .mdc suffix convention
  local dest_file="${CURSOR_RULES_DIR}/${item_name}.mdc"

  # Skip if this skill/agent has no cursor/ subdirectory
  if [[ ! -d "$harness_dir" ]]; then
    echo "  [skip] ${item_name} — no ${HARNESS}/ subdirectory found"
    return
  fi

  # Skip if the expected rule file doesn't exist
  if [[ ! -f "$source_file" ]]; then
    echo "  [skip] ${item_name} — no ${HARNESS}/${RULE_FILE} found"
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

  echo "  [ok] Installed: ${item_name} → ${dest_file}"
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

echo "======================================================="
echo " AI SDLC Harness — Cursor Installer"
echo "======================================================="
echo " Workspace: ${WORKSPACE}"
echo " Destination: ${CURSOR_RULES_DIR}"
echo ""

install_count=0
skip_count=0

# Install skills
if [[ -d "${PROJECT_ROOT}/skills" ]]; then
  echo "Installing skills..."
  for skill_dir in "${PROJECT_ROOT}/skills"/*/; do
    [[ -d "$skill_dir" ]] || continue
    install_item "$skill_dir"
    if [[ -f "${skill_dir}/${HARNESS}/${RULE_FILE}" ]]; then
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
    if [[ -f "${agent_dir}/${HARNESS}/${RULE_FILE}" ]]; then
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
    if [[ -f "${rule_dir}/${HARNESS}/${RULE_FILE}" ]]; then
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
  echo "[dry-run] Would configure MCP Server in mcp.json"
else
  echo "Configuring MCP Server..."
  if [[ -n "$WORKSPACE" ]]; then
    MCP_CONFIG_DIR="${WORKSPACE}/.cursor"
  else
    # Cursor globally stores MCP config in its internal AppData, but we can't easily guess it on Linux/Mac/Win identically without jq.
    # For global installs, we'll skip or just put it in a known Cursor config path. 
    # For now, we only automatically configure for workspace.
    MCP_CONFIG_DIR=""
  fi
  
  if [[ -n "$MCP_CONFIG_DIR" ]]; then
    mkdir -p "$MCP_CONFIG_DIR"
    MCP_CONFIG_FILE="${MCP_CONFIG_DIR}/mcp.json"
    
    MCP_SERVER_PATH="${PROJECT_ROOT}/mcp-server/src/server.py"
    
    if [[ ! -f "$MCP_CONFIG_FILE" ]]; then
      cat <<EOF > "$MCP_CONFIG_FILE"
{
  "mcpServers": {
    "sdlc-knowledge": {
      "command": "python3",
      "args": ["${MCP_SERVER_PATH}"]
    }
  }
}
EOF
      echo "  [ok] Created MCP configuration: ${MCP_CONFIG_FILE}"
    else
      echo "  [info] MCP configuration already exists at ${MCP_CONFIG_FILE}."
      echo "  [info] Please ensure 'sdlc-knowledge' server is registered pointing to ${MCP_SERVER_PATH}."
    fi
  else
    echo "  [info] Global Cursor MCP config is managed in Cursor UI. Please manually add the MCP server:"
    echo "         Command: python3"
    echo "         Args:    ${PROJECT_ROOT}/mcp-server/src/server.py"
  fi
fi

echo ""
echo "-------------------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete. ${install_count} item(s) would be installed, ${skip_count} skipped."
else
  echo " Done. ${install_count} item(s) installed to: ${CURSOR_RULES_DIR}"
  echo " ${skip_count} item(s) skipped (no ${HARNESS}/${RULE_FILE})."
  echo ""
  echo " NOTE: Remember to commit .cursor/rules/ to your workspace repo"
  echo "       so that Cursor can read the rule files."
fi
echo "======================================================="
