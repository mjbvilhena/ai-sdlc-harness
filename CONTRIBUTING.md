# Contributing to AI SDLC Harness

Thank you for contributing! This guide will help you understand how to author and publish skills and rules for this repository.

## Directory Layout

The repository is organized by category, then by item name, and finally by harness target. New skills use the `sdlc-` prefix:

```text
skills/
  sdlc-code-reviewer/       # The name of the skill (kebab-case, sdlc- prefix)
    skill.yaml              # Metadata file (required)
    CONTENT.md              # Canonical body. Installers expand this into each harness file.
    agy/                    # Thin shell + {{SKILL_BODY}}
      SKILL.md
    claude/
      command.md
    cursor/
      prompt.md
    ghcp/
      instructions.md
```

Rules use the same layout with `rule.yaml`, `CONTENT.md`, and `{{RULE_BODY}}` in the harness shells.

Author shared instructions once in `CONTENT.md`. Harness files keep only frontmatter, title, and (for Claude) a Trigger block, plus the placeholder on its own line. Installers substitute the body at install time and **refuse** to write a destination that still contains `{{SKILL_BODY}}` or `{{RULE_BODY}}`.

See [`skills/sdlc-example-skill/`](skills/sdlc-example-skill/) and [`rules/sdlc-example-rule/`](rules/sdlc-example-rule/) for complete stubs.

Cursor shells are `cursor/prompt.md`. The installer expands them into `<ws>/.cursor/prompts/sdlc-<name>.md` (Custom Prompts, not `.cursor/rules/*.mdc`).

Installers also accept an `agents/` tree with the same layout, but **`agents/` is not populated**. Lifecycle Drivers currently live as `skills/` (and ambient `rules/`). Do not add empty agent packages unless a later product decision asks for them.

Matching uninstallers live beside the installers (`install/uninstall_<harness>.sh` / `.ps1`).

## Metadata Schemas

Every skill must have a `skill.yaml` and every rule a `rule.yaml`. If `agents/` is introduced later, each agent needs an `agent.yaml`. These files are used for validation and documentation.

Example `skill.yaml`:
```yaml
name: sdlc-code-reviewer
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

1. [ ] Your item is located in the correct top-level directory (`skills/` or `rules/`). `agents/` is deferred.
2. [ ] The directory name is `kebab-case` and uses the `sdlc-` prefix for library items.
3. [ ] A valid `*.yaml` metadata file is present and accurately reflects the supported targets.
4. [ ] `CONTENT.md` holds the canonical body; each harness file is a thin shell containing `{{SKILL_BODY}}` (skills) or `{{RULE_BODY}}` (rules) on its own line.
5. [ ] You have implemented the skill/rule for at least one harness (preferably all four).
6. [ ] The tone of the prompts is professional, objective, and clear. Do not invent product claims. Lifecycle skills that need project standards should instruct the model to call MCP tools (`get_sdlc_template`, `get_definition_of_done`, `get_domain_consultant`, `get_layer_consultant`) rather than hardcoding those documents.

## Testing

This repository includes a unified testing script `run_tests.sh` at the root, which executes Metadata Validation, MCP Server unit tests, Bandit, BATS installer tests, and (when installed) Gitleaks. E2E tests run only when `GEMINI_API_KEY` is set.

### Running the Tests Locally
Simply execute the helper script:
```bash
./run_tests.sh
```

### End-to-End (E2E) LLM Testing
We have an E2E testing framework in `tests/e2e/test_agent_behavior.py` that executes a real LLM (Gemini) to verify that installed skills properly invoke the MCP server tools and respect constraints.

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
