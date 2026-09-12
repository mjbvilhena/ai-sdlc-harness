# Contributing to AI SDLC Harness

Thank you for contributing! This guide will help you understand how to author and publish skills, rules, and agents for this repository.

## Directory Layout

The repository is organized by category, then by item name, and finally by harness target:

```text
skills/
  code-reviewer/            # The name of the skill (kebab-case)
    skill.yaml              # Metadata file (required)
    agy/                    # Antigravity implementation
      SKILL.md
    claude/                 # Claude Code implementation
      command.md
    cursor/                 # Cursor implementation
      rule.mdc
    ghcp/                   # GitHub Copilot implementation
      instructions.md
```

## Metadata Schemas

Every skill must have a `skill.yaml`, every rule a `rule.yaml`, and every agent an `agent.yaml`. These files are used for validation and documentation.

Example `skill.yaml`:
```yaml
name: code-reviewer
description: Reviews a PR diff.
version: 1.0.0
author: your-github-handle
targets:
  - agy
  - claude
  - cursor
  - ghcp
triggers:
  - /review
```

For full schema details, see [schemas.md](docs/technical_design/schemas.md).

## Authoring for Each Harness

We support four harnesses. For detailed guides on how to write prompts for each, see the documentation in `docs/guides/`:

- [Authoring for Claude Code](docs/guides/authoring-for-claude.md)
- [Authoring for Cursor](docs/guides/authoring-for-cursor.md)
- [Authoring for GitHub Copilot](docs/guides/authoring-for-ghcp.md)
- [Authoring for Antigravity (AGY)](docs/guides/authoring-for-agy.md)

## PR Checklist

Before submitting a Pull Request, please ensure:

1. [ ] Your item is located in the correct top-level directory (`skills/`, `rules/`, or `agents/`).
2. [ ] The directory name is `kebab-case`.
3. [ ] A valid `*.yaml` metadata file is present and accurately reflects the supported targets.
4. [ ] You have implemented the skill/rule/agent for at least one harness (preferably all four).
5. [ ] The tone of the prompts is professional, objective, and clear.

## Testing

This repository includes a unified testing script `run_tests.sh` at the root, which executes Metadata Validation, MCP Server unit tests, and BATS installer tests.

### Running the Tests Locally
Simply execute the helper script:
```bash
./run_tests.sh
```

### End-to-End (E2E) LLM Testing
We have an E2E testing framework in `tests/e2e/test_agent_behavior.py` that executes a real LLM (Gemini) to verify that agents properly invoke the MCP server tools and respect constraints. 

Because this runs a real LLM, it requires an API key and is automatically skipped in standard CI runs if the key is missing.

To run the E2E tests locally:
```bash
# 1. Enter the MCP server directory and set up the virtual environment
cd mcp-server
source venv/bin/activate
pip install -r requirements.txt

# 2. Export your Gemini API key
export GEMINI_API_KEY="your-api-key-here"

# 3. Run the pytest suite against the e2e directory
PYTHONPATH=. pytest ../tests/e2e/test_agent_behavior.py -s
```
