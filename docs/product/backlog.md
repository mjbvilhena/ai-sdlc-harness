# Product Backlog

## Epic 1: Shell Installer Scripts

> Goal: Deliver working installer scripts for each supported harness.

- **Task 1.1**: Implement `install_claude.sh` — discovers `skills/*/claude/` and copies `.md` files to `~/.claude/commands/`.
- **Task 1.2**: Implement `install_cursor.sh` — discovers `skills/*/cursor/` and copies rules to `.cursor/rules/`.
- **Task 1.3**: Implement `install_ghcp.sh` — discovers `skills/*/ghcp/` and copies instruction files to `.github/instructions/`. Support `--workspace <path>` flag.
- **Task 1.4**: Implement `install_agy.sh` — discovers `skills/*/agy/` and copies contents to `~/.gemini/antigravity-cli/builtin/skills/<name>/`.
- **Task 1.5**: Add agent and rule support to all four installers (i.e., also iterate over `agents/*/` and `rules/*/`).
- **Task 1.6**: Write installer test stubs (dry-run mode or `--dry-run` flag) that print what would be copied without performing any file operations.

## Epic 2: Bundled Skill Library

> Goal: Ship a useful, high-quality set of skills and rules ready to install.

- **Task 2.1**: Author `code-reviewer` skill — reviews PR diffs, highlights issues. Author for `claude`, `cursor`, `ghcp`, `agy`.
- **Task 2.2**: Author `pr-summarizer` skill — generates a PR description from staged changes. Author for `claude`, `cursor`, `ghcp`, `agy`.
- **Task 2.3**: Author `commit-message` rule — passive format guideline for conventional commits. Author for `claude`, `cursor`, `ghcp`, `agy`.
- **Task 2.4**: Author `test-writer` skill — generates test stubs for a given function or module. Author for `claude`, `cursor`, `ghcp`, `agy`.
- **Task 2.5**: Author `docs-updater` skill — updates inline documentation and README sections. Author for `claude`, `cursor`, `ghcp`, `agy`.
- **Task 2.6**: Review and quality-gate all bundled skills and rules for accuracy and safety before first public release.

## Epic 3: Contributor Experience

> Goal: Make it easy for the community to author and contribute new skills, agents, and rules.

- **Task 3.1**: Create `skills/example-skill/` and `rules/example-rule/` with complete stubs for all harness targets and fully-annotated metadata files.
- **Task 3.2**: Write `CONTRIBUTING.md` — explains the directory layouts, metadata schemas, how to author for each harness, and the PR checklist.
- **Task 3.3**: Write per-harness authoring guides under `docs/guides/` (e.g., `authoring-for-claude.md`, `authoring-for-cursor.md`, `authoring-for-ghcp.md`, `authoring-for-agy.md`).
- **Task 3.4**: Add `skill.yaml`, `agent.yaml`, and `rule.yaml` schema documentation to `docs/technical_design/schemas.md`.
- **Task 3.5**: Add a GitHub Actions CI workflow that validates all metadata files for required fields on every PR.

## Epic 4: MCP Knowledge Retrieval Server

> Goal: Build the standalone MCP server to deliver SDLC knowledge (DoD, templates, architecture rules) with high resilience to LLM tool-calling quirks.

- **Task 4.1**: Scaffold a basic Python or TypeScript MCP server with tool definitions for `get_sdlc_template` and `get_definition_of_done`.
- **Task 4.2**: Implement fuzzy matching and alias resolution for parameters (e.g., mapping "user story" and "stories" to "story").
- **Task 4.3**: Implement graceful degradation so that unrecognized queries return a helpful list of valid options instead of failing blindly.
- **Task 4.4**: Populate the initial database/directory of SDLC standards (ADR templates, PR checklists, etc.).
- **Task 4.5**: Add tests for the MCP server ensuring robust LLM interaction flows.
