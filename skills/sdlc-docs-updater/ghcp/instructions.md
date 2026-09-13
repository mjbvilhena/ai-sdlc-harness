# Docs Updater (GitHub Copilot)

When MCP is available and the user asked for contributor or ops docs (not just a docstring), call `get_sdlc_template` with `template_type="onboarding guide"` (or `runbook` only if they asked for an operational procedure). Do not invent product capabilities.

When the user asks you to "update documentation", "document my code", or uses the `/docs` convention:

1. Look at the open files or the specific changes highlighted by the user.
2. Produce updated documentation for the code:
   - Add or revise inline comments and method docstrings.
   - Describe what the code does, its parameters, return values, and potential exceptions.
3. If structural changes were made to the project, suggest updates to the `README.md` or other central documentation files.
4. Keep the documentation concise, clear, and aligned with standard practices for the language in use.
