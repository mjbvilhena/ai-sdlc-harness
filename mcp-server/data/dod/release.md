# Definition of Done: Release

A release is **Done** when the intended artifacts are in the target environment, the audience can learn what changed, and someone is watching. Pair with `release_notes` and `rollout_plan`.

## Required

- [ ] **Contents frozen** — the release train only includes changes that already meet their own DoD
- [ ] **Notes published** — `release_notes` from the real git/PR range; breaking changes first; no invented features
- [ ] **Rollout executed** — stages in `rollout_plan` completed or an explicit hold with owner
- [ ] **Verification** — smoke / critical journeys plus existing dashboards; watch window as this team practices (if none stated, watch until error-rate and latency look like pre-release *on those dashboards*)
- [ ] **Migrations** — any `data migration` in the train is verified or rolled back
- [ ] **Flags** — defaults match the intended audience; leftover kill-switches documented
- [ ] **Support artifacts** — runbooks updated if ops changed
- [ ] **Known issues** — listed in notes if they shipped

## Not done if

- Tag exists but rollback is unknown
- Changelog is a raw `git log`
- "QA signed off" with no evidence and no named role

## Agent notes

`get_definition_of_done("release")`. Fetch `release_notes` and `rollout_plan`. Do not invent SLOs, uptime percentages, or store certifications.
