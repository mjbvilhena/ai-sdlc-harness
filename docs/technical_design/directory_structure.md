# Repository Directory Structure

```
ai-sdlc-harness/
├── README.md
├── CONTRIBUTING.md
├── run_tests.sh                 # Unified runner: metadata, MCP pytest, Bandit, optional E2E, BATS, Gitleaks
├── .markdownlint.json
├── .gitignore
│
├── install/                     # Harness installers + uninstallers (not at repo root)
│   ├── install_agy.sh / uninstall_agy.sh
│   ├── install_agy.ps1 / uninstall_agy.ps1
│   ├── install_claude.sh / uninstall_claude.sh
│   ├── install_claude.ps1 / uninstall_claude.ps1
│   ├── install_cursor.sh / uninstall_cursor.sh
│   ├── install_cursor.ps1 / uninstall_cursor.ps1
│   ├── install_ghcp.sh / uninstall_ghcp.sh
│   ├── install_ghcp.ps1 / uninstall_ghcp.ps1
│   └── lib/
│       ├── expand_content.sh    # Bash: expand CONTENT.md into harness shells
│       ├── Expand-Content.ps1   # PowerShell twin
│       ├── sdlc_names.sh        # Bash: sdlc- dest names + cleanup
│       └── Sdlc-Names.ps1       # PowerShell twin
│
├── skills/                      # Lifecycle Driver skill definitions
│   └── <skill-name>/            # e.g. sdlc-conductor, sdlc-ux-designer, sdlc-example-skill
│       ├── skill.yaml           # Metadata only (not parsed by installers)
│       ├── CONTENT.md           # Canonical body ({{SKILL_BODY}})
│       ├── agy/
│       │   └── SKILL.md         # Thin shell
│       ├── claude/
│       │   └── command.md
│       ├── cursor/
│       │   └── prompt.md     # Slash-command shell
│       └── ghcp/
│           └── instructions.md
│
├── rules/                       # Ambient / passive prompts
│   └── <rule-name>/
│       ├── rule.yaml
│       ├── CONTENT.md           # Canonical body ({{RULE_BODY}})
│       ├── agy/RULE.md
│       ├── claude/command.md
│       ├── cursor/prompt.md
│       └── ghcp/instructions.md
│
├── mcp-server/                  # Optional Python MCP knowledge server
│   ├── src/server.py
│   ├── data/templates/
│   ├── data/dod/
│   ├── tests/
│   └── requirements.txt
│
├── tests/
│   ├── bats/installers.bats
│   ├── docs_browser/            # Pages shell invariants + Playwright UI e2e
│   └── e2e/
│
├── .github/
│   ├── workflows/               # metadata, lint, BATS, security, Pages
│   ├── scripts/validate_metadata.py
│   └── CODEOWNERS
│
└── docs/
    ├── product/
    │   ├── vision.md
    │   ├── specification.md
    │   └── backlog.md
    ├── technical_design/
    │   ├── architecture.md
    │   ├── directory_structure.md   ← this file
    │   ├── schemas.md
    │   └── sdlc-conductor.md        # Design note: default front-door driver (skill: skills/sdlc-conductor/)
    ├── guides/
    │   ├── authoring-for-agy.md
    │   ├── authoring-for-claude.md
    │   ├── authoring-for-cursor.md
    │   ├── authoring-for-ghcp.md
    │   ├── installation-and-usage.md
    │   ├── testing.md
    │   └── github-pages.md      # Pages shell, live catalog from GitHub, one-time setting
    └── browser/                 # Static Pages shell (HTML/CSS/JS); inventory is fetched at runtime
```

## Notes

- **Installers live under `install/`**. Invoke them as `./install/install_<harness>.sh` (or the `.ps1` twin). Uninstallers are `./install/uninstall_<harness>.sh` / `.ps1`.
- **Cursor destinations are slash commands**: source `cursor/prompt.md` → `<ws>/.cursor/commands/sdlc-<name>.md`. Not `.cursor/prompts/` or `.cursor/rules/*.mdc`.
- **GitHub Copilot destinations** are `<ws>/.github/instructions/sdlc-<name>.instructions.md` (source `ghcp/instructions.md`).
- **`skills/` and `rules/` are the runtime source of truth today.** They are the Lifecycle Drivers and ambient rules the installers expand into each harness dest. A top-level `agents/` tree is **deferred**; installers already tolerate a missing `agents/` directory (they print a skip message and continue).
- `skill.yaml` / `rule.yaml` / `agent.yaml` (when present) are for humans, docs, and CI. Installer scripts do not parse them.
- Target-specific subdirectories (`agy/`, `claude/`, `cursor/`, `ghcp/`) are optional per item. An item that only targets AGY only needs `agy/`.
- There is no generated per-skill HTML tree. `docs/browser/` is a committed static shell; GitHub Pages deploys it as-is. The browser lists skills and MCP data from the live GitHub tree on `master`.
- There is no `build/` directory. Installers expand `CONTENT.md` into each harness shell and write the resolved file to the destination.
- `mcp-server/` is optional at *runtime*. A live installer currently needs host `python3` to merge MCP JSON; running the server also needs the repo venv. `--dry-run` does not call Python. Skill/rule copy/expand does not parse YAML.
