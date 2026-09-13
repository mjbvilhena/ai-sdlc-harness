# Definition of Done: Hotfix

A production hotfix is **Done** when the user-visible incident is mitigated with the smallest safe change and the follow-up path is real. Pair with `runbook`, `rollout_plan`, and later `incident_postmortem`.

## Required

- [ ] **Severity confirmed** — a human (role) confirmed this is an incident-class fix, not a normal bugfix queue-jump
- [ ] **Minimal diff** — only what stops the bleeding; no refactors, dependency upgrades, or drive-by features
- [ ] **Review** — at least one qualified reviewer (tech lead / EM / on-call peer as the org defines); same-person merge only if the org already allows it *and* that is stated
- [ ] **Verification in prod (or the failing env)** — the original symptom is gone on stated signals; include request ids / dashboard names, not screenshots of hope
- [ ] **Rollback known** — revert or flag-off path written before or with the deploy
- [ ] **CI** — required checks green unless a documented emergency bypass was used; if bypassed, say who approved and when checks will run
- [ ] **Regression seed** — a failing test or a dated follow-up ticket to add one within the team's stated window
- [ ] **Postmortem scheduled or filed** — calendar or draft; blameless
- [ ] **Comms** — only the notices that actually happened; do not claim customer/legal notification

## Not done if

- The "fix" is a config toggle nobody can find
- Monitoring was not watched after deploy
- Root cause is still "unknown" *and* no follow-up owner exists

## Agent notes

Fetch `hotfix` and often `bugfix` for the durable follow-up. Prefer `get_sdlc_template("runbook")` and `rollout_plan`. No exploit steps while diagnosing.
