# Product Backlog

## Epic 1: Shell Installer Scripts

> Goal: Deliver working installer scripts for each supported harness.

- **Task 1.1**: Implement `install_agy.sh` — discovers `skills/*/agy/` and copies contents to `~/.gemini/antigravity-cli/builtin/skills/<name>/`.
- **Task 1.2**: Implement `install_claude.sh` — discovers `skills/*/claude/` and copies `.md` files to `~/.claude/commands/`.
- **Task 1.3**: Implement `install_ghcp.sh` — discovers `skills/*/ghcp/` and copies instruction files to the target workspace. Support `--workspace <path>` flag.
- **Task 1.4**: Add agent support to all three installers (i.e. also iterate over `agents/*/`).
- **Task 1.5**: Write installer test stubs (dry-run mode or `--dry-run` flag) that print what would be copied without performing any file operations.

## Epic 2: Bundled Skill Library

> Goal: Ship a useful, high-quality set of skills ready to install.

- **Task 2.1**: Author `code-reviewer` skill — reviews PR diffs, highlights issues. Author for `agy`, `claude`, `ghcp`.
- **Task 2.2**: Author `pr-summarizer` skill — generates a PR description from staged changes. Author for `agy`, `claude`, `ghcp`.
- **Task 2.3**: Author `commit-message` skill — drafts a conventional commit message from diff context. Author for `agy`, `claude`, `ghcp`.
- **Task 2.4**: Author `test-writer` skill — generates test stubs for a given function or module. Author for `agy`, `claude`.
- **Task 2.5**: Author `docs-updater` skill — updates inline documentation and README sections. Author for `agy`, `claude`.
- **Task 2.6**: Review and quality-gate all bundled skills for accuracy and safety before first public release.

## Epic 3: Contributor Experience

> Goal: Make it easy for the community to author and contribute new skills.

- **Task 3.1**: Create `skills/example-skill/` with complete stubs for all three harness targets and a fully-annotated `skill.yaml`.
- **Task 3.2**: Write `CONTRIBUTING.md` — explains the skill directory layout, `skill.yaml` schema, how to author for each harness, and the PR checklist.
- **Task 3.3**: Write per-harness authoring guides under `docs/guides/` (e.g. `authoring-for-agy.md`, `authoring-for-claude.md`, `authoring-for-ghcp.md`).
- **Task 3.4**: Add `skill.yaml` schema documentation to `docs/technical_design/schemas.md`.
- **Task 3.5**: Add a GitHub Actions CI workflow that validates `skill.yaml` files for required fields on every PR.
