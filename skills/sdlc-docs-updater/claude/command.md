# Docs Updater (Claude Code)

## Trigger
`/docs`

## MCP tools (when relevant)

When MCP is available and the user asked for contributor or ops docs (not just a docstring), call `get_sdlc_template` with `template_type="onboarding guide"` (or `runbook` only if they asked for an operational procedure). Do not invent product capabilities.

## Instructions
Your task is to update the documentation to match the current state of the codebase.

1. **Analyze changes**: Review the user's staged or unstaged changes.
2. **Update Inline Docs**: For any modified functions, classes, or modules, generate updated docstrings or inline comments. Ensure you follow the project's documentation standard (e.g., Google Python style, JSDoc).
3. **Update Markdown Docs**: Check if these changes warrant an update to `README.md` or other markdown documentation files. If so, provide the updated text.
4. **Format Output**: Provide the suggested documentation changes clearly. Use diff blocks or standard code blocks showing the new documentation in context.
