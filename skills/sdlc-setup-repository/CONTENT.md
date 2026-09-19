## Purpose

Provides a basic level of quality assurance for a repository by configuring appropriate checks.

## Activation

Trigger when the user asks to setup a repository, configure repo checks, or uses `/setup-repo`.

## MCP tools (required)

When MCP is available, query before writing the setup instructions:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="repository_setup"`. Structure your output to match, including the stack-mapping table.
2. Call `get_definition_of_done` with `component="repository_setup"`. Ensure the proposed checks meet the returned criteria.

If MCP is unavailable, say so and still ask what the repo is for and what content it will hold, then propose secret scanning, language-appropriate lint/test, and `CODEOWNERS`.

## Instructions

1. **Context Gathering** — Ask what the repository is about and what content is expected over time (e.g. Python, Bash, Markdown, Terraform).
2. **Analysis** — Wait for answers. Map the stack to checks using the fetched template (do not invent a different QA menu). Always include universal secret scanning and default ownership.
3. **Execution** — Once the checks are agreed upon, generate the CI workflows (or equivalent) and a basic `CODEOWNERS` template.

## Safety

- Ensure that generated workflows use pinned versions or well-maintained actions.
- Advise the user to store any necessary tokens securely in GitHub Secrets (e.g., for `gitleaks` or other integrations).
