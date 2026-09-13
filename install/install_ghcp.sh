#!/usr/bin/env bash
# =============================================================================
# install_ghcp.sh — AI SDLC Harness installer for GitHub Copilot (ghcp)
#
# Installs all skills and agents from this repo as GitHub Copilot instruction
# files into the target workspace's .github/instructions/ directory.
#
# Each skill's ghcp/instructions.md is installed as:
#   <workspace>/.github/instructions/sdlc-<skill-name>.instructions.md
#
# Naming: destination filenames are always sdlc- prefixed (source folder
# basename is used as-is when it already starts with sdlc-).
# Cleanup: before installing, existing sdlc-*.instructions.md files in
# .github/instructions/ are removed (dry-run prints them only).
# Non-sdlc-* files are left alone.
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
HARNESS="ghcp"

# The filename inside each ghcp/ subdirectory to install
INSTRUCTIONS_FILE="instructions.md"

# Dry-run mode flag
DRY_RUN=false

# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/expand_content.sh
. "${SCRIPT_DIR}/lib/expand_content.sh"
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
  local item_dir="$1"   # e.g. skills/sdlc-code-reviewer or agents/my-agent
  local item_name
  item_name="$(sdlc_prefixed_name "$(basename "$item_dir")")"
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

echo "======================================================="
echo " AI SDLC Harness — GitHub Copilot (ghcp) Installer"
echo "======================================================="
echo " Workspace: ${WORKSPACE}"
echo " Destination: ${GHCP_INSTRUCTIONS_DIR}"
echo ""

remove_sdlc_files "${GHCP_INSTRUCTIONS_DIR}" "sdlc-*.instructions.md" "${DRY_RUN}"
echo ""

install_count=0
skip_count=0

# Install skills
if [[ -d "${PROJECT_ROOT}/skills" ]]; then
  echo "Installing skills..."
  for skill_dir in "${PROJECT_ROOT}/skills"/*/; do
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
if [[ -d "${PROJECT_ROOT}/agents" ]]; then
  echo "Installing agents..."
  for agent_dir in "${PROJECT_ROOT}/agents"/*/; do
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
if [[ -d "${PROJECT_ROOT}/rules" ]]; then
  echo "Installing rules..."
  for rule_dir in "${PROJECT_ROOT}/rules"/*/; do
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

# ---------------------------------------------------------------------------
# Configure MCP Server (VS Code / GitHub Copilot workspace)
# ---------------------------------------------------------------------------
# GitHub Copilot Chat in VS Code reads workspace MCP servers from
# `.vscode/mcp.json` using a top-level `servers` key (not `mcpServers`).
# See: https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp-in-your-ide/extend-copilot-chat-with-mcp
# and https://code.visualstudio.com/docs/copilot/chat/mcp-servers
if [[ "$DRY_RUN" == true ]]; then
  echo "[dry-run] Would configure MCP Server in .vscode/mcp.json"
else
  echo "Configuring MCP Server..."
  MCP_CONFIG_DIR="${WORKSPACE}/.vscode"
  mkdir -p "$MCP_CONFIG_DIR"
  MCP_CONFIG_FILE="${MCP_CONFIG_DIR}/mcp.json"
  MCP_SERVER_PATH="${PROJECT_ROOT}/mcp-server/src/server.py"

  if [[ ! -f "$MCP_CONFIG_FILE" ]]; then
    cat <<EOF > "$MCP_CONFIG_FILE"
{
  "servers": {
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
fi

echo ""
echo "-------------------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete. ${install_count} item(s) would be installed, ${skip_count} skipped."
else
  echo " Done. ${install_count} item(s) installed to: ${GHCP_INSTRUCTIONS_DIR}"
  echo " ${skip_count} item(s) skipped (no ${HARNESS}/${INSTRUCTIONS_FILE})."
  echo ""
  echo " NOTE: Remember to commit .github/instructions/ and .vscode/mcp.json"
  echo "       to your workspace repo so GitHub Copilot can read them."
fi
echo "======================================================="
