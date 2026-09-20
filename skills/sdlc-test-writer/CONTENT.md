## Purpose

Write unit or integration tests for a function, class, or module using the project's existing framework. Prefer a risk-ranked plan before dumping cases. If the user asked for a **test strategy before code exists**, defer to **`sdlc-test-planner`** (`/test-plan`) — this skill **executes** tests at verify time.

## Activation

Trigger when the user asks to "write tests for X", "generate test stubs", or uses `/test`.

## MCP tools (required)

When MCP is available:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="test plan"`. Outline coverage in that shape, then emit tests. If no test plan exists yet and there is no code to cover, stop and hand off to `sdlc-test-planner`. For journey-level work, defer to `sdlc-e2e-scripter` and fetch `e2e test plan` instead.
2. Call `get_definition_of_done` with `component="feature"` or `bugfix` (use `bugfix` when the user is locking in a regression). Honor the returned test expectations.
3. Call `get_layer_consultant` for the layer under test when it is inferable (`api`, `database`, `ui`). Honor testing MUST/NEVER.

If MCP is unavailable, say so and still cover happy path, one edge, and one error path.

## Instructions

1. Identify the target from the user, the active file, or the diff. Read the code. Do not invent APIs.
2. Match the repo's language and test runner (pytest, Jest, go test, …). Place files where this project already puts tests.
3. Cover: happy path, edges (empty, bounds), expected errors, and mocks only for I/O you must not hit.
4. Bugfixes need a test that failed on the old behavior.
5. Use descriptive names. No secrets, production URLs, or real personal data in fixtures.

## Safety

- Do not target production systems.
- Do not invent product behavior that is not in the code or the user's story.
- Do not weaken or delete tests just to go green.
