# Installation and Usage Guide

This guide explains how to deploy the AI SDLC Harness to a real repository and begin using it with your AI IDE of choice.

## Installer locations

All installers live under `install/`, not the repo root:

| Harness | Bash | PowerShell | Scope |
|---|---|---|---|
| Antigravity (agy) | `install/install_agy.sh` | `install/install_agy.ps1` | Global **or** workspace |
| Claude Code | `install/install_claude.sh` | `install/install_claude.ps1` | Global **or** workspace |
| Cursor | `install/install_cursor.sh` | `install/install_cursor.ps1` | Workspace only |
| GitHub Copilot (ghcp) | `install/install_ghcp.sh` | `install/install_ghcp.ps1` | Workspace only |

On Windows, run the `.ps1` scripts from PowerShell (`-Workspace` / `-DryRun` instead of `--workspace` / `--dry-run`).

## `--workspace` vs global

- **Cursor and GitHub Copilot** always install into a workspace. Pass `--workspace /path/to/your/project`. If you omit the flag, the installer uses `$PWD` (the directory you ran the script from).
- **Claude Code and Antigravity** install **globally** when you omit `--workspace` (`~/.claude/commands/` and `~/.gemini/antigravity-cli/builtin/skills/` respectively). Pass `--workspace` to keep skills inside the project instead (`<ws>/.claude/commands/` or `<ws>/.agents/skills/`).

`--dry-run` / `-DryRun` prints what would be removed, copied, and which MCP file would be written or merged, without creating or deleting files.

Matching uninstallers live beside each installer (`install/uninstall_<harness>.sh` / `.ps1`). They remove only `sdlc-*` destinations and, where implemented, drop the `sdlc-knowledge` MCP server key without deleting the rest of the config.

## Step 1: Install skills and configure MCP

From a clone of this repository:

```bash
git clone https://github.com/mjbvilhena/ai-sdlc-harness.git
cd ai-sdlc-harness

# Example: configure a real project for every harness
./install/install_agy.sh --workspace /path/to/your/real-project
./install/install_claude.sh --workspace /path/to/your/real-project
./install/install_cursor.sh --workspace /path/to/your/real-project
./install/install_ghcp.sh --workspace /path/to/your/real-project
```

PowerShell (from the same clone):

```powershell
.\install\install_agy.ps1 -Workspace C:\path\to\your\real-project
.\install\install_claude.ps1 -Workspace C:\path\to\your\real-project
.\install\install_cursor.ps1 -Workspace C:\path\to\your\real-project
.\install\install_ghcp.ps1 -Workspace C:\path\to\your\real-project
```

### What the installers do automatically

1. **Clean previous `sdlc-*` artifacts**, then **inject skills and rules** with `sdlc-` destination names (the prefix is added at install time if a source folder somehow lacks it). YAML frontmatter `name:` is rewritten to match. Only harness-owned `sdlc-*` files/dirs are removed; other user content in the same directory is preserved:
   - Claude: `sdlc-*.md` under `~/.claude/commands/` or `<ws>/.claude/commands/`
   - Cursor: `sdlc-*.md` under `<ws>/.cursor/prompts/`
   - AGY: `sdlc-*` directories under the chosen skills root
   - GitHub Copilot: `sdlc-*.instructions.md` under `<ws>/.github/instructions/`

   Library prompts are then copied into those same hidden directories:
   - AGY workspace: `.agents/skills/`
   - Claude workspace: `.claude/commands/`
   - Cursor: `.cursor/prompts/`
   - GitHub Copilot: `.github/instructions/`
2. **Attach the MCP server** by merging `sdlc-knowledge` into the host config (existing sibling servers are kept; the `sdlc-knowledge` key is created or updated):

   | Harness | MCP config written | JSON shape |
   |---|---|---|
   | Claude (workspace) | `<ws>/claude_desktop_config.json` | `mcpServers` |
   | Claude (global) | `~/.claude/claude_desktop_config.json` | `mcpServers` |
   | Cursor | `<ws>/.cursor/mcp.json` | `mcpServers` |
   | AGY (workspace) | `<ws>/.agents/mcp_config.json` | `mcpServers` |
   | AGY (global) | `~/.gemini/config/mcp_config.json` | `mcpServers` |
   | GitHub Copilot | `<ws>/.vscode/mcp.json` | `servers` (VS Code / Copilot schema) |

   GitHub Copilot Chat in VS Code documents workspace MCP servers in [`.vscode/mcp.json`](https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp-in-your-ide/extend-copilot-chat-with-mcp) with a top-level `servers` key (not `mcpServers`). After install, start the server from that file (VS Code shows a Start control) so Copilot can discover `sdlc-knowledge` tools.

   Bash installers set the MCP `command` to `mcp-server/venv/bin/python` from this clone (args: `mcp-server/src/server.py`). Create that venv before starting the server:

   ```bash
   python3 -m venv mcp-server/venv
   mcp-server/venv/bin/pip install -r mcp-server/requirements.txt
   ```

   Skill *installation* does not require Python; *running* the knowledge server does. PowerShell installers are not yet at parity (they still create the MCP file only when missing, and invoke `python3` rather than the repo venv).

3. **`agents/`**: If the directory is missing (the current default), installers print that they are skipping agents and continue. Skills are the Lifecycle Drivers.

Commit the workspace-scoped files (`.cursor/prompts/`, `.cursor/mcp.json`, `.github/instructions/`, `.vscode/mcp.json`, `.agents/`, `.claude/`) in the **target** project so teammates get the same prompts and MCP wiring.

To remove a harness install later:

```bash
./install/uninstall_agy.sh --workspace /path/to/your/real-project
./install/uninstall_claude.sh
./install/uninstall_cursor.sh --workspace /path/to/your/real-project
./install/uninstall_ghcp.sh --workspace /path/to/your/real-project
```

Uninstallers delete only `sdlc-*` artifacts. Cursor and AGY Bash uninstallers also remove the `sdlc-knowledge` MCP key from the host config. `uninstall_claude.sh` currently targets the global `~/.claude/commands` tree (workspace uninstall is not wired yet).

## Step 2: Define your project constraints

The harness uses a Tri-Dimensional Framework powered by dynamic consultants. The model can enforce *your* project's rules without pasting them into every prompt.

In the target workspace, add markdown files such as:

- **Domains**: `src/domains/auth/DOMAIN.md` (for example, "Authentication must go through AuthService.")
- **Layers**: `src/ui/LAYER.md` (for example, "UI components must be purely functional.")

The MCP tools `get_domain_consultant` and `get_layer_consultant` discover these files by walking the workspace.

## Step 3: Trigger a Lifecycle Driver

Open the target project in Antigravity, Cursor, Claude Code, or VS Code with GitHub Copilot. Invoke a skill, for example:

> `Please run the /sdlc-code-reviewer skill on my current branch.`

**The model should:**

1. Recognize the `/sdlc-code-reviewer` (or equivalent) instructions.
2. Query the MCP server for Domain/Layer consultants and, when relevant, Definition of Done.
3. Review the change against those constraints plus the diff — without inventing product claims.

Other drivers follow the same pattern: fetch templates or consultants from MCP, then write the artifact. Besides `/story`, `/threat`, `/e2e`, `/postmortem`, and `/release-notes`, the library includes `/rfc`, `/triage`, `/runbook`, `/api-design`, `/security-review`, and `/migration`, plus the a11y and DoD rules.
