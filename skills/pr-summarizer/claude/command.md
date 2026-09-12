# PR Summarizer (Claude Code)

## Trigger
`/pr`

## Instructions
Your goal is to generate a professional Pull Request description based on the user's current changes.

1. Check `git diff --cached` for staged changes. If empty, check `git diff` for unstaged changes.
2. Analyze the changes to understand the feature, fix, or refactoring being introduced.
3. Output a markdown PR description with the following structure:
   - **Title**: A conventional commit-style title.
   - **Summary**: High-level explanation of the intent.
   - **Key Changes**: Bulleted list of significant changes, grouped logically (e.g., Frontend, Backend, Database).
   - **Testing Notes**: (If applicable) How to verify the changes.
4. Keep the output clean and ready to be copy-pasted directly into a PR creation form. Do not include excessive conversational text before or after the markdown.
