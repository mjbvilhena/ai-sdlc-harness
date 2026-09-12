# Product Vision & Goals

## Vision

The AI SDLC Harness is a simple, dependency-free installer that deploys a curated library of AI skills, rules, and agents into the local configuration directories of popular AI developer tools.

The core philosophy is built on three pillars:
1. **Multi-Harness Native Authoring**: Rather than compiling a universal format into multiple targets, skills are **authored directly in the native format of each target harness**. Installing them means copying those files to the right place.
2. **Tri-Dimensional Agent Framework (Multi-Harness)**: We structure AI tasks across three orthogonal dimensions: Lifecycle (The Driver), Domain (The Consultant), and Layer (The Consultant). While each harness (e.g., Claude Code, Cursor, GitHub Copilot, Antigravity) has its own native mechanisms for managing prompts or background agents, this conceptual framework ensures they all follow the same strict separation of concerns.
3. **Decoupled Knowledge via JIT Retrieval (MCP)**: To prevent prompt bloat, we separate *execution mechanism* from *operational knowledge*. While the native prompt acts as the execution engine, heavy knowledge—including Domain and Layer contexts (the "Consultants") as well as Lifecycle governance (Definitions of Done, phase entry/exit criteria, SDLC templates, and review checklists)—is extracted into a standalone Model Context Protocol (MCP) server. Agents across all harnesses use standardized MCP tools to dynamically retrieve this context just-in-time.

## Goals

1. **Frictionless Installation**: Simple shell and PowerShell scripts (`./install_claude.sh`, `./install_claude.ps1`, etc.) deploy the right prompts to the right places without complex build steps.
2. **Author-native skills**: Skill authors write directly in the format that each AI tool understands — no intermediate abstraction layer.
3. **Universal Knowledge & Governance**: By shifting Domain, Layer, and Lifecycle governance (DoD, checklists, templates) into an MCP server, all harnesses (e.g., Claude Code, Cursor, GitHub Copilot, Antigravity) share the exact same standards and policies.
4. **Lean Driver Payloads**: Harness-specific prompts (the "Drivers") are stripped down to focus exclusively on execution flow and tool invocation, querying MCP just-in-time for both lifecycle requirements and domain/layer knowledge.
5. **Easy contribution**: Adding a new skill is as simple as creating a directory, dropping in files, and opening a PR.

## Target Harnesses (v1)

- **Claude Code**: Skills installed as custom slash commands to `~/.claude/commands/`
- **Cursor**: Rules installed to `.cursor/rules/`
- **GitHub Copilot (ghcp)**: Instructions installed to `.github/instructions/`
- **Antigravity (agy)**: Skills installed to `~/.gemini/antigravity-cli/builtin/skills/` and workspace agents to `.antigravity/`

## Non-Goals

- **Universal format / compilation**: We do not aim to write once and compile to all targets. Target-specific authoring is intentional.
- **Cloud registry or distribution**: Skills are distributed via Git. There is no hosted registry.
- **Runtime skill management**: There is no daemon, watcher, or auto-update mechanism.
