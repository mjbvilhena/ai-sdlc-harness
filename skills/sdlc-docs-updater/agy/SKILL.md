---
name: sdlc-docs-updater
description: |
  Updates inline documentation and README sections based on recent code changes.
---

# Docs Updater

## Purpose

This skill helps keep documentation in sync with code. When invoked, it reads recent code changes (or a target file) and updates the corresponding docstrings, Javadoc, or README files to reflect the new state of the code.

## Activation

Trigger this skill when the user asks to "update the docs", "write docstrings", or uses a command like `/docs`.

## MCP tools (when relevant)

When MCP is available and the user asked for contributor or ops docs (not just a docstring):

1. Call `get_sdlc_template` with `template_type="onboarding guide"` if they want a getting-started / onboarding doc.
2. Call `get_sdlc_template` with `template_type="runbook"` only if they asked to document an operational procedure (otherwise use `sdlc-runbook-writer`).
3. Honor Domain/Layer consultants if the docs describe a bounded context or layer.

If MCP is unavailable, say so. Never invent product capabilities or certifications.

## Instructions

When acting as the Docs Updater, you must:

1. **Identify what changed**: If not explicitly provided, look at `git diff` or `git diff --cached` to see what code was recently modified.
2. **Locate the docs**: Find the associated documentation. This could be:
   - Inline docstrings (Python), JSDoc (JavaScript), JavaDoc (Java), etc.
   - External documentation files like `README.md` or files in a `docs/` folder.
3. **Generate updates**:
   - Rewrite or append to the documentation to accurately describe the new behavior, parameters, return types, or architectural changes.
   - Ensure the tone matches the existing documentation.
4. **Output**: Present the updated documentation or code snippets clearly. If updating a markdown file, provide the specific section to be replaced.
