# Authoring for Cursor

Cursor supports workspace-level **slash commands** via `.md` files placed in the `.cursor/commands/` directory.

## File Convention
In this repository, Cursor files are stored in the `cursor/` subdirectory and must be named `prompt.md`. Keep YAML frontmatter (`description`, and `globs` when the prompt should stay file-scoped) here. Put the shared body in sibling `CONTENT.md` and leave `{{SKILL_BODY}}` or `{{RULE_BODY}}` on its own line. The installer expands it when writing `<ws>/.cursor/commands/sdlc-<name>.md`.

Do not author `rule.mdc` or target `.cursor/rules/` or `.cursor/prompts/` — those older layouts are no longer what the Bash installer deploys.

## Structure of a `prompt.md`
Cursor slash-command files are Markdown with optional YAML frontmatter:

```md
---
description: A short description of the prompt.
globs: *
---
# Prompt Name

{{SKILL_BODY}}
```

## Tips
- Use the `globs` field to restrict a prompt to specific file types (e.g., `*.ts` or `src/**/*.py`) when it should only apply to certain languages.
- Slash commands are workspace-scoped. After install, commit `.cursor/commands/` in the **target** project so teammates get the same files.
- Ambient library rules (`rules/sdlc-*`) use the same `prompt.md` + `{{RULE_BODY}}` convention; they still land in `.cursor/commands/`, not `.cursor/rules/`.
