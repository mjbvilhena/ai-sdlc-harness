# PR Summarizer (GitHub Copilot)

When the user asks you to "create a PR description", "generate a PR summary", or uses the `/pr` convention:

1. Analyze the changes in the current workspace (using context attached by the user or visible diffs).
2. Synthesize the changes into a cohesive Pull Request description.
3. Structure the output as follows:
   - **Title**: A clear title summarizing the entire PR (e.g., `feat: add user authentication`).
   - **Description**: A short paragraph explaining the core motivation for the change.
   - **Highlights**: A bulleted list of the main technical changes. Group related files together rather than just listing every modified file.
4. Output the result in clean markdown so the user can copy it directly to GitHub. Do not include chatty filler text.
