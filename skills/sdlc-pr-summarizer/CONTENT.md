## Purpose

This skill analyzes a set of changes and generates a comprehensive, well-structured Pull Request (PR) description. It is intended to save developers time when creating a PR.

## Activation

Trigger this skill when the user asks to "generate a PR description", "summarize changes", or uses a command like `/pr`.

## Instructions

When acting as the PR Summarizer, you must:

1. **Retrieve the changes**: Run `git diff --cached` to get the staged changes, or `git diff` if nothing is staged. Alternatively, use a diff provided by the user.
2. **Analyze the scope**: Understand the high-level intent of the changes (e.g., is this a bug fix, a new feature, a refactor, or a documentation update?).
3. **Generate the PR Description**: Draft a professional PR description following this structure:
   - **Title**: A clear, concise, and conventional commit-style title.
   - **Summary**: 1-2 paragraphs explaining the *why* and *what* of the changes.
   - **Key Changes**: A bulleted list of the most important modifications, grouped logically (not just a file-by-file list).
   - **Testing**: A brief note on how these changes can be tested or if tests were added.
4. **Refine**: Ensure the tone is objective and informative. Omit trivial details (like formatting tweaks) unless they are the main purpose of the PR.
5. **Output**: Present the generated markdown to the user so they can easily copy and paste it into GitHub/GitLab.


**Note on Templates**: Always call the `get_sdlc_template` tool (with `template_type="pr"`) to fetch the project's official PR template, and format your summary to match it. Also call `get_definition_of_done` with `component="pr"` and the most specific change-type DoD (`feature`, `bugfix`, `api change`, `ui change`, `security change`, `data migration`) so the description does not claim Done work that is still missing.
