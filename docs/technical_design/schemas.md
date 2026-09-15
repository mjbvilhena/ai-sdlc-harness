# Metadata Schemas

`skill.yaml`, `agent.yaml`, and `rule.yaml` are **metadata-only** files. They are not parsed or executed by the installer scripts. Their purpose is:

- Human documentation (what does this capability do, who wrote it, what version is it)
- CI validation (check that required fields are present on every PR)
- Future tooling (e.g. a registry, a README generator)

The installers select files based purely on directory conventions (the presence of `agy/`, `claude/`, `cursor/`, `ghcp/` subdirectories). `skill.yaml` (and others) are never read at install time.

Each skill or rule directory also has a canonical `CONTENT.md`. Harness files are thin shells that contain `{{SKILL_BODY}}` (skills/agents) or `{{RULE_BODY}}` (rules) on its own line. At install time the installer substitutes `CONTENT.md` into that placeholder and writes the expanded file. Missing `CONTENT.md`, a missing placeholder, or an unresolved placeholder after expansion is a hard error. CI (`validate_metadata.py`) checks that `CONTENT.md` exists and that each harness primary file contains the correct placeholder. Cursor's primary file is `cursor/prompt.md` (installed as slash commands under `.cursor/commands/`).

---

## `skill.yaml` Schema

```yaml
# Required fields
name: string           # Unique identifier for the skill (kebab-case, matches directory name)
description: string    # One-sentence description of what the skill does
version: string        # Semantic version (e.g. "1.0.0")
author: string         # Author name or GitHub handle

# Optional fields
targets:               # List of harnesses this skill has been authored for
  - agy
  - claude
  - cursor
  - ghcp

triggers:              # Natural-language or slash-command names that activate the skill
  - /review
  - "code review"
```

### Example

```yaml
name: sdlc-code-reviewer
description: Reviews a PR diff and suggests improvements focused on correctness, performance, and security.
version: 1.0.0
author: mjbvilhena
targets:
  - agy
  - claude
  - cursor
  - ghcp
triggers:
  - /review
  - /cr
```

---

## `agent.yaml` Schema

Agents follow the same metadata schema as skills, using `agent.yaml` instead. The `agents/` directory is **not populated** today (Lifecycle Drivers live under `skills/`); this schema applies if agent packages are added later.

```yaml
# Required fields
name: string           # Unique identifier (kebab-case, matches directory name)
description: string    # One-sentence description of what the agent does
version: string        # Semantic version
author: string         # Author name or GitHub handle

# Optional fields
targets:
  - agy
  - claude
  - cursor
  - ghcp

triggers:
  - /run-agent
```

---

## `rule.yaml` Schema

Rules are for passive, ambient context (e.g., guidelines, styles, templates) rather than active workflows. They follow the same structure but typically don't have triggers:

```yaml
# Required fields
name: string           # Unique identifier (kebab-case, matches directory name)
description: string    # One-sentence description of the rule or context
version: string        # Semantic version
author: string         # Author name or GitHub handle

# Optional fields
targets:
  - agy
  - claude
  - cursor
  - ghcp
```

---

## Valid Target Values

| Value | Harness |
|-------|---------|
| `agy` | Antigravity (AGY) |
| `claude` | Claude Code |
| `cursor` | Cursor |
| `ghcp` | GitHub Copilot |

---

## CI Validation

A GitHub Actions workflow (`.github/workflows/validate-metadata.yaml`, script `.github/scripts/validate_metadata.py`) validates that every `skill.yaml`, `agent.yaml`, and `rule.yaml` in a PR contains all required fields and that the `targets` list matches the harness subdirectories present in the directory.
