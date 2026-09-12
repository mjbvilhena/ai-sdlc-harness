# Architecture Overview

The AI SDLC Harness has a deliberately minimal architecture. There is no compiler engine, no schema parser, and no runtime. The system consists entirely of:

1. **A skill/agent/rule library** — directories of pre-authored, target-specific files.
2. **Installer scripts (Bash / PowerShell)** — scripts that copy those files to the correct locations on the user's machine.

## High-Level Flow

```
User runs: ./install_claude.sh
    │
    ▼
install_claude.sh
    │
    ├─→ Iterates over skills/*/claude/
    │       │
    │       └─→ For each skill with a claude/ subdirectory:
    │               Copy contents → ~/.claude/commands/
    │
    ├─→ Iterates over agents/*/claude/
    │       │
    │       └─→ For each agent with a claude/ subdirectory:
    │               Copy contents → ~/.claude/commands/
    │
    └─→ Iterates over rules/*/claude/
            │
            └─→ For each rule with a claude/ subdirectory:
                    Copy contents → ~/.claude/commands/
```

The same pattern applies for `install_cursor`, `install_ghcp`, and `install_agy` across both `.sh` and `.ps1` variants.

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

*(The `agents/` and `rules/` directories follow this exact same layout.)*

Each target-specific file is authored natively — it contains exactly what the target harness expects to read. The installer scripts do not transform, template, or parse these files. They are copied as-is.

## Installer Script Structure

Each installer script follows the same internal structure:

```
install_<harness>.sh | .ps1
    │
    ├─ 1. Resolve DEST (destination directory, absolute path)
    │       e.g., CLAUDE_COMMANDS_DIR="${HOME}/.claude/commands"
    │
    ├─ 2. Resolve SCRIPT_DIR (absolute path to this repo root)
    │
    ├─ 3. For each item in skills/*/, agents/*/, rules/*/:
    │       a. Check if <item>/<harness>/ exists → skip if not
    │       b. mkdir -p "${DEST}/<name>"
    │       c. cp -r "<item>/<harness>/." "${DEST}/<name>/"
    │       d. Print: "Installed <name> → ${DEST}/<name>/"
    │
    ├─ 4. Print summary: N items installed.
    │
    └─ 5. Configure MCP Server
            Generates or updates the corresponding `mcp.json` / `claude.json` 
            configuration file so the host IDE immediately knows how to 
            communicate with the AI SDLC Knowledge Server.
```

## Design Principles

- **No runtime dependencies**: Installers use only native system shell utilities (POSIX `bash`, `cp`, `mkdir` for Unix systems, and native PowerShell for Windows).
- **No parsing**: Metadata files (`skill.yaml`, `rule.yaml`, etc.) are read by humans and CI validators only; installer scripts do not parse them.
- **Idempotency**: Copying files with `cp -r` is naturally idempotent. Running installers multiple times is safe.
- **Isolation**: Each harness installer is independent. Running `install_claude.sh` does not affect Cursor or Antigravity configuration, and vice versa.

## MCP Knowledge Server & Dynamic Consultants

In addition to static skills, this project includes a standalone Model Context Protocol (MCP) server in the `mcp-server/` directory.

The MCP server acts as an intelligent knowledge retrieval layer for the AI agents (the "Lifecycle Drivers"), fulfilling the role of "Consultants" in the Tri-Dimensional Framework:

- **SDLC Templates**: Tools like `get_sdlc_template` and `get_definition_of_done` serve foundational project standards (ADRs, PR checklists).
- **Dynamic Consultant Discovery**: Tools like `get_domain_consultant` and `get_layer_consultant` dynamically scan the user's `WORKSPACE_ROOT` for `DOMAIN.md` and `LAYER.md` files. This allows the MCP server to dynamically construct constraints and knowledge payloads that reflect the real-time architectural state of the user's repository without any hardcoded mappings.

The skills we install (e.g., `sdlc-user-story-refiner` or `sdlc-dod-checker`) explicitly instruct the agent to query this MCP server to fetch constraints before generating artifacts.
