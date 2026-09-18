# Authoring for Cursor

Cursor supports workspace-level **slash commands** via `.md` files placed in the `.cursor/commands/` directory.

## File Convention
In this repository, Cursor files are stored in the `cursor/` subdirectory and must be named `prompt.md`. Keep YAML frontmatter here (`description` is the field Cursor slash commands use). Put the shared body in sibling `CONTENT.md` and leave `{{SKILL_BODY}}` or `{{RULE_BODY}}` on its own line. The installer expands it when writing `<ws>/.cursor/commands/sdlc-<name>.md`.

Do not author `rule.mdc` or target `.cursor/rules/` or `.cursor/prompts/` — those older layouts are no longer what the Bash installer deploys.

## Structure of a `prompt.md`
Cursor slash-command files are Markdown with optional YAML frontmatter:

```md
---
description: A short description of the prompt.
---
# Prompt Name

{{SKILL_BODY}}
```

Current library shells still include a leftover `globs: *` key from the rules-era layout; Cursor slash commands are not file-scoped the way `.cursor/rules/*.mdc` are. Do not add new `globs` to command shells until Task 12.7 confirms or drops that field.

## Tips
- Slash commands are workspace-scoped. After install, commit `.cursor/commands/` in the **target** project so teammates get the same files.
- Ambient library rules (`rules/sdlc-*`) use the same `prompt.md` + `{{RULE_BODY}}` convention; they still land in `.cursor/commands/`, not `.cursor/rules/`.
