# Product Specification: AI SDLC Harness

## 1. Introduction & Purpose

The AI SDLC Harness is a shell-script-based installer and skill library for AI developer tools. It provides a curated set of skills and agents — authored in the native format of each supported harness — and simple installer scripts that copy those files into the correct local configuration directories.

There is no CLI tool to install, no Python package, and no compilation step. The project is a collection of files and shell scripts. The *installation of skills* is strictly zero-dependency (using only `bash` and `cp`). Additionally, the project includes an optional standalone Model Context Protocol (MCP) server that provides agents with Just-In-Time (JIT) retrieval of SDLC standards, templates, and Definitions of Done. (Note: running the MCP server itself requires a local Python/Node runtime).

## 2. Target Personas

- **AI Tooling Engineers**: Developers who want a pre-built library of useful AI skills (code review, PR summarization, etc.) deployed into their local AI tooling with minimal effort.
- **Platform Engineers**: Engineers who want to standardize AI assistant behaviors across a team by distributing a shared skill library via Git.
- **Skill Authors & Contributors**: Developers who want to contribute new skills to the library for the benefit of the broader community.

## 3. Core User Journeys

### Journey 1: Install skills into Antigravity

1. The user clones this repository.
2. The user runs `./install_agy.sh` from the repo root.
3. The script discovers all skill directories under `skills/` that contain an `agy/` subdirectory.
4. For each skill, the script copies the `agy/` contents into `~/.gemini/antigravity-cli/builtin/skills/<skill-name>/`.
5. The user restarts (or reloads) Antigravity and the skills are immediately available.

### Journey 2: Author a new skill

1. The author creates a directory under `skills/<skill-name>/`.
2. The author creates `skill.yaml` with metadata (name, description, version, author, targets, triggers).
3. The author creates one or more target-specific subdirectories (`agy/`, `claude/`, `ghcp/`) and writes the native skill files inside them.
4. The author tests locally by running the relevant installer script.
5. The author opens a Pull Request to contribute the skill back to the library.

### Journey 3: Contribute a skill back

1. The contributor forks the repository and authors a new skill (see Journey 2).
2. The contributor ensures `skill.yaml` is filled in completely and all targeted harness subdirectories are present.
3. The contributor opens a PR. Reviewers check that the target-specific files are correct, well-documented, and safe.
4. On merge, the skill becomes available to all users who pull the latest version of the repo.

### Journey 4: Execute a task using the Tri-Dimensional Framework

1. The user initiates a software task via their preferred harness (Claude Code, Cursor, Antigravity).
2. The harness invokes the native Lifecycle Driver prompt (e.g., the `code_implementer` skill).
3. The Driver prompt explicitly instructs the AI to query the local MCP Knowledge Server to fetch SDLC standards and Domain/Layer constraints (the Consultants).
4. The AI synthesizes the retrieved constraints to generate the final code artifact, maintaining strict context isolation.

## 4. Functional Requirements

### F1. Skill Directory Convention

- Each skill lives in `skills/<skill-name>/`.
- Each skill directory MUST contain a `skill.yaml` metadata file.
- Each skill directory MAY contain one or more harness-specific subdirectories: `agy/`, `claude/`, `ghcp/`, `cursor/`.
- A harness subdirectory contains the files that are copied verbatim to the target harness's configuration directory.

### F2. Agent Directory Convention & Framework (Multi-Harness)

- Agents are structured according to the **Tri-Dimensional Agent Framework** (Lifecycle, Domain, Layer).
- To support functional parity across modern harnesses (Claude, Cursor, AGY, GHCP), this framework is decoupled:
  - **Lifecycle Drivers**: Authored as native skills/prompts/agents in the `agents/<agent-name>/<harness>/` directories using the harness's specific primitives.
  - **Domain/Layer Consultants**: Maintained as dynamic knowledge payloads served securely and structurally via the MCP Server.
- Installers deploy the Lifecycle Drivers to the user's local workspace (`.antigravity/`, `.cursor/rules/`, `.github/instructions/`, `.claude/commands/`) depending on the target.
- Each agent directory MUST contain a `.yaml` manifest outlining its role.

### F3. Installer Scripts

- `install_agy.sh`: Iterates over `skills/*/agy/` and `agents/*/agy/`. Copies skills to `~/.gemini/antigravity-cli/builtin/skills/<name>/` and agents to the local workspace `.antigravity/`.
- `install_claude.sh`: Iterates over `skills/*/claude/` and `agents/*/claude/`. Copies `.md` files to `~/.claude/commands/`.
- `install_ghcp.sh`: Iterates over `skills/*/ghcp/` and `agents/*/ghcp/`. Copies instruction files to a target workspace directory `.github/instructions/`.
- `install_cursor.sh`: Iterates over `skills/*/cursor/` and `agents/*/cursor/`. Copies rules to a target workspace directory `.cursor/rules/`.
- All installers accept an optional `--workspace <path>` flag (defaults to `$PWD`) to determine where workspace-specific agents should be installed.

### F4. Installer Behaviour

- Installers MUST be idempotent: running the script multiple times must produce the same result.
- Installers MUST print a summary of what was installed and where.
- Installers MUST skip any skill directory that does not have the relevant harness subdirectory (i.e. `install_agy.sh` skips skills with no `agy/` directory).
- Installers SHOULD create destination directories if they do not already exist.
- Installers MUST NOT require any runtime dependency beyond `bash`, `cp`, `mkdir`, and `ln`.

### F5. MCP Knowledge Retrieval Server

- A standalone MCP server (Python or TypeScript) will be scaffolded alongside the `skills/` and installers.
- It exposes a precise JSON API contract (e.g., `get_sdlc_template(doc_type)`, `get_definition_of_done(phase)`) to serve SDLC standards.
- Skill and agent prompts are designed to be lean, explicitly instructing the agent to call the MCP server for specific templates rather than hardcoding them in the prompt.

## 5. Non-Functional Requirements

- **Zero dependencies**: The installer requires only standard Unix utilities. No Python, Node, or other runtimes.
- **Portable**: Scripts must work on macOS and Linux with `bash >= 3.2`.
- **Readable**: Installer scripts must be thoroughly commented so that authors understand and can trust what is being installed.
- **Safe**: Installers must not delete existing user configuration. Overwrites of previously installed skill files are acceptable; deletion of other files is not.

## 6. Out of Scope for v1

- **Universal format / compilation**: Writing a skill in one format and auto-generating the others is out of scope. Each target is authored directly.
- **Cloud registry**: No hosted skill registry or auto-update mechanism.
- **Bidirectional sync**: Importing a skill from an installed location back into this repo format is out of scope.
