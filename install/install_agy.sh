#!/usr/bin/env bash
# =============================================================================
# install_agy.sh — AI SDLC Harness installer for Antigravity (agy)
#
# Installs all skills and agents from this repo into the local Antigravity
# configuration directory at:
#   ~/.gemini/antigravity-cli/builtin/skills/sdlc-<skill-name>/
#
# Naming: destination directory names (and YAML frontmatter name:) are always
# sdlc- prefixed (source folder basename is used as-is when it already
# starts with sdlc-).
# Cleanup: before installing, existing sdlc-* skill directories under the
# chosen skills root are removed (dry-run prints them only). Non-sdlc-*
# neighbors are left alone.
#
# Usage:
#   ./install_agy.sh           # Install all skills and agents
#   ./install_agy.sh --dry-run # Preview what would be installed (no changes)
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

# Antigravity skills destination directory (default global)
AGY_SKILLS_DIR="${HOME}/.gemini/antigravity-cli/builtin/skills"
WORKSPACE=""

# Target harness subdirectory name (within each skill/agent folder)
HARNESS="agy"

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
      AGY_SKILLS_DIR="${WORKSPACE}/.agents/skills"
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
  local dest="${AGY_SKILLS_DIR}/${item_name}"

  # Skip if this skill/agent has no agy/ subdirectory
  if [[ ! -d "$harness_dir" ]]; then
    echo "  [skip] ${item_name} — no ${HARNESS}/ subdirectory found"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [dry-run] Would install: ${item_name}"
    echo "            Source:      ${harness_dir}/ + CONTENT.md"
    echo "            Destination: ${dest}/"
    validate_item_content "$item_dir" "$item_name" "$harness_dir"
    return
  fi

  expand_harness_dir "$item_dir" "$harness_dir" "$dest" "$item_name"
  ensure_sdlc_frontmatter_names_in_dir "$dest" "$item_name"

  echo "  [ok] Installed: ${item_name} → ${dest}/"
}

# ---------------------------------------------------------------------------
# Main install logic
# ---------------------------------------------------------------------------

echo "============================================="
echo " AI SDLC Harness — Antigravity (agy) Installer"
echo "============================================="
echo ""

remove_sdlc_dirs "${AGY_SKILLS_DIR}" "${DRY_RUN}"
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
    MCP_CONFIG_DIR="${WORKSPACE}/.agents"
  else
    MCP_CONFIG_DIR="${HOME}/.gemini/config"
  fi

  echo "Configuring MCP Server..."
  if [[ -n "$MCP_CONFIG_DIR" ]]; then
    mkdir -p "$MCP_CONFIG_DIR"
    MCP_CONFIG_FILE="${MCP_CONFIG_DIR}/mcp_config.json"
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
echo "---------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo " Dry-run complete. ${install_count} item(s) would be installed, ${skip_count} skipped."
else
  echo " Done. ${install_count} item(s) installed to: ${AGY_SKILLS_DIR}"
  echo " ${skip_count} item(s) skipped (no ${HARNESS}/ subdirectory)."
fi
echo "============================================="
