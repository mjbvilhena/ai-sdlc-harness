# Incident Postmortem Template

Blameless operational learning document. Pair with skill `sdlc-postmortem-writer`. This is not a performance review and not a legal filing.

**Quality bar:** A reader can retell what users experienced, what the system did, what we changed to stop the bleeding, and which follow-ups prevent recurrence. Every time and metric is sourced or marked unknown.

## Metadata

| Field | Value |
|---|---|
| Incident id / name | |
| Severity | S1–S4 as the org defines it (do not invent a scheme) |
| Status | Draft / Reviewed / Actions tracked |
| Started / detected / mitigated / resolved | timestamps + timezone |
| Author role | |
| Reviewers | roles |

## Executive summary

One short paragraph: impact, duration, user-visible effect, how it was mitigated. No root-cause deep dive here.

## Customer and system impact

- What users could not do (and who, if known without personal data)
- Internal impact (SLOs, queues, dependent teams) — only if evidenced
- Workarounds given during the incident
- Unknowns explicitly listed

## Timeline (UTC or stated zone)

Chronological, one row per event. Distinguish detect / diagnose / mitigate / communicate / resolve.

| Time | Event | Evidence |
|---|---|---|
| HH:MM | … | log id, chat excerpt (redacted), dashboard |

## Detection and response

- How we learned (monitor, customer, deploy)
- What delayed detection
- Decision log: what we tried and why we stopped or continued

## Root cause and contributing factors

Separate:

1. **Proximate cause** — the thing that immediately broke user experience
2. **Contributing factors** — latent conditions (missing limit, unclear runbook, noisy page)
3. **What we ruled out** — with evidence

Do not assign personal fault. Systems, processes, and interfaces fail.

## Resolution and recovery

- Mitigations in order (rollback, flag, scale, patch)
- How we confirmed recovery (signals, not hope)
- Residual risk still present

## What went well / what was lucky

Keep this factual. Luck is a signal that a control is missing.

## Action items

Each item: outcome, owner **role**, due window, how we will know it is done. Prefer reversible, measurable work.

- [ ] **Prevent** — remove the class of failure
- [ ] **Detect** — signal that would have fired earlier
- [ ] **Respond** — runbook / paging / comms gap
- [ ] **Document** — ADR, runbook, or DOMAIN/LAYER update

## Communication record

External or internal notices *only if they happened*. Do not claim regulatory notification occurred unless the user said so.

## Anti-patterns

- Invented timestamps, customer counts, or dollar impact
- "Human error" as root cause
- Action items without owners or success criteria
- Secrets, tokens, or personal data copied from chat dumps
- Certification or compliance claims
