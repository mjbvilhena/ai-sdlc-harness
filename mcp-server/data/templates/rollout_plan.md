# Rollout Plan

How a finished change reaches users without a big-bang hope. Pair with DoD `release` / `hotfix` and with `migration_plan` when data moves. Complements `runbook` for the "it went wrong" path.

**Quality bar:** Stages, gates, and rollback are specific. Flags have a default. Monitoring uses signals that already exist or are added in the same change — no invented SLOs.

## Metadata

| Field | Value |
|---|---|
| Change | PR / release / flag name |
| Environments | order |
| Owner role | |
| Related runbook | |

## Blast radius

- Who can be affected (tenant, region, role) — only if known
- Data written, jobs triggered, caches invalidated
- Coupled services that must move together

## Preconditions

- [ ] DoD for the change type is met
- [ ] Migrations expanded (if any) and verified in a lower env
- [ ] Flag or config exists and default is safe
- [ ] Rollback tested or explicitly residual-risk accepted by a human

## Stages

| Stage | Audience | Gate to continue | Abort if |
|---|---|---|---|
| 0 Internal | staff / dogfood | smoke + dashboards | error budget / known bug |
| 1 Canary | % or ring | … | … |
| 2 Full | … | … | … |

Percentages only if the platform supports them; otherwise use rings the repo actually has.

## Monitoring

- Dashboards and alerts to watch (existing names)
- User-visible symptom that means roll back
- How long to watch (do not invent "24h" unless the user/DoD said so — the release DoD may specify a watch window)

## Rollback

- Flag off / revert / traffic shift
- Data: follow `migration_plan` rollback; say if not revert-safe
- Comms: who is told (roles)

## Communication

- Release notes needed? (`release_notes`)
- Support / status page only if the user said that process exists

## Anti-patterns

- "Deploy to prod" as the only stage
- Flag default-on for a risky change with no canary
- Invented uptime percentages
- No owner for the watch window
