# Product Specification: AI SDLC Harness

## 1. Introduction & Purpose

The AI SDLC Harness is a shell-script-based installer and skill library for AI developer tools. It provides a curated set of skills and agents — authored in the native format of each supported harness — and simple installer scripts that copy those files into the correct local configuration directories.

There is no CLI tool to install, no Python package, and no compilation step. The project is a collection of files and shell scripts. The *installation of skills* is strictly zero-dependency (using only `bash` and `cp`). Additionally, the project includes an optional standalone Model Context Protocol (MCP) server that provides agents with Just-In-Time (JIT) retrieval of SDLC standards, templates, and Definitions of Done. (Note: running the MCP server itself requires a local Python/Node runtime).

## 2. Target Personas

- **AI Tooling Engineers**: Developers who want a pre-built library of useful AI skills (code review, PR summarization, etc.) deployed into their local AI tooling with minimal effort.
- **Platform Engineers**: Engineers who want to standardize AI assistant behaviors across a team by distributing a shared skill library via Git.
- **Skill Authors & Contributors**: Developers who want to contribute new skills to the library for the benefit of the broader community.

## 3. Core User Journeys

### Journey 1: Install skills into a target harness (e.g., Claude Code, Cursor, GHCP, Antigravity)

1. The user clones this repository.
2. The user runs the installer script for their preferred harness (e.g., `./install_claude.sh`, `./install_cursor.sh`, `./install_ghcp.sh`, or `./install_agy.sh`) from the repo root.
3. The script discovers all skill directories under `skills/` that contain the corresponding harness subdirectory (e.g., `claude/`, `cursor/`, `ghcp/`, `agy/`).
4. For each skill, the script copies the contents into the target harness's expected local configuration directory.
5. The user opens or reloads their AI tool and the skills are immediately available.

### Journey 2: Author a new skill

1. The author creates a directory under `skills/<skill-name>/`.
2. The author creates `skill.yaml` with metadata (name, description, version, author, targets, triggers).
3. The author creates one or more target-specific subdirectories (`claude/`, `cursor/`, `ghcp/`, `agy/`) and writes the native skill files inside them.
4. The author tests locally by running the relevant installer script.
5. The author opens a Pull Request to contribute the skill back to the library.

### Journey 3: Contribute a skill back

1. The contributor forks the repository and authors a new skill (see Journey 2).
2. The contributor ensures `skill.yaml` is filled in completely and all targeted harness subdirectories are present.
3. The contributor opens a PR. Reviewers check that the target-specific files are correct, well-documented, and safe.
4. On merge, the skill becomes available to all users who pull the latest version of the repo.

### Journey 4: Execute a task using the Tri-Dimensional Framework

1. The user initiates a software task via their preferred harness (e.g., Claude Code, Cursor, GitHub Copilot, Antigravity).
2. The harness invokes the native Lifecycle Driver prompt (e.g., the `code_implementer` skill).
3. The Driver prompt explicitly instructs the AI to query the local MCP Knowledge Server to fetch SDLC standards and Domain/Layer constraints (the Consultants).
4. The AI synthesizes the retrieved constraints to generate the final code artifact, maintaining strict context isolation.

## 4. Functional Requirements

### F1. Skill Directory Convention

- Each skill lives in `skills/<skill-name>/`.
- Each skill directory MUST contain a `skill.yaml` metadata file.
- Each skill directory MAY contain one or more harness-specific subdirectories: `claude/`, `cursor/`, `ghcp/`, `agy/`.
- A harness subdirectory contains the files that are copied verbatim to the target harness's configuration directory.

### F2. Agent Directory Convention & Framework (Multi-Harness)

- Agents are structured according to the **Tri-Dimensional Agent Framework** (Lifecycle, Domain, Layer).
- To support functional parity across modern harnesses (e.g., Claude Code, Cursor, GitHub Copilot, Antigravity), this framework is decoupled:
  - **Lifecycle Drivers**: Authored as native skills/prompts/agents in the `agents/<agent-name>/<harness>/` directories using the harness's specific primitives.
  - **Domain/Layer Consultants**: Maintained as dynamic knowledge payloads served securely and structurally via the MCP Server.
- Installers deploy the Lifecycle Drivers to the user's local workspace or configuration (e.g., `.claude/commands/`, `.cursor/rules/`, `.github/instructions/`, `.antigravity/`) depending on the target.
- Each agent directory MUST contain a `agent.yaml` manifest outlining its role.

### F3. Rule Directory Convention

- Rules are used for passive, ambient context (e.g., style guidelines, format templates) rather than active workflows.
- Each rule lives in `rules/<rule-name>/`.
- Each rule directory MUST contain a `rule.yaml` metadata file.
- Each rule directory MAY contain one or more harness-specific subdirectories (e.g., `claude/`, `cursor/`, `ghcp/`).
- Rules are copied verbatim to the target harness's configuration directory by the installers.

### F4. Installer Scripts

- `install_claude.sh`: Iterates over `skills/*/claude/`, `agents/*/claude/`, and `rules/*/claude/`. Copies `.md` files to `~/.claude/commands/`.
- `install_cursor.sh`: Iterates over `skills/*/cursor/`, `agents/*/cursor/`, and `rules/*/cursor/`. Copies rules to a target workspace directory `.cursor/rules/`.
- `install_ghcp.sh`: Iterates over `skills/*/ghcp/`, `agents/*/ghcp/`, and `rules/*/ghcp/`. Copies instruction files to a target workspace directory `.github/instructions/`.
- `install_agy.sh`: Iterates over `skills/*/agy/`, `agents/*/agy/`, and `rules/*/agy/`. Copies to `~/.gemini/antigravity-cli/builtin/skills/<name>/` and the local workspace `.antigravity/`.
- All installers accept an optional `--workspace <path>` flag (defaults to `$PWD`) to determine where workspace-specific agents should be installed.

