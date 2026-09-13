# Runbook

Operational procedure a human or on-call agent can follow under stress. Pair with skill `sdlc-runbook-writer`. Not an incident novel and not a design doc.

**Quality bar:** Someone half-awake can detect, mitigate, and escalate without guessing commands. Every command is copy-pasteable and scoped (no unbounded `rm`, no production URL invented). Rollback is explicit.

## Metadata

| Field | Value |
|---|---|
| Service / job | |
| Symptom this covers | one failure mode per runbook |
| Severity if this fires | |
| Last verified | date + env (do not claim verification you did not do) |
| Related dashboards / alerts | names already in the repo |

## When to use

Observable signals (alert name, error rate, user report). If two alerts share this runbook, list both.

## When not to use

Neighboring failures that look similar but have a different runbook.

## Preconditions

- Access/roles required (names, not credentials)
- Feature flags or tenant scope
- "Stop if" conditions (missing backups, unknown blast radius)

## Detection

- What good looks like (metric, log query **without secrets**)
- How to confirm this is *this* incident, not a lookalike

## Mitigation (stop the bleeding)

Numbered, reversible first:

1. Command or console step (exact)
2. Expected result
3. If unexpected → escalate / abort path

Prefer: disable flag, shed load, rollback deploy, fail closed. Do not include exploit steps or "how an attacker would".

## Diagnosis (after users are safe)

- Queries and what they prove
- Likely causes (ranked) with disconfirming evidence

## Recovery

- Return to steady state
- How to verify (same signals as detection)
- Cache / queue / cursor drain if relevant

## Rollback

- Exact revert (deploy, flag, migration)
- Data repair if writes happened (link `migration_plan` if needed)
- When rollback is unsafe

## Escalation

| If | Notify (role) | Bring |
|---|---|---|
| Not mitigated in N minutes | … | … |

Do not invent paging policies. If unknown, write `Unknown — ask the service owner`.

## Post-incident

- Ticket fields to capture
- Whether a postmortem is expected (link `incident_postmortem`)

## Anti-patterns

- "Restart the pod" as the only step with no verification
- Secrets, tokens, or private keys in the doc
- Unverified commands copied from memory
- Blameless-breaking language ("the intern forgot")
- Attack recipes
