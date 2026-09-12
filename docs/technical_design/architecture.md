# Architecture Overview

The AI SDLC Harness has a deliberately minimal architecture. There is no compiler engine, no schema parser, and no runtime. The system consists entirely of:

1. **A skill/agent/rule library** — directories of pre-authored, target-specific files.
2. **Installer shell scripts** — scripts that copy those files to the correct locations on the user's machine.

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

The same pattern applies for `install_cursor.sh`, `install_ghcp.sh`, and `install_agy.sh`, with different source subdirectories and destination paths.

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
install_<harness>.sh
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
    └─ 4. Print summary: N items installed.
```

## Design Principles

- **No runtime dependencies**: Scripts use only POSIX utilities (`bash`, `cp`, `mkdir`, `ln`, `find`).
- **No parsing**: Metadata files (`skill.yaml`, `rule.yaml`, etc.) are read by humans and CI validators only; installer scripts do not parse them.
- **Idempotency**: Copying files with `cp -r` is naturally idempotent. Running installers multiple times is safe.
- **Isolation**: Each harness installer is independent. Running `install_claude.sh` does not affect Cursor or Antigravity configuration, and vice versa.
