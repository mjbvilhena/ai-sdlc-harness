# Migration Plan

Plan for a data, schema, or traffic migration that cannot be a silent code deploy. Pair with skill `sdlc-migration-planner` and DoD `data migration`.

**Quality bar:** Forward path, backward path, and a failed-in-the-middle path are all written. Batch sizes, locks, and dual-write windows are explicit. No "we'll just run it on prod" without verification queries.

## Metadata

| Field | Value |
|---|---|
| Subject | table / topic / index / traffic shift |
| Environments | order of promotion |
| Owner role | |
| Related ADR / RFC / runbook | |
| Rehearsed? | yes (where) / no |

## Why this migration

- User or engineering outcome
- What breaks if we ship the new code without migrating
- Freeze / feature-flag dependencies

## Current vs target

| Aspect | Before | After |
|---|---|---|
| Schema / shape | | |
| Writers | | |
| Readers | | |
| Volume (if known) | | |

Unknown volume is allowed; do not invent row counts.

## Strategy

Choose one and justify: expand/contract, dual write, shadow read, blue/green, offline window, backfill job.

- **Expand:** additive schema first
- **Migrate:** backfill / dual write
- **Contract:** remove old after readers are gone

## Steps

Numbered, each with: command or job, expected result, abort condition, lock/timeout.

1. …
2. …

Include: backup or snapshot **if the repo/user said how**; otherwise state `backup procedure unknown — do not run until the owner provides one`.

## Idempotency and batches

- Resume key
- Batch size and throttle
- What happens if the job retries

## Verification

| Check | Query or signal | Pass criteria |
|---|---|---|
| Row counts / checksums | … | … (do not invent SLOs) |
| Canary reads | … | … |
| App health | existing dashboards | … |

## Rollback

- Schema down / dual-write off / traffic revert
- Whether rollback is **data-lossy** (say so)
- How far back the plan is valid (after contract phase, rollback may be a restore)

## Risk register

| Risk | Likelihood (qualitative) | Detection | Mitigation |
|---|---|---|---|
| Long lock | … | … | … |
| Dual-write drift | … | … | … |
| Irreversible transform | … | … | … |

## Security and privacy (defensive)

- No production dumps in tickets
- Minimize personal data in logs and samples
- Access required (roles)

## Anti-patterns

- One-way `UPDATE` with no verification
- Mixing code contract removal with the first expand PR
- Invented downtime windows or row counts
- Exploit-like "just query the users table and exfiltrate"
- Calling it done when only the happy-path job succeeded
