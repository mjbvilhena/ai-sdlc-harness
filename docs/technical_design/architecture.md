# Architecture Overview

The AI SDLC Harness has a deliberately minimal architecture. There is no compiler engine, no schema parser, and no runtime. The system consists of:

1. **A skill/rule library** — directories of pre-authored, target-specific files. These are the **Lifecycle Drivers** today.
2. **Installer scripts (Bash / PowerShell)** under `install/` — scripts that copy those files to the correct locations on the user's machine.
3. **An optional MCP knowledge server** under `mcp-server/` — Just-In-Time templates, Definitions of Done, and Domain/Layer consultants.

A separate `agents/` tree is deferred. Installers already iterate `agents/` when present and skip it when absent.

## High-Level Flow

```
User runs: ./install/install_claude.sh
    │
    ▼
install/install_claude.sh
    │
    ├─→ Iterates over skills/*/claude/
    │       │
    │       └─→ For each skill with a claude/ subdirectory:
    │               Copy contents → ~/.claude/commands/
    │                   (or <ws>/.claude/commands/ with --workspace)
    │
    ├─→ Iterates over agents/*/claude/   (skipped if agents/ is absent)
    │
    └─→ Iterates over rules/*/claude/
            │
            └─→ For each rule with a claude/ subdirectory:
                    Copy contents → ~/.claude/commands/
```

The same pattern applies for `./install/install_cursor.sh`, `./install/install_ghcp.sh`, and `./install/install_agy.sh` across both `.sh` and `.ps1` variants.

## Skill Library Layout

```
skills/
└─ <skill-name>/
       ├─ skill.yaml          ← Metadata only. Not parsed by scripts.
       ├─ claude/
       │     └─ command.md    ← Copied verbatim to Claude commands dir
       ├─ cursor/
       │     └─ rule.mdc      ← Copied verbatim to Cursor rules dir
       ├─ ghcp/
       │     └─ instructions.md  ← Copied verbatim to workspace instructions dir
       └─ agy/
             └─ SKILL.md      ← Copied verbatim to AGY config dir
```

*(The `rules/` directory follows this same layout. `agents/` would follow it too when introduced.)*

Each target-specific file is authored natively — it contains exactly what the target harness expects to read. The installer scripts do not transform, template, or parse these files. They are copied as-is.

## Installer Script Structure

Each installer script follows the same internal structure:

```
install/install_<harness>.sh | .ps1
    │
    ├─ 1. Resolve DEST (destination directory, absolute path)
    │       e.g., CLAUDE_COMMANDS_DIR="${HOME}/.claude/commands"
    │
    ├─ 2. Resolve SCRIPT_DIR / PROJECT_ROOT (install/ → repo root)
    │
    ├─ 3. For each item in skills/*/, agents/*/ (if present), rules/*/:
    │       a. Check if <item>/<harness>/ exists → skip if not
    │       b. Copy the harness file(s) to DEST
    │       c. Print: "Installed <name> → …"
    │
    ├─ 4. Print summary: N items installed.
    │
    └─ 5. Configure MCP Server (unless --dry-run / -DryRun)
            Creates the host config if missing; does not overwrite:
              Claude  → claude.json (`mcpServers`)
              Cursor  → <ws>/.cursor/mcp.json (`mcpServers`)
              AGY     → <ws>/.agents/mcp_config.json or ~/.gemini/config/mcp_config.json
              GHCP    → <ws>/.vscode/mcp.json (`servers` — VS Code / Copilot schema)
```

## Design Principles

- **No runtime dependencies for install**: Installers use only native system shell utilities (POSIX `bash`, `cp`, `mkdir` for Unix systems, and native PowerShell for Windows).
- **No parsing**: Metadata files (`skill.yaml`, `rule.yaml`, etc.) are read by humans and CI validators only; installer scripts do not parse them.
- **Idempotency**: Copying files with `cp` / `Copy-Item` is naturally idempotent. Running installers multiple times is safe. Existing MCP JSON is left untouched.
- **Isolation**: Each harness installer is independent. Running `install/install_claude.sh` does not affect Cursor or Antigravity configuration, and vice versa.

## MCP Knowledge Server & Dynamic Consultants

In addition to static skills, this project includes a standalone Model Context Protocol (MCP) server in the `mcp-server/` directory.

The MCP server acts as an intelligent knowledge retrieval layer for the Lifecycle Drivers (the installed skills/rules), fulfilling the role of "Consultants" in the Tri-Dimensional Framework:

- **SDLC Templates**: Tools like `get_sdlc_template` and `get_definition_of_done` serve foundational project standards (ADRs, PR checklists, user stories, incident post-mortems).
- **Dynamic Consultant Discovery**: Tools like `get_domain_consultant` and `get_layer_consultant` dynamically scan the user's `WORKSPACE_ROOT` for `DOMAIN.md` and `LAYER.md` files. This allows the MCP server to construct constraints that reflect the real-time architectural state of the user's repository without hardcoded mappings.

Lifecycle Driver prompts (e.g., `sdlc-user-story-refiner`, `sdlc-code-reviewer`, `sdlc-dod-checker`) explicitly instruct the model to query this MCP server for templates and constraints before generating artifacts.