### F5. Installer Behaviour

- Installers MUST be idempotent: running the script multiple times must produce the same result.
- Installers MUST print a summary of what was installed and where.
- Installers MUST skip any directory that does not have the relevant harness subdirectory (e.g., `install_claude.sh` skips items with no `claude/` directory).
- Installers SHOULD create destination directories if they do not already exist.
- Installers MUST NOT require any runtime dependency beyond `bash`, `cp`, `mkdir`, and `ln`.

### F6. MCP Knowledge Retrieval Server

- A standalone MCP server (Python or TypeScript) will be scaffolded alongside the `skills/` and installers.
- It exposes a precise JSON API contract (e.g., `get_sdlc_template(doc_type)`, `get_definition_of_done(phase)`) to serve SDLC standards.
- **Fuzzy Matching & Resilience**: The server MUST implement fuzzy string matching or robust alias mapping for input parameters (e.g., gracefully mapping "story", "user story", and "stories" to the same template). If a requested term cannot be resolved, the server MUST return a list of available valid options to help the LLM auto-correct.
- Skill and agent prompts are designed to be lean, explicitly instructing the agent to call the MCP server for specific templates rather than hardcoding them in the prompt.

## 5. Non-Functional Requirements

- **Zero dependencies**: The installer requires no external runtimes like Python or Node.
- **Portable**: Scripts must work on macOS and Linux (via `bash >= 3.2`) and Windows (via native `PowerShell` scripts, i.e., `.ps1`).
- **Readable**: Installer scripts must be thoroughly commented so that authors understand and can trust what is being installed.
- **Safe**: Installers must not delete existing user configuration. Overwrites of previously installed skill files are acceptable; deletion of other files is not.

## 6. Automated Testing of the Harness

Given the shell-based nature of the installers and the modular nature of the skill library and MCP server, automated testing will be broken down into the following strategies:

### 6.1 Shell Script Testing
- **Framework**: BATS (Bash Automated Testing System) will be used to test the installer scripts (`install_claude.sh`, `install_cursor.sh`, `install_ghcp.sh`, `install_agy.sh`, etc.).
- **Test Cases**:
  - Verify correct file copying to target directories based on mock skill structures.
  - Verify idempotency (multiple runs produce the same safe result).
  - Verify skipping of skills/agents that lack the target harness subdirectory.
  - Verify proper handling of the `--workspace` flag and creation of destination directories.

### 6.2 MCP Server Testing
- **Framework**: Standard language-specific testing frameworks (`pytest` for Python, or `Jest`/`Vitest` for TypeScript).
- **Test Cases**:
  - Unit tests for API contracts (e.g., `get_sdlc_template(doc_type)`).
  - Mocked integration tests to verify the MCP server correctly parses and serves the underlying knowledge documents.
  - **Dynamic Consultant Creation**: Verify that as a mock repository evolves (e.g., new domains or architectural layers are built), the MCP Server automatically discovers and generates the corresponding Domain and Layer Consultant knowledge payloads without manual reconfiguration.

### 6.3 Linting and Static Validation
- **Shell Scripts**: `shellcheck` will be used in CI to ensure bash scripts are safe and follow best practices.
- **YAML Validation**: A CI step to validate that all `skill.yaml`, `agent.yaml`, and `rule.yaml` manifest files conform to a defined structural schema.
- **Markdown**: `markdownlint` to ensure consistency in prompt files and documentation.

### 6.4 Agent Behavioral & E2E Testing
- **Framework**: LLM evaluation tools (e.g., `promptfoo`, or custom scripts utilizing standard test runners like `pytest`) integrated with headless harness execution.
- **Test Cases (Mock Projects)**:
  - Maintain sandboxed mock repositories (e.g., a simple API or frontend app) with predefined feature requests, bugs, or refactoring tasks.
  - Programmatically invoke the AI agent/skill (e.g., "Review this PR" or "Implement feature X") against the mock repository.
  - **Evolution Adaptability**: Introduce a new architectural layer or business domain to the mock repo mid-test, and verify that the Lifecycle Agent seamlessly discovers and utilizes the newly auto-created Domain/Layer Consultants via the MCP server.
- **Validation Criteria**:
  - **Functional correctness**: Run the mock project's test suite post-execution to verify the agent's code changes compile and pass tests.
  - **Structural correctness**: Assert that the agent generated the expected files and adhered to standard directory structures.
  - **LLM-as-a-Judge / Evaluation**: Programmatically evaluate the agent's compliance with the specific SDLC standards and Constraints served by the MCP server, and ensure it did not hallucinate or deviate from the given persona.

## 7. Out of Scope for v1

- **Universal format / compilation**: Writing a skill in one format and auto-generating the others is out of scope. Each target is authored directly.
- **Cloud registry**: No hosted skill registry or auto-update mechanism.
- **Bidirectional sync**: Importing a skill from an installed location back into this repo format is out of scope.

### 6.4 Zero-Touch Workspace Integration
The installer scripts MUST seamlessly configure the host IDE (via `mcp.json` or `claude.json`) to communicate with the MCP Knowledge Server without requiring the user to manually edit JSON configuration files.
