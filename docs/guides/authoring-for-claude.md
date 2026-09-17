# Authoring for Claude Code

Claude Code supports custom slash commands by placing Markdown files in `~/.claude/commands/` (global default) or `<ws>/.claude/commands/` when the installer is run with `--workspace`.

## File Convention
In this repository, Claude Code files are stored in the `claude/` subdirectory of a skill or agent and must be named `command.md`. Keep the Claude-specific Trigger block in this file and put the shared body in sibling `CONTENT.md`. The shell must contain `{{SKILL_BODY}}` (skills) or `{{RULE_BODY}}` (rules) on its own line.

## Structure of a `command.md`
A good Claude Code command should include:
1. **Trigger**: Specify what slash command activates it (e.g., `/review`).
2. **Instructions**: Clear, numbered steps for Claude to follow.
3. **Context**: What tools Claude should use (e.g., `git diff`).

## Tips
- Claude Code excels at using tools. Tell it explicitly to check `git diff` or `cat` a file if needed.
- Keep instructions direct and imperative.
