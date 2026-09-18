# Product Vision & Goals

## Vision

The AI SDLC Harness is a simple installer that deploys a curated library of AI skills and rules into the local configuration directories of popular AI developer tools. Skill/rule copy and expand is zero-dependency (shell/PowerShell). A live installer currently also needs host `python3` to merge MCP JSON. An optional MCP knowledge server under `mcp-server/` requires Python to serve templates.

The core philosophy is built on three pillars:
1. **Multi-Harness Native Authoring**: Shared instructions live once in `CONTENT.md`. Each target still has a **thin native shell** (frontmatter, titles, Claude triggers) — we do not compile an AGY `SKILL.md` into a Claude `command.md`. Installers expand `{{SKILL_BODY}}` / `{{RULE_BODY}}` into those shells and write the resolved files to the right place.
2. **Tri-Dimensional Agent Framework (Multi-Harness)**: We structure AI tasks across three orthogonal dimensions: Lifecycle (The Driver), Domain (The Consultant), and Layer (The Consultant). **Lifecycle Drivers currently live as `skills/` (and ambient `rules/`)** — a separate `agents/` package tree is deferred. Each harness has its own native prompt primitives; the framework keeps the same separation of concerns.
3. **Decoupled Knowledge via JIT Retrieval (MCP)**: To prevent prompt bloat, we separate *execution mechanism* from *operational knowledge*. While the native prompt acts as the execution engine, heavy knowledge—including Domain and Layer contexts (the "Consultants") as well as Lifecycle governance (Definitions of Done, phase entry/exit criteria, SDLC templates, and review checklists)—is extracted into a standalone Model Context Protocol (MCP) server. Agents across all harnesses use standardized MCP tools to dynamically retrieve this context just-in-time.

## Goals

1. **Frictionless Installation**: Simple shell and PowerShell scripts under `install/` (`./install/install_claude.sh`, `./install/install_claude.ps1`, etc.) deploy the right prompts to the right places without complex build steps.
2. **Author-native shells, shared body**: Skill authors keep harness-specific frontmatter and triggers in each target's thin shell. Operational instructions live in `CONTENT.md` and are expanded at install time.
3. **Universal Knowledge & Governance**: By shifting Domain, Layer, and Lifecycle governance (DoD, checklists, templates) into an MCP server, all harnesses (e.g., Claude Code, Cursor, GitHub Copilot, Antigravity) share the exact same standards and policies.
4. **Lean Driver Payloads**: Harness-specific prompts (the "Drivers") are stripped down to focus exclusively on execution flow and tool invocation, querying MCP just-in-time for both lifecycle requirements and domain/layer knowledge.
5. **Easy contribution**: Adding a new skill is as simple as creating a directory, dropping in files, and opening a PR.

## Target Harnesses (v1)

- **Claude Code**: Skills installed as custom slash commands to `~/.claude/commands/` (or `<ws>/.claude/commands/` with `--workspace`)
- **Cursor**: Slash commands installed to `<ws>/.cursor/commands/`
- **GitHub Copilot (ghcp)**: Instructions installed to `<ws>/.github/instructions/`
- **Antigravity (agy)**: Skills installed globally to `~/.gemini/antigravity-cli/builtin/skills/` or, with `--workspace`, to `<ws>/.agents/skills/`. Workspace MCP config is `<ws>/.agents/mcp_config.json`.

## Non-Goals

- **Universal format / compilation**: We do not compile one harness file into the others. A shared `CONTENT.md` body with per-target shells is intentional; it is not a universal compiler.
- **Cloud registry or distribution**: Skills are distributed via Git. There is no hosted registry.
- **Runtime skill management**: There is no daemon, watcher, or auto-update mechanism.
