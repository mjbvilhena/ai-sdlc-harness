# Contributing to AI SDLC Harness

Thank you for contributing! This guide will help you understand how to author and publish skills, rules, and agents for this repository.

## Directory Layout

The repository is organized by category, then by item name, and finally by harness target:

```text
skills/
  code-reviewer/            # The name of the skill (kebab-case)
    skill.yaml              # Metadata file (required)
    agy/                    # Antigravity implementation
      SKILL.md
    claude/                 # Claude Code implementation
      command.md
    cursor/                 # Cursor implementation
      rule.mdc
    ghcp/                   # GitHub Copilot implementation
      instructions.md
```

## Metadata Schemas

Every skill must have a `skill.yaml`, every rule a `rule.yaml`, and every agent an `agent.yaml`. These files are used for validation and documentation.

Example `skill.yaml`:
```yaml
name: code-reviewer
description: Reviews a PR diff.
version: 1.0.0
author: your-github-handle
targets:
  - agy
  - claude
  - cursor
  - ghcp
triggers:
  - /review
```

For full schema details, see [schemas.md](docs/technical_design/schemas.md).

## Authoring for Each Harness

We support four harnesses. For detailed guides on how to write prompts for each, see the documentation in `docs/guides/`:

- [Authoring for Claude Code](docs/guides/authoring-for-claude.md)
- [Authoring for Cursor](docs/guides/authoring-for-cursor.md)
- [Authoring for GitHub Copilot](docs/guides/authoring-for-ghcp.md)
- [Authoring for Antigravity (AGY)](docs/guides/authoring-for-agy.md)

## PR Checklist

Before submitting a Pull Request, please ensure:

1. [ ] Your item is located in the correct top-level directory (`skills/`, `rules/`, or `agents/`).
2. [ ] The directory name is `kebab-case`.
3. [ ] A valid `*.yaml` metadata file is present and accurately reflects the supported targets.
4. [ ] You have implemented the skill/rule/agent for at least one harness (preferably all four).
5. [ ] The tone of the prompts is professional, objective, and clear.
