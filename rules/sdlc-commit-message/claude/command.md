# Conventional Commits Rule (Claude Code)

## Trigger
(Passive / Ambient) - Apply when generating commit messages.

## Guidelines
When writing or proposing a git commit message, always adhere to the Conventional Commits specification:

`<type>[optional scope]: <description>`

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting, missing semi colons, etc.
- `refactor`: Refactoring code
- `perf`: Performance improvements
- `test`: Adding tests
- `chore`: Maintenance

**Rules**:
- Use imperative tense: "add" not "added" or "adds".
- No capitalization at the start of the description.
- No period at the end of the description.
