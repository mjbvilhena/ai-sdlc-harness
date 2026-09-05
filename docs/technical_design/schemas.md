# Metadata Schemas

`skill.yaml` and `agent.yaml` are **metadata-only** files. They are not parsed or executed by the installer scripts. Their purpose is:

- Human documentation (what does this skill do, who wrote it, what version is it)
- CI validation (check that required fields are present on every PR)
- Future tooling (e.g. a skill registry, a README generator)

The installers copy files based purely on directory conventions (the presence of `agy/`, `claude/`, `ghcp/` subdirectories). `skill.yaml` is never read at install time.

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
  - ghcp

triggers:              # Natural-language or slash-command names that activate the skill
  - /review
  - "code review"
```

### Example

```yaml
name: code-reviewer
description: Reviews a PR diff and suggests improvements focused on correctness, performance, and security.
version: 1.0.0
author: mjbvilhena
targets:
  - agy
  - claude
  - ghcp
triggers:
  - /review
  - /cr
```

---

## `agent.yaml` Schema

Agents follow the same metadata schema as skills, using `agent.yaml` instead:

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
  - ghcp

triggers:
  - /run-agent
```

---

## Valid Target Values

| Value | Harness |
|-------|---------|
| `agy` | Antigravity (AGY) |
| `claude` | Claude Code |
| `ghcp` | GitHub Copilot |

---

## CI Validation

A GitHub Actions workflow (planned, see backlog) will validate that every `skill.yaml` and `agent.yaml` in a PR contains all required fields and that the `targets` list matches the subdirectories present in the skill directory.
