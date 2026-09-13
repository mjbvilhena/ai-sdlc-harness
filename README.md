# AI SDLC Harness

A shell-script-based installer that deploys a curated library of AI skills and rules into your local AI tooling environments.

Skill installation is zero-dependency: just shell or PowerShell scripts and file copies. An optional MCP knowledge server under `mcp-server/` needs a local Python runtime if you want Just-In-Time SDLC templates, Definitions of Done, and Domain/Layer consultants. Payloads live in `mcp-server/data/templates/` and `mcp-server/data/dod/` (ADR, RFC, PR, threat model, API design, runbook, migration, and change-type DoD such as `security change` / `api change`). Skills instruct the model to fetch those documents rather than hardcoding them.

## How It Works

Skills in this repo are **authored once per target harness** — each skill has a dedicated file written in the exact format that a given AI tool expects (e.g. a `SKILL.md` for Antigravity, a `command.md` for Claude Code, a `rule.mdc` for Cursor). A top-level installer script for each harness discovers all skills in the `skills/` directory and copies the correct files into the right place on your machine.

Lifecycle Drivers today live as these `skills/` (and ambient `rules/`). A separate `agents/` tree is deferred; installers already skip it when the directory is absent.

## Supported Harnesses (v1)

| Harness | Installer | Install location |
|---|---|---|
| **Antigravity (agy)** | `install/install_agy.sh` | Global: `~/.gemini/antigravity-cli/builtin/skills/<skill-name>/`. Workspace: `<ws>/.agents/skills/` |
| **Claude Code** | `install/install_claude.sh` | Global: `~/.claude/commands/`. Workspace: `<ws>/.claude/commands/` |
| **Cursor** | `install/install_cursor.sh` | `<ws>/.cursor/rules/` (workspace-scoped; defaults to `$PWD`) |
| **GitHub Copilot (ghcp)** | `install/install_ghcp.sh` | `<ws>/.github/instructions/` (workspace-scoped; defaults to `$PWD`) |

PowerShell equivalents live beside the Bash scripts (`install/install_*.ps1`).

## Installation

Clone this repo and run the installer for the harness you use:

```bash
git clone https://github.com/mjbvilhena/ai-sdlc-harness.git
cd ai-sdlc-harness

# Antigravity (global builtin skills)
./install/install_agy.sh

# Claude Code (global commands)
./install/install_claude.sh

# Cursor (workspace rules + `.cursor/mcp.json`)
./install/install_cursor.sh --workspace /path/to/your/project

# GitHub Copilot (workspace instructions + `.vscode/mcp.json`)
./install/install_ghcp.sh --workspace /path/to/your/project
```

`--workspace` is **required in practice** for Cursor and GitHub Copilot (they always install into a workspace; omitting the flag uses `$PWD`). For Claude and Antigravity it is optional: omit it for a user-global install, or pass it for a project-local install.

The installer scripts require no dependencies beyond standard Unix shell utilities (`bash`, `cp`, `mkdir`) or native PowerShell on Windows.

## Repository Structure

```
ai-sdlc-harness/
├── README.md
├── CONTRIBUTING.md
├── run_tests.sh             # Unified local test runner
├── install/                 # Harness installers (Bash + PowerShell)
│   ├── install_agy.sh
│   ├── install_claude.sh
│   ├── install_cursor.sh
│   └── install_ghcp.sh
├── skills/                  # Lifecycle Driver skill definitions
│   └── sdlc-example-skill/
│       ├── skill.yaml
│       ├── CONTENT.md           # Canonical body; installers expand into harness files
│       ├── agy/SKILL.md         # Thin shell with {{SKILL_BODY}}
│       ├── claude/command.md
│       ├── cursor/rule.mdc
│       └── ghcp/instructions.md
├── rules/                   # Ambient rules (same harness layout)
├── mcp-server/              # Optional Python MCP knowledge server
├── tests/                   # BATS installer tests + E2E suites
└── docs/
```

`agents/` is not populated. Installers iterate `agents/` when present and skip it otherwise.

## Adding a New Skill

1. Create a directory under `skills/` with your skill's name (`sdlc-` prefix, kebab-case):
   ```bash
   mkdir -p skills/sdlc-my-skill/{agy,claude,cursor,ghcp}
   ```

2. Create `skills/sdlc-my-skill/skill.yaml` with metadata:
   ```yaml
   name: sdlc-my-skill
   description: What this skill does.
   version: 0.1.0
   author: Your Name
   targets:
     - agy
     - claude
     - cursor
     - ghcp
   triggers:
     - /sdlc-my-skill
   ```

3. Author `CONTENT.md` (the shared instructions) and thin harness shells that contain `{{SKILL_BODY}}` on its own line:
   - `skills/sdlc-my-skill/CONTENT.md` — canonical body
   - `skills/sdlc-my-skill/agy/SKILL.md` — Antigravity frontmatter + title
   - `skills/sdlc-my-skill/claude/command.md` — Claude trigger + title
   - `skills/sdlc-my-skill/cursor/rule.mdc` — Cursor frontmatter + title
   - `skills/sdlc-my-skill/ghcp/instructions.md` — GitHub Copilot title

   Rules use `{{RULE_BODY}}` the same way. Installers expand the placeholder from `CONTENT.md`; they fail if either the file or the placeholder is missing.

4. Re-run the relevant installer(s).

See [`skills/sdlc-example-skill/`](skills/sdlc-example-skill/) for a complete example.

## Contributing

Pull requests for new skills, improved instructions, or additional harness installers are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md) and `docs/` for specification, architecture, and authoring guides.

## Installation & Usage

To deploy this harness into a real project (including `--workspace` nuances, PowerShell installers, and MCP auto-configuration), read the [Installation and Usage Guide](docs/guides/installation-and-usage.md).

## Testing

To run the local test suites (metadata validation, MCP unit tests, and BATS shell tests):

```bash
./run_tests.sh
```

For End-to-End LLM evaluations using a Gemini API key, see the Testing section in [`CONTRIBUTING.md`](CONTRIBUTING.md).
