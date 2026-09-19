# AI SDLC Harness

A shell-script-based installer that deploys a curated library of AI skills and rules into your local AI tooling environments.

Skill/rule **copy and expand** is zero-dependency (shell or PowerShell). A live installer currently also needs host `python3` to merge MCP JSON. An optional MCP knowledge server under `mcp-server/` needs a local Python runtime if you want Just-In-Time SDLC templates, Definitions of Done, and Domain/Layer consultants. Payloads live in `mcp-server/data/templates/` and `mcp-server/data/dod/` (ADR, RFC, PR, product spec, research, repository setup, threat model, API design, runbook, migration, and change-type DoD such as `security change` / `api change`). Skills instruct the model to fetch those documents rather than hardcoding them.

**Live catalog:** [Browse skills & MCP catalog](https://mjbvilhena.github.io/ai-sdlc-harness/).

## How It Works

Each skill is **authored once** in `CONTENT.md`. Thin harness shells (`agy/SKILL.md`, `claude/command.md`, `cursor/prompt.md`, `ghcp/instructions.md`) keep frontmatter, titles, and a `{{SKILL_BODY}}` placeholder. An installer under `install/` expands that body from `skills/` and `rules/` and writes the resolved file where the target tool expects it.

Lifecycle Drivers today live as these `skills/` (and ambient `rules/`). A separate `agents/` tree is deferred; installers already skip it when the directory is absent. The default front door is **`sdlc-conductor`** (`/sdlc-conductor`, `/conductor`, “what next?”) — see [`docs/technical_design/sdlc-conductor.md`](docs/technical_design/sdlc-conductor.md).

## Supported Harnesses (v1)

| Harness | Installer | Install location |
|---|---|---|
| **Antigravity (agy)** | `install/install_agy.sh` | Global: `~/.gemini/antigravity-cli/builtin/skills/sdlc-<name>/`. Workspace: `<ws>/.agents/skills/sdlc-<name>/` |
| **Claude Code** | `install/install_claude.sh` | Global: `~/.claude/commands/`. Workspace: `<ws>/.claude/commands/` |
| **Cursor** | `install/install_cursor.sh` | `<ws>/.cursor/commands/` (workspace-scoped slash commands; defaults to `$PWD`) |
| **GitHub Copilot (ghcp)** | `install/install_ghcp.sh` | `<ws>/.github/instructions/sdlc-<name>.instructions.md` (workspace-scoped; defaults to `$PWD`) |

PowerShell equivalents live beside the Bash scripts (`install/install_*.ps1`). **`install_cursor.ps1` is not at dest parity** — it still looks for `cursor/rule.mdc` and writes `.cursor/rules/*.mdc`, so it would skip every current skill and rule (Task 12.1). Matching uninstallers (`install/uninstall_*.sh` / `.ps1`) are meant to remove previously installed `sdlc-*` artifacts and, where implemented, the `sdlc-knowledge` MCP entry. Known reverse-path bugs (Cursor still deletes `.cursor/prompts/`; Claude deletes `sdlc-*.json` while install writes `sdlc-*.md`; GHCP does not drop the MCP key) are Epic 12. See the [Installation and Usage Guide](docs/guides/installation-and-usage.md).

## Installation

Clone this repo and run the installer for the harness you use:

```bash
git clone https://github.com/mjbvilhena/ai-sdlc-harness.git
cd ai-sdlc-harness

# Antigravity (global builtin skills)
./install/install_agy.sh

# Claude Code (global commands)
./install/install_claude.sh

# Cursor (workspace slash commands + `.cursor/mcp.json`)
./install/install_cursor.sh --workspace /path/to/your/project

# GitHub Copilot (workspace instructions + `.vscode/mcp.json`)
./install/install_ghcp.sh --workspace /path/to/your/project
```

`--workspace` is **required in practice** for Cursor and GitHub Copilot (they always install into a workspace; omitting the flag uses `$PWD`). For Claude and Antigravity it is optional: omit it for a user-global install, or pass it for a project-local install.

Each installer first removes previously installed `sdlc-*` artifacts in its destination (leaving other user files alone), then expands `CONTENT.md` into skills and rules with `sdlc-` destination names — including YAML frontmatter `name:` where present. `--dry-run` prints the cleanup and copies without changing files.

Bash installers **merge** the `sdlc-knowledge` MCP server into the host config if it already exists (they do not replace the whole file). A live (non-`--dry-run`) install currently invokes host `python3` to write that JSON, then sets MCP `command` to `mcp-server/venv/bin/python` from this clone — create that venv (`python3 -m venv mcp-server/venv && mcp-server/venv/bin/pip install -r mcp-server/requirements.txt`) before the knowledge server can start. `--dry-run` does not call Python. The copy/expand step itself uses only `bash`/`cp`/`mkdir` (or native PowerShell).

To remove a harness install (see the [installation guide](docs/guides/installation-and-usage.md) for current reverse-path gaps):

```bash
./install/uninstall_cursor.sh --workspace /path/to/your/project
./install/uninstall_ghcp.sh --workspace /path/to/your/project
./install/uninstall_claude.sh            # global ~/.claude/commands
./install/uninstall_agy.sh --workspace /path/to/your/project
```

## Repository Structure

```
ai-sdlc-harness/
├── README.md
├── CONTRIBUTING.md
├── run_tests.sh             # Unified local test runner
├── install/                 # Harness installers + uninstallers (Bash + PowerShell)
│   ├── install_agy.sh / uninstall_agy.sh
│   ├── install_claude.sh / uninstall_claude.sh
│   ├── install_cursor.sh / uninstall_cursor.sh
│   └── install_ghcp.sh / uninstall_ghcp.sh
├── skills/                  # Lifecycle Driver skill definitions
│   └── sdlc-example-skill/
│       ├── skill.yaml
│       ├── CONTENT.md           # Canonical body; installers expand into harness files
│       ├── agy/SKILL.md         # Thin shell with {{SKILL_BODY}}
│       ├── claude/command.md
│       ├── cursor/prompt.md
│       └── ghcp/instructions.md
├── rules/                   # Ambient rules (same harness layout)
├── mcp-server/              # Optional Python MCP knowledge server
├── tests/                   # BATS installer tests + E2E suites + docs-browser invariants
└── docs/
    └── browser/             # GitHub Pages shell (live catalog from GitHub, not a frozen HTML tree)
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
   - `skills/sdlc-my-skill/cursor/prompt.md` — Cursor slash-command frontmatter + title
   - `skills/sdlc-my-skill/ghcp/instructions.md` — GitHub Copilot title

   Rules use `{{RULE_BODY}}` the same way. Installers expand the placeholder from `CONTENT.md`; they fail if either the file or the placeholder is missing.

4. Re-run the relevant installer(s).

See [`skills/sdlc-example-skill/`](skills/sdlc-example-skill/) for a complete example.

## Contributing

Pull requests for new skills, improved instructions, or additional harness installers are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md) and `docs/` for specification, architecture, and authoring guides.

## Installation & Usage

To deploy this harness into a real project (including `--workspace` nuances, uninstallers, PowerShell installers, and MCP merge / venv setup), read the [Installation and Usage Guide](docs/guides/installation-and-usage.md).

## Testing

To run the local test suites (metadata validation, docs-browser catalog invariants, MCP unit tests, Bandit, BATS installer tests, and Gitleaks when installed):

```bash
./run_tests.sh
```

For End-to-End LLM evaluations using a Gemini API key, see the Testing section in [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Catalog on GitHub Pages

A static shell in [`docs/browser/`](docs/browser/) is deployed with GitHub Actions (`actions/upload-pages-artifact` + `actions/deploy-pages`). The **inventory is not generated at build time**. The page lists `skills/` and `mcp-server/data/` from the public GitHub tree on `master` when you load it, so a new skill or MCP markdown file appears on refresh without editing the site.

One-time (Pages is not enabled yet): **Settings → Pages → Source = GitHub Actions**. After that, the site is `https://mjbvilhena.github.io/ai-sdlc-harness/`.

```bash
python3 -m http.server 8080 --directory docs/browser
```

See [`docs/guides/github-pages.md`](docs/guides/github-pages.md) for the one-time Pages setting, local preview, and Playwright UI e2e (`e2e-pr` on PRs; `e2e-live` after deploy on `master`).
