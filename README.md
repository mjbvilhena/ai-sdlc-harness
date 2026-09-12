# AI SDLC Harness

A shell-script-based installer that deploys a curated library of AI skills and agents into your local AI tooling environments.

No Python. No compilation step. Just shell scripts and file copies.

## How It Works

Skills and agents in this repo are **authored once per target harness** — meaning each skill has a dedicated file written in the exact format that a given AI tool expects (e.g. a `SKILL.md` for Antigravity, a `command.md` for Claude Code). A top-level installer script for each harness discovers all skills in the `skills/` directory and copies (or symlinks) the correct files into the right place on your machine.

## Supported Harnesses (v1)

| Harness | Installer | Install Location |
|---|---|---|
| **Antigravity (agy)** | `install_agy.sh` | `~/.gemini/antigravity-cli/builtin/skills/<skill-name>/` |
| **Claude Code** | `install_claude.sh` | `~/.claude/commands/` |
| **GitHub Copilot (ghcp)** | `install_ghcp.sh` | `.github/instructions/` in your workspace |

## Installation

Clone this repo and run the installer for the harness you use:

```bash
git clone https://github.com/your-org/ai-sdlc-harness.git
cd ai-sdlc-harness

# Install into Antigravity
./install_agy.sh

# Install into Claude Code
./install_claude.sh

# Install into GitHub Copilot (installs into the current working directory workspace)
./install_ghcp.sh --workspace /path/to/your/project
```

That's it. The scripts require no dependencies beyond standard Unix shell utilities (`bash`, `cp`, `mkdir`, `ln`).

## Repository Structure

```
ai-sdlc-harness/
├── README.md
├── install_agy.sh           # Installer for Antigravity
├── install_claude.sh        # Installer for Claude Code
├── install_ghcp.sh          # Installer for GitHub Copilot
├── skills/                  # All skill definitions
│   └── <skill-name>/
│       ├── skill.yaml       # Metadata (name, description, version, triggers)
│       ├── agy/             # Antigravity-specific files
│       │   └── SKILL.md
│       ├── claude/          # Claude Code-specific files
│       │   └── command.md
│       └── ghcp/            # GitHub Copilot-specific files
│           └── instructions.md
└── agents/                  # All agent definitions (same layout as skills/)
    └── <agent-name>/
        ├── agent.yaml
        ├── agy/
        ├── claude/
        └── ghcp/
```

## Adding a New Skill

1. Create a directory under `skills/` with your skill's name (use kebab-case):
   ```bash
   mkdir -p skills/my-skill/{agy,claude,ghcp}
   ```

2. Create `skills/my-skill/skill.yaml` with metadata:
   ```yaml
   name: my-skill
   description: What this skill does.
   version: 0.1.0
   author: Your Name
   targets:
     - agy
     - claude
     - ghcp
   triggers:
     - /my-skill
   ```

3. Author the target-specific files:
   - `skills/my-skill/agy/SKILL.md` — written as an Antigravity skill
   - `skills/my-skill/claude/command.md` — written as a Claude Code slash command
   - `skills/my-skill/ghcp/instructions.md` — written as GitHub Copilot instructions

4. Re-run the relevant installer(s).

See `skills/example-skill/` for a complete example.

## Contributing

Pull requests for new skills, improved instructions, or additional harness installers are welcome. See `docs/` for detailed specification, architecture, and contribution guidelines.

## Testing

To run the local test suites (Metadata validation, MCP unit tests, and BATS shell tests), run the unified helper script:

```bash
./run_tests.sh
```

For instructions on running the End-to-End LLM evaluations using a Gemini API key, please see the Testing section in [`CONTRIBUTING.md`](CONTRIBUTING.md).
