# Architecture Overview

The AI SDLC Harness has a deliberately minimal architecture. There is no compiler engine and no schema parser. Skill/rule installation is file copies. The only runtime is the optional MCP knowledge server. The system consists of:

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
    │               Expand CONTENT.md into command.md → ~/.claude/commands/
    │                   (or <ws>/.claude/commands/ with --workspace)
    │
    ├─→ Iterates over agents/*/claude/   (skipped if agents/ is absent)
    │
    └─→ Iterates over rules/*/claude/
            │
            └─→ For each rule with a claude/ subdirectory:
                    Expand CONTENT.md into command.md → ~/.claude/commands/
```

The same pattern applies for `./install/install_cursor.sh` (slash commands under `.cursor/commands/`), `./install/install_ghcp.sh`, and `./install/install_agy.sh`. Bash and PowerShell twins exist for every harness, but `install_cursor.ps1` is not at dest parity yet (it still looks for `cursor/rule.mdc` and writes `.cursor/rules/*.mdc` — Task 12.1). Matching `install/uninstall_*.sh` / `.ps1` scripts are meant to remove `sdlc-*` destinations; known reverse-path bugs are Epic 12.

## Skill Library Layout

```
skills/
└─ <skill-name>/
       ├─ skill.yaml          ← Metadata only. Not parsed by scripts.
       ├─ CONTENT.md          ← Canonical body (expanded at install time)
       ├─ claude/
       │     └─ command.md    ← Thin shell → ~/.claude/commands/ (or <ws>)
       ├─ cursor/
       │     └─ prompt.md     ← Thin shell → <ws>/.cursor/commands/*.md
       ├─ ghcp/
       │     └─ instructions.md  ← Thin shell → <ws>/.github/instructions/sdlc-<name>.instructions.md
       └─ agy/
             └─ SKILL.md      ← Thin shell → AGY skills dir
```

*(The `rules/` directory follows this same layout. `agents/` would follow it too when introduced.)*

Each harness file is a thin shell (frontmatter, title, optional Claude Trigger) plus `{{SKILL_BODY}}` or `{{RULE_BODY}}`. The shared instructions live in sibling `CONTENT.md`. Installers expand the placeholder at install time and write a fully resolved file to the destination — never an unresolved token.

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
    ├─ 3. Remove existing sdlc-* artifacts in DEST (dry-run: print only)
    │
    ├─ 4. For each item in skills/*/, agents/*/ (if present), rules/*/:
    │       a. Normalize dest name to sdlc-* (prefix if the folder lacks it)
    │       b. Check if <item>/<harness>/ exists → skip if not
    │       c. Expand CONTENT.md into the harness shell and write DEST
    │       d. Ensure YAML frontmatter name: is sdlc-* when present
    │       e. Print: "Installed <name> → …"
    │
    ├─ 5. Print summary: N items installed.
    │
    └─ 6. Configure MCP Server (unless --dry-run / -DryRun)
            Bash merges sdlc-knowledge into the host config (keeps sibling servers)
            and sets command to mcp-server/venv/bin/python (args: mcp-server/src/server.py).
            PowerShell twins still create the file only when missing and invoke `python3`
            (Task 12.2). Destinations:
              Claude  → claude_desktop_config.json (`mcpServers`) — PS1 still writes claude.json
              Cursor  → <ws>/.cursor/mcp.json (`mcpServers`)
              AGY     → <ws>/.agents/mcp_config.json or ~/.gemini/config/mcp_config.json
              GHCP    → <ws>/.vscode/mcp.json (`servers` — VS Code / Copilot schema)
```

## Design Principles

- **No runtime dependencies for copy/expand**: Skill/rule expansion uses only native shell utilities (POSIX `bash`, `cp`, `mkdir` on Unix; native PowerShell on Windows). A live install currently invokes host `python3` to merge MCP JSON (Task 12.5).
- **No metadata parsing**: `skill.yaml` / `rule.yaml` are read by humans and CI validators only. Installers do not parse them. They do expand `CONTENT.md` into `{{SKILL_BODY}}` / `{{RULE_BODY}}`.
- **Idempotency**: Expanding the same `CONTENT.md` into the same destination is idempotent. Running installers multiple times is safe. **Bash** merges existing MCP JSON (sibling servers stay; `sdlc-knowledge` is created or updated). **PowerShell** still writes the MCP file only when it is missing and does not update an existing `sdlc-knowledge` entry (Task 12.2).
- **Isolation**: Each harness installer is independent. Running `install/install_claude.sh` does not affect Cursor or Antigravity configuration, and vice versa.

## MCP Knowledge Server & Dynamic Consultants

In addition to static skills, this project includes a standalone Model Context Protocol (MCP) server in the `mcp-server/` directory.

The MCP server acts as an intelligent knowledge retrieval layer for the Lifecycle Drivers (the installed skills/rules), fulfilling the role of "Consultants" in the Tri-Dimensional Framework:

- **SDLC Templates**: `get_sdlc_template` serves markdown under `mcp-server/data/templates/` (**27** files). The catalog covers the original set (ADR, bug report, domain, layer, PR, RFC, user story, incident postmortem) plus threat model, code review, test / e2e plans, release notes, runbook, API design & contract, security review, accessibility audit, migration plan, onboarding guide, rollout plan, product spec, research, repository setup, lifecycle pipeline, UX design, and docs backlog review. Natural-language aliases (`stride`, `changelog`, `playbook`, `openapi`, `prd`, `spike`, `conductor`, `ux`, …) resolve via longest-match in `server.py`.
- **Definitions of Done**: `get_definition_of_done` serves `mcp-server/data/dod/` (**13** files) for `bugfix`, `epic`, `feature`, `hotfix`, `release`, `pr`, `user story`, `security change`, `ui change`, `api change`, `data migration`, `research`, and `repository setup`.
- **Dynamic Consultant Discovery**: Tools like `get_domain_consultant` and `get_layer_consultant` walk `WORKSPACE_ROOT` for `DOMAIN.md` and `LAYER.md` files. That path is `os.getenv("WORKSPACE_ROOT", os.getcwd())` in `mcp-server/src/server.py`. Bash installers write only `command` + `args` into the host MCP config — they do **not** set `env.WORKSPACE_ROOT` to the `--workspace` target — so discovery depends on the MCP host process CWD unless the IDE (or the user) sets the env var (Task 12.8).

Lifecycle Driver prompts (e.g., `sdlc-conductor`, `sdlc-product-owner`, `sdlc-researcher`, `sdlc-setup-repository`, `sdlc-user-story-refiner`, `sdlc-ux-designer`, `sdlc-code-reviewer`, `sdlc-rfc-drafter`, `sdlc-security-reviewer`, `sdlc-docs-backlog-review`) and the ambient `sdlc-dod-checker` **rule** explicitly instruct the model to query this MCP server for templates and constraints before generating artifacts. Tool names stay stable; only payloads, aliases, and tests expand. `sdlc-ux-designer` fetches `ux design` plus `user story` and `ui change` DoD. `sdlc-conductor` fetches `lifecycle pipeline` as the runtime graph. `sdlc-docs-backlog-review` fetches `docs backlog review`.

The default front door is **`sdlc-conductor`** (`/sdlc-conductor`, `/conductor`, “what next?”). Design: [`sdlc-conductor.md`](sdlc-conductor.md). Runtime graph: MCP template `lifecycle pipeline`. It recommends the next legal pipeline step — including a first-class **design & planning** band after story refine (UI/UX via `sdlc-ux-designer`), not stories → setup → code — and stewards cross-cutting memory. It must not replace child-skill authorship or `sdlc-docs-backlog-review`.
