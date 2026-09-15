## Purpose

Provides a basic level of quality assurance for a repository by configuring appropriate checks.

## Activation

Trigger when the user asks to setup a repository, configure repo checks, or uses `/setup-repo`.

## MCP tools (required)

When MCP is available, query before writing the setup instructions:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="repository_setup"`. Structure your output to match.
2. Call `get_definition_of_done` with `component="repository_setup"`. Ensure the proposed checks meet the returned criteria.

If MCP is unavailable, proceed using the instructions below.

## Instructions

1. **Context Gathering** — Start by asking the user the following questions to understand the repository's needs:
   - What is the repository about?
   - What type of content is expected to be added to it over time (e.g., Python code, Bash scripts, Markdown docs, Terraform, etc.)?
   
2. **Analysis** — Wait for the user's answers. Based on the responses, determine what type of basic quality assurance checks should be added from the very beginning. Use standard robust practices (similar to the `.github` workflows in `ai-sdlc-harness`) to establish basic QA:
   - If the repo contains Bash scripts, propose `bats` for testing and `shellcheck` for linting.
   - If it contains Python, propose SAST tools like `bandit`.
   - If it contains Markdown documentation, propose `markdownlint`.
   - Always propose universal security checks like `gitleaks` for secret scanning.
   - Suggest setting up a `CODEOWNERS` file to establish default ownership and ensure proper review processes.
   
3. **Execution** — Once the checks are agreed upon, generate and output the necessary GitHub Action workflows (or equivalent CI/CD configurations) to enforce these checks. Include a basic `CODEOWNERS` template.

## Safety

- Ensure that generated workflows use pinned versions or well-maintained actions.
- Advise the user to store any necessary tokens securely in GitHub Secrets (e.g., for `gitleaks` or other integrations).
