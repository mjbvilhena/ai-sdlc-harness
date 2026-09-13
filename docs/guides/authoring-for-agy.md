# Authoring for Antigravity (AGY)

Antigravity uses a robust skill architecture where skills can define their own rules, tools, and prompts.

## File Convention
In this repository, Antigravity skills are stored in the `agy/` subdirectory. The primary file must be named `SKILL.md`. It is a **thin shell**: YAML frontmatter, a title, and `{{SKILL_BODY}}` on its own line. Shared instructions live in the sibling `CONTENT.md` (or `{{RULE_BODY}}` + `CONTENT.md` for rules). The installer expands the placeholder at install time.

## Structure of a `SKILL.md`
`SKILL.md` files in Antigravity can include YAML frontmatter followed by Markdown content:

```markdown
---
name: my-skill
description: Does something cool.
---

# My Skill

{{SKILL_BODY}}
```

Put Purpose, Instructions, Safety, and MCP tool steps in `CONTENT.md`, not in every harness file.

## Tips
- AGY parses `SKILL.md` files thoroughly. Use clear sections like `## Purpose`, `## Instructions`, and `## Examples`.
- Be specific about what tools the agent should use (e.g., `grep_search`, `write_to_file`).
- You can place companion scripts inside the `agy/` folder (e.g., in a `scripts/` subdirectory) and AGY can execute them.
