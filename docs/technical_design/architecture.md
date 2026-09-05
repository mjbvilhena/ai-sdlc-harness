# Architecture Overview

The AI SDLC Harness has a deliberately minimal architecture. There is no compiler engine, no schema parser, and no runtime. The system consists entirely of:

1. **A skill/agent library** — directories of pre-authored, target-specific files.
2. **Installer shell scripts** — scripts that copy those files to the correct locations on the user's machine.

## High-Level Flow

```
User runs: ./install_agy.sh
    │
    ▼
install_agy.sh
    │
    ├─→ Iterates over skills/*/agy/
    │       │
    │       └─→ For each skill with an agy/ subdirectory:
    │               Copy contents → ~/.gemini/antigravity-cli/builtin/skills/<name>/
    │
    └─→ Iterates over agents/*/agy/
            │
            └─→ For each agent with an agy/ subdirectory:
                    Copy contents → ~/.gemini/antigravity-cli/builtin/skills/<name>/
```

The same pattern applies for `install_claude.sh` and `install_ghcp.sh`, with different source subdirectories and destination paths.

## Skill Library Layout

```
skills/
└─ <skill-name>/
       ├─ skill.yaml          ← Metadata only. Not parsed by scripts.
       ├─ agy/
       │     └─ SKILL.md      ← Copied verbatim to AGY config dir
       ├─ claude/
       │     └─ command.md    ← Copied verbatim to Claude commands dir
       └─ ghcp/
             └─ instructions.md  ← Copied verbatim to workspace instructions dir
```

Each target-specific file is authored natively — it contains exactly what the target harness expects to read. The installer scripts do not transform, template, or parse these files. They are copied as-is.

## Installer Script Structure

Each installer script follows the same internal structure:

```
install_<harness>.sh
    │
    ├─ 1. Resolve DEST (destination directory, absolute path)
    │       e.g. AGY_SKILLS_DIR="${HOME}/.gemini/antigravity-cli/builtin/skills"
    │
    ├─ 2. Resolve SCRIPT_DIR (absolute path to this repo root)
    │
    ├─ 3. For each skill in skills/*/:
    │       a. Check if skills/<name>/<harness>/ exists → skip if not
    │       b. mkdir -p "${DEST}/<name>"
    │       c. cp -r "skills/<name>/<harness>/." "${DEST}/<name>/"
    │       d. Print: "Installed <name> → ${DEST}/<name>/"
    │
    └─ 4. Print summary: N skills installed.
```

## Design Principles

- **No runtime dependencies**: Scripts use only POSIX utilities (`bash`, `cp`, `mkdir`, `ln`, `find`).
- **No parsing**: `skill.yaml` is read by humans and CI validators only; installer scripts do not parse it.
- **Idempotency**: Copying files with `cp -r` is naturally idempotent. Running installers multiple times is safe.
- **Isolation**: Each harness installer is independent. Running `install_agy.sh` does not affect Claude Code configuration and vice versa.
