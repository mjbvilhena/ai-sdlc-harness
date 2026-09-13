# Authoring for GitHub Copilot

GitHub Copilot supports workspace-level custom instructions via files placed in the `.github/instructions/` directory.

## File Convention
In this repository, GitHub Copilot instructions are stored in the `ghcp/` subdirectory and must be named `instructions.md`.

## Structure of an `instructions.md`
GHCP instructions are simple Markdown files.
- Use headers to define the scope.
- Use numbered lists for execution steps.

## Tips
- GHCP instructions are great for defining chat personas and coding standards.
- Instruct GHCP on what to do when specific keywords are used in the chat (e.g., "When I say /review...").
