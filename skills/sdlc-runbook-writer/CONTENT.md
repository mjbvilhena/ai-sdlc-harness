## Purpose

Write an operational runbook that an on-call engineer can follow under stress for **one** failure mode. Not a design doc and not a postmortem.

## MCP tools (required)

When MCP is available:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="runbook"` (aliases `playbook`, `ops runbook` also resolve). Follow its sections and quality bar.
2. If a layer or domain owns the service, call `get_layer_consultant` / `get_domain_consultant` and honor operational MUST/NEVER (timeouts, forbidden stores, audit events).
3. For incident follow-up language, you may fetch `incident postmortem` but do not turn the runbook into a postmortem.

If MCP is unavailable, say so and use When to use, Detection, Mitigation, Diagnosis, Recovery, Rollback, and Escalation.

## Instructions

1. Title the runbook by symptom, not by an entire service ("checkout 5xx after deploy", not "platform").
2. Prefer reversible mitigations first (flag off, rollback, shed load). Every command needs an expected result and an abort path.
3. Use only commands, dashboards, and alert names evidenced in the repo or provided by the user. If a backup/rollback procedure is unknown, write that — do not invent one.
4. Escalation table uses **roles**, not blamed individuals. If paging policy is unknown, say so.
5. After users are safe, diagnosis may list ranked likely causes with disconfirming checks.

## Safety

- No secrets, tokens, private keys, or production connection strings in the runbook.
- No exploit steps or "how an attacker would".
- Do not invent SLOs, paging policies, or verification you did not perform.
- Do not claim legal or customer notification occurred.
