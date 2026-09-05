# Product Vision & Goals

## Vision

The AI SDLC Harness is a simple, dependency-free installer that deploys a curated library of AI skills and agents into the local configuration directories of popular AI developer tools.

The core philosophy is **simplicity over abstraction**. Rather than compiling a universal format into multiple targets, skills are **authored directly in the native format of each target harness**. A skill is a directory of hand-crafted, target-specific files. Installing it means copying those files to the right place.

There is no Python package to install, no compilation step, no YAML-to-format translation engine. Just shell scripts and file operations.

## Goals

1. **Zero friction installation**: A single `./install_agy.sh` command is all a developer needs to get the full skill library into Antigravity.
2. **Author-native skills**: Skill authors write directly in the format that each AI tool understands — no intermediate abstraction layer. The skill works exactly as authored.
3. **Multi-harness support from one repo**: The same repo houses skills for Antigravity, Claude Code, and GitHub Copilot. Authors write separate files per target but manage them in one place.
4. **Easy contribution**: Adding a new skill is as simple as creating a directory, dropping in files, and opening a PR.

## Target Harnesses (v1)

- **Antigravity (agy)**: Skills installed to `~/.gemini/antigravity-cli/builtin/skills/<skill-name>/`
- **Claude Code**: Skills installed as custom slash commands to `~/.claude/commands/`
- **GitHub Copilot (ghcp)**: Instructions installed to `.github/instructions/` in the user's workspace

## Non-Goals

- **Universal format / compilation**: We do not aim to write once and compile to all targets. Target-specific authoring is intentional.
- **Cloud registry or distribution**: Skills are distributed via Git. There is no hosted registry.
- **Runtime skill management**: There is no daemon, watcher, or auto-update mechanism.
