# Repository Directory Structure

```
ai-sdlc-harness/
├── README.md                    # Project overview and quick-start guide
├── CONTRIBUTING.md              # How to author and contribute new skills
├── install_agy.sh               # Installer: Antigravity (agy)
├── install_claude.sh            # Installer: Claude Code
├── install_ghcp.sh              # Installer: GitHub Copilot (ghcp)
│
├── skills/                      # All skill definitions
│   └── <skill-name>/
│       ├── skill.yaml           # Metadata only (not parsed by scripts)
│       ├── agy/                 # Antigravity-specific files
│       │   └── SKILL.md         # Native AGY SKILL.md format
│       ├── claude/              # Claude Code-specific files
│       │   └── command.md       # Native Claude slash command format
│       └── ghcp/                # GitHub Copilot-specific files
│           └── instructions.md  # Native GHCP instructions format
│
├── agents/                      # All agent definitions (same layout as skills/)
│   └── <agent-name>/
│       ├── agent.yaml           # Metadata only
│       ├── agy/
│       │   └── SKILL.md
│       ├── claude/
│       │   └── command.md
│       └── ghcp/
│           └── instructions.md
│
├── rules/                       # Passive contextual prompts and instructions
│   └── <rule-name>/
│       ├── rule.yaml            # Metadata only
│       ├── claude/              # e.g., custom instructions
│       │   └── command.md
│       └── ghcp/                # e.g., ambient instructions
│           └── instructions.md
│
└── docs/                        # Project documentation
    ├── product/
    │   ├── vision.md
    │   ├── specification.md
    │   └── backlog.md
    ├── technical_design/
    │   ├── architecture.md
    │   ├── directory_structure.md   ← this file
    │   └── schemas.md
    └── guides/                  # Per-harness authoring guides (planned)
        ├── authoring-for-agy.md
        ├── authoring-for-claude.md
        └── authoring-for-ghcp.md
```

## Notes

- The `skills/`, `agents/`, and `rules/` directories are the only runtime source of truth. The installer scripts read from these directories and nothing else.
- `skill.yaml` / `agent.yaml` / `rule.yaml` are for human readers, documentation generators, and CI validators. Installer shell scripts do not parse them.
- Target-specific subdirectories (`agy/`, `claude/`, `ghcp/`) are optional per skill/rule/agent. A skill that only targets AGY only needs an `agy/` subdirectory.
- There is no `build/` directory. Files are copied directly from source to destination — no intermediate build step.
