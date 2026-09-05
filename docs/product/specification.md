# Product Specification: AI SDLC Harness

## 1. Introduction & Purpose

The AI SDLC Harness is a shell-script-based installer and skill library for AI developer tools. It provides a curated set of skills and agents — authored in the native format of each supported harness — and simple installer scripts that copy those files into the correct local configuration directories.

There is no CLI tool to install, no Python package, and no compilation step. The project is a collection of files and shell scripts.

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

## 4. Functional Requirements

### F1. Skill Directory Convention

- Each skill lives in `skills/<skill-name>/`.
- Each skill directory MUST contain a `skill.yaml` metadata file.
- Each skill directory MAY contain one or more harness-specific subdirectories: `agy/`, `claude/`, `ghcp/`.
- A harness subdirectory contains the files that are copied verbatim to the target harness's configuration directory.

### F2. Agent Directory Convention

- Agents follow the same layout as skills, but live under `agents/<agent-name>/`.
- Each agent directory MUST contain an `agent.yaml` metadata file.

### F3. Installer Scripts

- `install_agy.sh`: Iterates over `skills/*/agy/` and `agents/*/agy/`. For each, copies contents to `~/.gemini/antigravity-cli/builtin/skills/<name>/`. Creates the destination directory if it does not exist.
- `install_claude.sh`: Iterates over `skills/*/claude/` and `agents/*/claude/`. Copies `.md` files to `~/.claude/commands/`.
- `install_ghcp.sh`: Iterates over `skills/*/ghcp/` and `agents/*/ghcp/`. Copies instruction files to a target workspace directory. Accepts an optional `--workspace <path>` flag (defaults to `$PWD`).

### F4. Installer Behaviour

- Installers MUST be idempotent: running the script multiple times must produce the same result.
- Installers MUST print a summary of what was installed and where.
- Installers MUST skip any skill directory that does not have the relevant harness subdirectory (i.e. `install_agy.sh` skips skills with no `agy/` directory).
- Installers SHOULD create destination directories if they do not already exist.
- Installers MUST NOT require any runtime dependency beyond `bash`, `cp`, `mkdir`, and `ln`.

## 5. Non-Functional Requirements

- **Zero dependencies**: The installer requires only standard Unix utilities. No Python, Node, or other runtimes.
- **Portable**: Scripts must work on macOS and Linux with `bash >= 3.2`.
- **Readable**: Installer scripts must be thoroughly commented so that authors understand and can trust what is being installed.
- **Safe**: Installers must not delete existing user configuration. Overwrites of previously installed skill files are acceptable; deletion of other files is not.

## 6. Out of Scope for v1

- **Universal format / compilation**: Writing a skill in one format and auto-generating the others is out of scope. Each target is authored directly.
- **Cursor support**: Cursor is not a v1 target harness.
- **Cloud registry**: No hosted skill registry or auto-update mechanism.
- **Bidirectional sync**: Importing a skill from an installed location back into this repo format is out of scope.
