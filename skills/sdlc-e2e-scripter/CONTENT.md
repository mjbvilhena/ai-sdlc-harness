## Purpose

Scaffold Playwright or Cypress end-to-end tests from user-story acceptance criteria. Match the repo's existing test stack when one is present. If the user asked for an **e2e strategy before code exists**, defer to **`sdlc-test-planner`** (`/test-plan`) — this skill **executes** journeys at verify time.

## MCP tools (required)

When MCP is available:

1. Call `get_sdlc_template` with `template_type="e2e test plan"` (aliases `e2e plan`, `end-to-end test plan` also resolve). Use it to structure journeys, stability, and environment rules before writing scripts.
2. Call `get_sdlc_template` with `template_type="user story"` so scenarios follow the project's story/AC shape. If the user already pasted complete Given/When/Then criteria, still fetch the template and map their criteria onto it.
3. Call `get_layer_consultant` for the UI/frontend layer when the flow is user-facing (`ui`, `frontend`, or a name the tool lists). Honor selector or testing constraints it returns.

If MCP is unavailable, say so and proceed from the provided acceptance criteria.

## Instructions

1. Prefer the project's existing E2E runner (Playwright or Cypress). If both or neither exist, ask once, or default to Playwright and state that assumption.
2. Generate one test (or `test.step`) per acceptance scenario. Use roles/labels over brittle CSS where possible.
3. Cover the happy path and one meaningful failure or empty state when the criteria include it.
4. Place files next to existing E2E tests when that layout is clear.

## Safety

- Target local or documented test environments only. Do not point tests at production URLs unless the user explicitly provided that base URL.
- Do not hard-code secrets, session tokens, or real personal data. Use fixtures or env vars.
- Do not invent product behavior that is not in the story or the codebase.
