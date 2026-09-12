#!/usr/bin/env bash
# =============================================================================
# install_agy.sh — AI SDLC Harness installer for Antigravity (agy)
#
# Installs all skills and agents from this repo into the local Antigravity
# configuration directory at:
#   ~/.gemini/antigravity-cli/builtin/skills/<skill-name>/
#
# Usage:
#   ./install_agy.sh           # Install all skills and agents
#   ./install_agy.sh --dry-run # Preview what would be installed (no changes)
#
# Requirements: bash >= 3.2, cp, mkdir (standard Unix utilities only)
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Absolute path to the root of this repository (directory containing this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Antigravity skills destination directory (default global)
AGY_SKILLS_DIR="${HOME}/.gemini/antigravity-cli/builtin/skills"
WORKSPACE=""

# Target harness subdirectory name (within each skill/agent folder)
HARNESS="agy"

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
      WORKSPACE="$(cd "$WORKSPACE" && pwd)"
      AGY_SKILLS_DIR="${WORKSPACE}/.antigravity/skills"
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
  local item_dir="$1"   # e.g. skills/code-reviewer or agents/my-agent
  local item_name
  item_name="$(basename "$item_dir")"
  local harness_dir="${item_dir}/${HARNESS}"
  local dest="${AGY_SKILLS_DIR}/${item_name}"

  # Skip if this skill/agent has no agy/ subdirectory
  if [[ ! -d "$harness_dir" ]]; then
    echo "  [skip] ${item_name} — no ${HARNESS}/ subdirectory found"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [dry-run] Would install: ${item_name}"
    echo "            Source:      ${harness_dir}/"
    echo "            Destination: ${dest}/"
    return
  fi

  # Create destination directory if it doesn't exist
  mkdir -p "$dest"

  # Copy all files from the harness subdirectory into the destination.
  # The trailing /. on the source ensures directory contents (not the dir itself) are copied.
  cp -r "${harness_dir}/." "${dest}/"

  echo "  [ok] Installed: ${item_name} → ${dest}/"
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

echo "============================================="
echo " AI SDLC Harness — Antigravity (agy) Installer"
echo "============================================="
echo ""

install_count=0
skip_count=0

# Install skills
if [[ -d "${PROJECT_ROOT}/skills" ]]; then
  echo "Installing skills..."
  for skill_dir in "${PROJECT_ROOT}/skills"/*/; do
    [[ -d "$skill_dir" ]] || continue
    install_item "$skill_dir"
    if [[ -d "${skill_dir}/${HARNESS}" ]]; then
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
    if [[ -d "${agent_dir}/${HARNESS}" ]]; then
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
    if [[ -d "${rule_dir}/${HARNESS}" ]]; then
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
    MCP_CONFIG_DIR="${WORKSPACE}/.antigravity"
  else
    MCP_CONFIG_DIR="${HOME}/.gemini/config"
  fi
  
  mkdir -p "$MCP_CONFIG_DIR"
  MCP_CONFIG_FILE="${MCP_CONFIG_DIR}/mcp.json"
  
  # Note: jq is typically required for safe JSON manipulation, but for 
  # zero-dependency we will construct a basic config if it doesn't exist,
  # or warn the user if it does exist.
  
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
fi

echo ""
echo "---------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete. ${install_count} item(s) would be installed, ${skip_count} skipped."
else
  echo " Done. ${install_count} item(s) installed to: ${AGY_SKILLS_DIR}"
  echo " ${skip_count} item(s) skipped (no ${HARNESS}/ subdirectory)."
fi
echo "============================================="
