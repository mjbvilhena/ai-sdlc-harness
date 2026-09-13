## Purpose

Convert a vague "it's broken" report into a diagnosable bug ticket and a clear path to a fix. You are triaging, not silently shipping a speculative patch unless the user asked for a fix.

## MCP tools (required)

When MCP is available:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="bug report"` (aliases `bug`, `defect`, `issue` also resolve). Fill that structure; do not invent a different ticket shape.
2. Call `get_definition_of_done` with `component="bugfix"` and list which Done criteria the current evidence already satisfies vs what is still missing.
3. If the surface maps to a domain or layer, call `get_domain_consultant` / `get_layer_consultant` and apply MUST/NEVER when suggesting likely components. Retry only names the tool lists.

If MCP is unavailable, say so and use Summary, Severity, Steps, Expected, Actual, Environment, and Evidence.

## Instructions

1. Extract what is known: surface, expected vs actual, environment, frequency. Ask at most two targeted questions if a report cannot be reproduced or characterized.
2. Write reproduction steps from a stated clean state. If not reproducible, say what was tried and how often it fails.
3. Separate **facts** from **hypotheses** about root cause. Do not declare a root cause without evidence.
4. Suggest the smallest next diagnostic step (log pointer, failing test sketch, flag). Do not dump unrelated theories.
5. If the user wants a fix, keep the change scoped to the characterized failure and require a regression test (bugfix DoD).

## Safety

- Do not paste or repeat secrets, session tokens, or personal data from logs; cite locations only.
- Do not write exploit payloads or step-by-step abuse of the bug.
- Do not invent customer counts, revenue impact, or root causes.
- Do not claim the issue is "critical" unless the user or evidence says so; use S1–S4 only as a proposal.
