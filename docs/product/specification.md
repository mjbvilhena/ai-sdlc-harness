# Product Specification: AI SDLC Harness

## 1. Introduction & Purpose

The AI SDLC Harness is a shell-script-based installer and skill library for AI developer tools. It provides a curated set of skills and rules — a shared `CONTENT.md` body plus thin native shells per harness — and installer scripts that expand those files into the correct local configuration directories. A separate `agents/` tree is deferred.

There is no CLI tool to install, no compiled package, and no compilation of one harness file into another. Shared skill/rule instructions live in `CONTENT.md`; each target has a thin native shell. The *copy/expand of skills* uses only `bash` and `cp` (or native PowerShell). A live installer currently also invokes host `python3` to merge MCP JSON (Epic 12.5). The optional MCP server under `mcp-server/` needs a local Python runtime to actually serve templates, Definitions of Done, and Domain/Layer consultants.

## 2. Target Personas

- **AI Tooling Engineers**: Developers who want a pre-built library of useful AI skills (code review, PR summarization, etc.) deployed into their local AI tooling with minimal effort.
- **Platform Engineers**: Engineers who want to standardize AI assistant behaviors across a team by distributing a shared skill library via Git.
- **Skill Authors & Contributors**: Developers who want to contribute new skills to the library for the benefit of the broader community.

## 3. Core User Journeys

### Journey 1: Install skills into a target harness (e.g., Claude Code, Cursor, GHCP, Antigravity)

1. The user clones this repository.
2. The user runs the installer script for their preferred harness from the repo root (e.g., `./install/install_claude.sh`, `./install/install_cursor.sh`, `./install/install_ghcp.sh`, or `./install/install_agy.sh`).
3. The script discovers all skill directories under `skills/` that contain the corresponding harness subdirectory (e.g., `claude/`, `cursor/`, `ghcp/`, `agy/`).
4. For each skill, the script copies the contents into the target harness's expected local configuration directory.
5. The user opens or reloads their AI tool and the skills are immediately available.

### Journey 2: Author a new skill

1. The author creates a directory under `skills/<skill-name>/`.
2. The author creates `skill.yaml` with metadata (name, description, version, author, targets, triggers).
3. The author writes `CONTENT.md` (canonical body) and thin harness shells (`claude/`, `cursor/`, `ghcp/`, `agy/`) that contain `{{SKILL_BODY}}` on its own line.
4. The author tests locally by running the relevant installer script (it expands `CONTENT.md` into the destination).
5. The author opens a Pull Request to contribute the skill back to the library.

### Journey 3: Contribute a skill back

1. The contributor forks the repository and authors a new skill (see Journey 2).
2. The contributor ensures `skill.yaml` is filled in completely and all targeted harness subdirectories are present.
3. The contributor opens a PR. Reviewers check that the target-specific files are correct, well-documented, and safe.
4. On merge, the skill becomes available to all users who pull the latest version of the repo.

### Journey 4: Execute a task using the Tri-Dimensional Framework

1. The user initiates a software task via their preferred harness (e.g., Claude Code, Cursor, GitHub Copilot, Antigravity).
2. The harness invokes the native Lifecycle Driver prompt (today: a skill under `skills/`, e.g. `sdlc-code-reviewer`). Dedicated `agents/` packages are deferred.
3. The Driver prompt explicitly instructs the AI to query the local MCP Knowledge Server to fetch SDLC standards and Domain/Layer constraints (the Consultants).
4. The AI synthesizes the retrieved constraints to generate the final code artifact, maintaining strict context isolation.

## 4. Functional Requirements

### F1. Skill Directory Convention

- Each skill lives in `skills/<skill-name>/`.
- Each skill directory MUST contain a `skill.yaml` metadata file.
- Each skill directory MAY contain one or more harness-specific subdirectories: `claude/`, `cursor/`, `ghcp/`, `agy/`.
- A harness subdirectory contains thin shells (`command.md`, `prompt.md`, `instructions.md`, `SKILL.md` / `RULE.md`). Installers expand sibling `CONTENT.md` into `{{SKILL_BODY}}` / `{{RULE_BODY}}` and write the resolved file to the target harness's configuration directory.

### F2. Lifecycle Drivers, Consultants, and deferred `agents/`

- Work is structured according to the **Tri-Dimensional Agent Framework** (Lifecycle, Domain, Layer).
- To support functional parity across modern harnesses (Claude Code, Cursor, GitHub Copilot, Antigravity), this framework is decoupled:
  - **Lifecycle Drivers (current)**: Authored as native skills and rules under `skills/<name>/<harness>/` and `rules/<name>/<harness>/` using each harness's primitives. These are what the installers deploy today.
  - **Domain/Layer Consultants**: Dynamic knowledge payloads served by the MCP Server (`get_domain_consultant`, `get_layer_consultant`), sourced from workspace `DOMAIN.md` / `LAYER.md` files.
  - **`agents/` (deferred)**: A separate agent-package tree is **not populated**. Installers already iterate `agents/` when present and skip it when absent. Do not invent full agent packages until that product decision is revisited.
