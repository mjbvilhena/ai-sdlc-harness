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

On Windows, run the `.ps1` scripts from PowerShell (`-Workspace` / `-DryRun` instead of `--workspace` / `--dry-run`). **`install_cursor.ps1` is not at dest parity** with the Bash installer: it still looks for `cursor/rule.mdc` and writes `.cursor/rules/*.mdc`, so it would skip every current skill and rule (Task 12.1). Use `install/install_cursor.sh` until that is fixed.

## `--workspace` vs global

- **Cursor and GitHub Copilot** always install into a workspace. Pass `--workspace /path/to/your/project`. If you omit the flag, the installer uses `$PWD` (the directory you ran the script from).
- **Claude Code and Antigravity** install **globally** when you omit `--workspace` (`~/.claude/commands/` and `~/.gemini/antigravity-cli/builtin/skills/` respectively). Pass `--workspace` to keep skills inside the project instead (`<ws>/.claude/commands/` or `<ws>/.agents/skills/`).

`--dry-run` / `-DryRun` prints what would be removed, copied, and which MCP file would be written or merged, without creating or deleting files.

Matching uninstallers live beside each installer (`install/uninstall_<harness>.sh` / `.ps1`). They are **intended** to remove only `sdlc-*` destinations and drop the `sdlc-knowledge` MCP key without deleting sibling servers. They are not a reliable reverse of today's installers (Task 12.3): `uninstall_cursor.sh` still targets `.cursor/prompts/` while the Bash installer writes `.cursor/commands/`; `uninstall_claude.sh` deletes `sdlc-*.json` and ignores `--workspace`; GHCP never drops the MCP key; PowerShell uninstallers source missing `lib/sdlc_names.ps1` and fail before cleanup.

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
.\install\install_cursor.ps1 -Workspace C:\path\to\your\real-project   # broken dest — Task 12.1; use the .sh installer
.\install\install_ghcp.ps1 -Workspace C:\path\to\your\real-project
```

### What the installers do automatically

1. **Clean previous `sdlc-*` artifacts**, then **inject skills and rules** with `sdlc-` destination names (the prefix is added at install time if a source folder somehow lacks it). YAML frontmatter `name:` is rewritten to match. Only harness-owned `sdlc-*` files/dirs are removed; other user content in the same directory is preserved:
   - Claude: `sdlc-*.md` under `~/.claude/commands/` or `<ws>/.claude/commands/`
   - Cursor: `sdlc-*.md` under `<ws>/.cursor/commands/`
   - AGY: `sdlc-*` directories under the chosen skills root
   - GitHub Copilot: `sdlc-*.instructions.md` under `<ws>/.github/instructions/`

   Library prompts are then expanded into those same hidden directories:
   - AGY workspace: `.agents/skills/`
   - Claude workspace: `.claude/commands/`
   - Cursor: `.cursor/commands/`
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

   A live (non-`--dry-run`) Bash install currently invokes host `python3` to merge that JSON, then sets MCP `command` to `mcp-server/venv/bin/python` from this clone (args: `mcp-server/src/server.py`). Create that venv before starting the server:

   ```bash
   python3 -m venv mcp-server/venv
   mcp-server/venv/bin/pip install -r mcp-server/requirements.txt
   ```

   The copy/expand step itself does not require Python; *running* the knowledge server does. `--dry-run` does not call Python. PowerShell installers are not yet at MCP parity (they still create the MCP file only when missing, and invoke `python3` rather than the repo venv). `install_cursor.ps1` additionally uses the old `.cursor/rules/*.mdc` dest (Task 12.1).

3. **`agents/`**: If the directory is missing (the current default), installers print that they are skipping agents and continue. Skills are the Lifecycle Drivers.

Commit the workspace-scoped files (`.cursor/commands/`, `.cursor/mcp.json`, `.github/instructions/`, `.vscode/mcp.json`, `.agents/`, `.claude/`) in the **target** project so teammates get the same prompts and MCP wiring.

To remove a harness install later:

```bash
./install/uninstall_agy.sh --workspace /path/to/your/real-project
./install/uninstall_claude.sh
./install/uninstall_cursor.sh --workspace /path/to/your/real-project
./install/uninstall_ghcp.sh --workspace /path/to/your/real-project
```

When they run, uninstallers delete only `sdlc-*` artifacts (PowerShell uninstallers currently fail first — Task 12.3). Cursor and AGY Bash uninstallers also remove the `sdlc-knowledge` MCP key from the host config. `uninstall_claude.sh` currently targets the global `~/.claude/commands` tree (workspace uninstall is not wired yet) and deletes `sdlc-*.json` while install writes `sdlc-*.md`. `uninstall_cursor.sh` currently removes `.cursor/prompts/sdlc-*.md`, not the `.cursor/commands/` files the installer now writes. `uninstall_ghcp.sh` / `.ps1` do not remove `sdlc-knowledge` from `.vscode/mcp.json`.

## Step 2: Define your project constraints

The harness uses a Tri-Dimensional Framework powered by dynamic consultants. The model can enforce *your* project's rules without pasting them into every prompt.

In the target workspace, add markdown files such as:

- **Domains**: `src/domains/auth/DOMAIN.md` (for example, "Authentication must go through AuthService.")
- **Layers**: `src/ui/LAYER.md` (for example, "UI components must be purely functional.")

The MCP tools `get_domain_consultant` and `get_layer_consultant` discover these files by walking `WORKSPACE_ROOT` (env var, else the MCP process CWD). Installers do not set that env var today (Task 12.8), so after install the scan follows whatever directory the IDE uses when it starts `mcp-server`.

## Step 3: Trigger a Lifecycle Driver

Open the target project in Antigravity, Cursor, Claude Code, or VS Code with GitHub Copilot. For “what next?”, invoke the default front door:

> `Please run /sdlc-conductor` (also `/conductor`, or ask “what next?”)

It inspects the repo, recommends the next legal pipeline step (including a design & planning band after stories — not stories → setup → code), confirms, and hands off. Experts may still call a specialist skill directly, for example:

> `Please run the /review skill on my current branch.`

**For `/sdlc-conductor`, the model should** inspect the workspace, recommend the next legal step (confirm before hand-off), and refuse to invent UI or domain rules.

**For a specialist such as `/review`, the model should:**

1. Recognize the `/review` instructions (Claude Trigger and `skills/sdlc-code-reviewer/skill.yaml`; Cursor dest filename is `sdlc-code-reviewer.md`).
2. Query the MCP server for Domain/Layer consultants and, when relevant, Definition of Done.
3. Review the change against those constraints plus the diff — without inventing product claims.

Other drivers follow the same pattern: fetch templates or consultants from MCP, then write the artifact. Besides `/sdlc-conductor` (default front door; fetches `lifecycle pipeline`), `/story`, `/ux` (also `/ux-design` — wireframes/flows/copy from stories; template `ux design`), `/threat`, `/e2e`, `/postmortem`, `/release-notes`, `/review`, `/pr`, and `/test`, the library includes `/sdlc-product-owner` (vision → epics / product spec), `/research`, `/setup-repo`, `/rfc`, `/triage`, `/runbook`, `/api-design`, `/security-review`, `/migration`, `/adr`, `/ci`, `/docs-backlog-review` (full-repo docs↔code + backlog hygiene; template `docs backlog review`; distinct from `/docs`, which updates docs for a recent code change), `/domain-architect`, and `/layer-architect`, plus the a11y and DoD rules. Primary triggers for every skill live in `skills/*/skill.yaml`. Design: [sdlc-conductor.md](../technical_design/sdlc-conductor.md).
