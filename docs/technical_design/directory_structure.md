# Repository Directory Structure

```
ai-sdlc-harness/
├── README.md
├── CONTRIBUTING.md
├── run_tests.sh                 # Unified runner: metadata, MCP pytest, BATS, optional E2E
├── .markdownlint.json
├── .gitignore
│
├── install/                     # Harness installers (not at repo root)
│   ├── install_agy.sh
│   ├── install_agy.ps1
│   ├── install_claude.sh
│   ├── install_claude.ps1
│   ├── install_cursor.sh
│   ├── install_cursor.ps1
│   ├── install_ghcp.sh
│   ├── install_ghcp.ps1
│   └── lib/
│       ├── expand_content.sh    # Bash: expand CONTENT.md into harness shells
│       └── Expand-Content.ps1   # PowerShell twin
│
├── skills/                      # Lifecycle Driver skill definitions
│   └── <skill-name>/            # e.g. sdlc-code-reviewer, sdlc-example-skill
│       ├── skill.yaml           # Metadata only (not parsed by installers)
│       ├── CONTENT.md           # Canonical body ({{SKILL_BODY}})
│       ├── agy/
│       │   └── SKILL.md         # Thin shell
│       ├── claude/
│       │   └── command.md
│       ├── cursor/
│       │   └── rule.mdc
│       └── ghcp/
│           └── instructions.md
│
├── rules/                       # Ambient / passive prompts
│   └── <rule-name>/
│       ├── rule.yaml
│       ├── CONTENT.md           # Canonical body ({{RULE_BODY}})
│       ├── agy/RULE.md
│       ├── claude/command.md
│       ├── cursor/rule.mdc
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
│   └── e2e/
│
├── .github/
│   ├── workflows/               # metadata, lint, BATS, security
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
    │   └── schemas.md
    └── guides/
        ├── authoring-for-agy.md
        ├── authoring-for-claude.md
        ├── authoring-for-cursor.md
        ├── authoring-for-ghcp.md
        ├── installation-and-usage.md
        └── testing.md
```

## Notes

- **Installers live under `install/`**. Invoke them as `./install/install_<harness>.sh` (or the `.ps1` twin).
- **`skills/` and `rules/` are the runtime source of truth today.** They are the Lifecycle Drivers and ambient rules the installers copy. A top-level `agents/` tree is **deferred**; installers already tolerate a missing `agents/` directory (they print a skip message and continue).
- `skill.yaml` / `rule.yaml` / `agent.yaml` (when present) are for humans, docs, and CI. Installer scripts do not parse them.
- Target-specific subdirectories (`agy/`, `claude/`, `cursor/`, `ghcp/`) are optional per item. An item that only targets AGY only needs `agy/`.
- There is no `build/` directory. Files are copied directly from source to destination.
- `mcp-server/` is optional at install time. Running it requires Python; skill *installation* does not.