- Installers deploy Lifecycle Drivers to the target harness location (e.g., `.claude/commands/`, `.cursor/commands/`, `.github/instructions/`, global AGY `~/.gemini/antigravity-cli/builtin/skills/` or workspace `.agents/skills/`).
- If `agents/` is introduced later, each agent directory MUST contain an `agent.yaml` manifest.

### F3. Rule Directory Convention

- Rules are used for passive, ambient context (e.g., style guidelines, format templates) rather than active workflows.
- Each rule lives in `rules/<rule-name>/`.
- Each rule directory MUST contain a `rule.yaml` metadata file.
- Each rule directory MAY contain one or more harness-specific subdirectories (e.g., `agy/`, `claude/`, `cursor/`, `ghcp/`).
- Rules (and skills) are installed by expanding `CONTENT.md` into `{{RULE_BODY}}` / `{{SKILL_BODY}}` in the harness shell. Destinations never contain unresolved placeholders.

### F4. Installer Scripts

Installers live under `install/` (`install/install_<harness>.sh` and `.ps1`).

- `install/install_claude.sh`: Iterates over `skills/*/claude/`, `agents/*/claude/` (if present), and `rules/*/claude/`. Expands each `command.md` + sibling `CONTENT.md` to `~/.claude/commands/sdlc-<name>.md`, or `<ws>/.claude/commands/` when `--workspace` is set.
- `install/install_cursor.sh`: Same pattern for `cursor/prompt.md` → `<ws>/.cursor/commands/sdlc-<name>.md`. Workspace defaults to `$PWD`.
- `install/install_ghcp.sh`: Same pattern for `ghcp/instructions.md` → `<ws>/.github/instructions/sdlc-<name>.instructions.md`. Workspace defaults to `$PWD`.
- `install/install_agy.sh`: Expands `agy/` files (typically `SKILL.md` / `RULE.md`) into `~/.gemini/antigravity-cli/builtin/skills/sdlc-<name>/` or `<ws>/.agents/skills/sdlc-<name>/`. Destination YAML `name:` is rewritten to the same `sdlc-` name.
- `--workspace <path>` is optional for Claude and AGY (omit for user-global install). Cursor and GHCP are always workspace-scoped; omitting the flag uses `$PWD`.
- `install/uninstall_<harness>.sh` / `.ps1`: Intended to remove previously installed `sdlc-*` artifacts from the same destinations and, where implemented, drop the `sdlc-knowledge` MCP server key without deleting sibling servers. Current reverse-path bugs are Epic 12 (Cursor still deletes `.cursor/prompts/`; Claude deletes `sdlc-*.json` while install writes `sdlc-*.md`; GHCP does not remove `.vscode/mcp.json`).

### F5. Installer Behaviour

- Installers MUST be idempotent: running the script multiple times must produce the same result.
- Installers MUST remove previously installed `sdlc-*` artifacts in the destination before writing new ones (dry-run must report those paths without deleting). Non-`sdlc-*` user files MUST be left untouched.
- Installed destination names (and YAML frontmatter `name:` when present) MUST start with `sdlc-`. If a source folder basename already has that prefix it is used as-is; otherwise the installer prefixes it.
- Installers MUST print a summary of what was installed and where.
- Installers MUST skip any directory that does not have the relevant harness subdirectory (e.g., `install_claude.sh` skips items with no `claude/` directory).
- Installers SHOULD create destination directories if they do not already exist.
- Installers MUST NOT require any runtime dependency beyond standard Unix utilities (`bash`, `cp`, `mkdir`, `cat`, `grep`, `mktemp`) or native PowerShell **for the copy/expand step**. A live (non-`--dry-run`) install currently invokes host `python3` to merge MCP JSON (Task 12.5).
- Installers MUST expand `CONTENT.md` into `{{SKILL_BODY}}` (skills/agents) or `{{RULE_BODY}}` (rules) and MUST fail if `CONTENT.md` or the placeholder is missing. They MUST NOT write unresolved placeholders.

### F6. MCP Knowledge Retrieval Server

- A standalone Python MCP server lives under `mcp-server/` alongside the `skills/` and installers.
- It exposes a precise JSON API contract (e.g., `get_sdlc_template(template_type)`, `get_definition_of_done(component)`) to serve SDLC standards.
- **Fuzzy Matching & Resilience**: The server MUST implement fuzzy string matching or robust alias mapping for input parameters (e.g., gracefully mapping "story", "user story", and "stories" to the same template). If a requested term cannot be resolved, the server MUST return a list of available valid options to help the LLM auto-correct.
- Skill and agent prompts are designed to be lean, explicitly instructing the agent to call the MCP server for specific templates rather than hardcoding them in the prompt.

## 5. Non-Functional Requirements

