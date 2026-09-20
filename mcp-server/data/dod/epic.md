# Definition of Done: Epic

An epic is **Done** when the outcome is in users' hands (or explicitly shelved), not when the last ticket is merely closed. Stories inside the epic use the `user story` / `feature` DoD.

## Required

- [ ] **Outcome stated** — one paragraph: who can do what now that they could not before
- [ ] **Child work complete** — all in-scope stories/tasks are Done per their own DoD, or explicitly cut with a leftover backlog item
- [ ] **No orphan flags** — temporary flags/migrations have an owner and a remove-by plan, or are already removed
- [ ] **Journey proven** — critical path covered by E2E or a documented manual journey; link the `e2e_test_plan` or test evidence
- [ ] **Contracts published** — user docs, API contract, and runbooks match shipped behavior (no invented capabilities)
- [ ] **Domain/Layer updated** — `DOMAIN.md` / `LAYER.md` changed if the epic moved a boundary
- [ ] **ADRs filed** — accepted decisions are ADRs, not only PR comments
- [ ] **Rollout finished or gated** — `rollout_plan` stages complete, or remaining rings have a named owner
- [ ] **Stakeholder acceptance** — a named **role** accepted the outcome (do not invent sign-off)

## Not done if

- Half the stories shipped a different product than the epic described and nobody updated the epic
- "Documentation later" with no ticket
- Integration only tested on a developer laptop

## Agent notes

Fetch `epic` plus `feature` / `user story` as needed. Do not mark an epic Done because CI is green on one service. **Planning-time** epic approval is a separate human gate (named sign-off or “treat as approved”; a backlog status flip is not enough) before stories; this DoD is the **shipped** outcome, not that planning gate.
