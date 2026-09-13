## Purpose

Plan a data, schema, or traffic migration that cannot be a silent code deploy. Use expand/migrate/contract thinking, verification queries, and an honest rollback.

## MCP tools (required)

When MCP is available:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="migration plan"` (alias `schema migration` also resolve). Follow its sections.
2. Call `get_definition_of_done` with `component="data migration"` and list Done gaps.
3. Call `get_domain_consultant` and `get_layer_consultant` for the data/domain and persistence layer. Honor invariants and forbidden stores.
4. If cutover needs staged traffic, also fetch `rollout plan`. If operators will run the job under stress, fetch `runbook` and keep procedures consistent.

If MCP is unavailable, say so and still write current vs target, numbered steps, verification, and rollback.

## Instructions

1. State why the new code cannot ship without this migration. Do not invent row counts or downtime windows.
2. Prefer expand (additive schema) → migrate (backfill/dual write) → contract (remove old). Call out if an offline window is required and who accepted that risk (role).
3. Numbered steps with expected result, abort condition, batch size, and resume key.
4. If backup/restore is unknown, write that the migration must not run until the owner provides it.
5. Rollback: say whether it is data-lossy. Verification uses queries/signals from the repo or the user — no invented SLOs.

## Safety

- No production dumps, personal data samples, or secrets in the plan.
- No instructions that exfiltrate or "just export the users table".
- Do not invent rehearsal evidence. If it was not rehearsed, say so.
- Stay defensive; this is operations, not an attack narrative.