- **Zero dependencies for copy/expand**: The skill/rule copy step requires no external runtimes like Node. A live installer currently needs host `python3` only to merge MCP JSON; running the knowledge server needs the `mcp-server/venv` Python.
- **Portable**: Scripts must work on macOS and Linux (via `bash >= 3.2`) and Windows (via native `PowerShell` scripts, i.e., `.ps1`).
- **Readable**: Installer scripts must be thoroughly commented so that authors understand and can trust what is being installed.
- **Safe**: Installers must not delete existing user configuration. Overwrites of previously installed skill files are acceptable; deletion of other files is not.

## 6. Automated Testing of the Harness

Given the shell-based nature of the installers and the modular nature of the skill library and MCP server, automated testing will be broken down into the following strategies:

### 6.1 Shell Script Testing
- **Framework**: BATS (Bash Automated Testing System) is used to test the installer scripts (`install/install_claude.sh`, `install/install_cursor.sh`, `install/install_ghcp.sh`, `install/install_agy.sh`, etc.).
- **Test Cases**:
  - Verify correct `CONTENT.md` expansion and destination writes based on mock skill structures.
  - Verify idempotency (multiple runs produce the same safe result).
  - Verify skipping of skills/agents that lack the target harness subdirectory.
  - Verify proper handling of the `--workspace` flag and creation of destination directories.

### 6.2 MCP Server Testing
- **Framework**: Standard language-specific testing frameworks (`pytest` for Python, or `Jest`/`Vitest` for TypeScript).
- **Test Cases**:
  - Unit tests for API contracts (e.g., `get_sdlc_template(template_type)`).
  - Mocked integration tests to verify the MCP server correctly parses and serves the underlying knowledge documents.
  - **Dynamic Consultant Creation**: Verify that as a mock repository evolves (e.g., new domains or architectural layers are built), the MCP Server automatically discovers and generates the corresponding Domain and Layer Consultant knowledge payloads without manual reconfiguration.

### 6.3 Linting and Static Validation
- **Shell Scripts**: `shellcheck` will be used in CI to ensure bash scripts are safe and follow best practices.
- **YAML Validation**: A CI step to validate that all `skill.yaml`, `agent.yaml`, and `rule.yaml` manifest files conform to a defined structural schema.
- **Markdown**: `markdownlint` to ensure consistency in prompt files and documentation.

### 6.4 Agent Behavioral & E2E Testing
- **Framework**: LLM evaluation tools (e.g., `promptfoo`, or custom scripts utilizing standard test runners like `pytest`) integrated with headless harness execution.
- **Implemented today**: `tests/e2e/test_agent_behavior.py` runs Gemini with a stub `get_domain_consultant` function (not a live MCP process) plus optional `test_cli_integration.py` CLI smoke tests when `agy` / `claude` binaries exist. `run_tests.sh` includes the directory only when `GEMINI_API_KEY` is set. The mock-project evolution / promptfoo / LLM-as-judge cases below remain a scaffold target (Task 8.3), not current CI.
- **Test Cases (Mock Projects)**:
  - Maintain sandboxed mock repositories (e.g., a simple API or frontend app) with predefined feature requests, bugs, or refactoring tasks.
  - Programmatically invoke the AI agent/skill (e.g., "Review this PR" or "Implement feature X") against the mock repository.
  - **Evolution Adaptability**: Introduce a new architectural layer or business domain to the mock repo mid-test, and verify that the Lifecycle Agent seamlessly discovers and utilizes the newly auto-created Domain/Layer Consultants via the MCP server.
- **Validation Criteria**:
  - **Functional correctness**: Run the mock project's test suite post-execution to verify the agent's code changes compile and pass tests.
  - **Structural correctness**: Assert that the agent generated the expected files and adhered to standard directory structures.
  - **LLM-as-a-Judge / Evaluation**: Programmatically evaluate the agent's compliance with the specific SDLC standards and Constraints served by the MCP server, and ensure it did not hallucinate or deviate from the given persona.

### 6.5 Zero-Touch Workspace Integration
The installer scripts MUST seamlessly configure the host IDE to communicate with the MCP Knowledge Server without requiring the user to manually edit JSON configuration files. Implemented locations:

- Claude: `<ws>/claude_desktop_config.json` (workspace) or `~/.claude/claude_desktop_config.json` (global)
- Cursor: `<ws>/.cursor/mcp.json` (`mcpServers`)
- Antigravity: `<ws>/.agents/mcp_config.json` (workspace) or `~/.gemini/config/mcp_config.json` (global)
- GitHub Copilot / VS Code: `<ws>/.vscode/mcp.json` (`servers` key — VS Code / Copilot workspace schema)

Bash installers merge `sdlc-knowledge` into an existing file (they do not replace the whole JSON). The MCP `command` they write is `mcp-server/venv/bin/python` from this clone. A live install currently calls host `python3` to perform that merge.

## 7. Out of Scope for v1

- **Universal format / compilation**: We do not compile one harness file into the others. Shared instructions live in `CONTENT.md`; each target still has a thin native shell (frontmatter / triggers).
- **Cloud registry**: No hosted skill registry or auto-update mechanism.
- **Bidirectional sync**: Importing a skill from an installed location back into this repo format is out of scope.
