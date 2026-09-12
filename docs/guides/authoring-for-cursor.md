# Authoring for Cursor

Cursor supports workspace-level rules via `.mdc` files placed in the `.cursor/rules/` directory.

## File Convention
In this repository, Cursor rules are stored in the `cursor/` subdirectory and must be named `rule.mdc`.

## Structure of a `rule.mdc`
Cursor rules require YAML frontmatter followed by Markdown content:

```mdc
---
description: A short description of the rule.
globs: *
---
# Rule Name

1. Step one.
2. Step two.
```

## Tips
- Use the `globs` field to restrict rules to specific file types (e.g., `*.ts` or `src/**/*.py`) if the rule only applies to certain languages.
- Cursor rules act as ambient context. They are injected into the context window when relevant files are open or when the user asks a related question.
