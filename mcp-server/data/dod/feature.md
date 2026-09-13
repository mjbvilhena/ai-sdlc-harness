# Definition of Done: Feature

A feature is **Done** when the acceptance criteria are true in the target environment, not when the branch exists. Pair with `user_story` and, if user-facing, `ui_change` or `api_change`.

## Required

- [ ] **Acceptance criteria met** — every `Must` scenario on the story is demonstrably true (test or recorded manual check)
- [ ] **Scope honest** — no silent extra features; Nice-to-haves are split or explicitly dropped
- [ ] **Tests** — unit and/or integration tests for new behavior and one meaningful failure path; match the repo's frameworks
- [ ] **Reviewed** — human review against Domain/Layer consultants
- [ ] **Docs** — user-facing or API docs updated when behavior is visible; internal notes if the change is operator-facing
- [ ] **CI/CD** — pipeline green; merge revision is the tested revision
- [ ] **Flag default** — if gated, default is documented and safe for the current rollout stage
- [ ] **A11y for UI** — in-scope WCAG 2.2 AA checklist run (see `accessibility_audit`); no conformance claim
- [ ] **No secrets** or personal data in repo artifacts

## Coverage note

Do not treat a single coverage percentage as Done. Prefer risk-based tests from `test_plan`. If the project publishes a coverage floor, meet it *and* the risk list.

## Not done if

- AC were rewritten after implementation to match the code without product agreement
- "Works on my machine" is the only evidence
- Breaking API changes shipped without `api change` DoD

## Agent notes

`get_definition_of_done("feature")` or fuzzy `feat`. Also fetch the story template and the matching change-type DoD (`ui change`, `api change`, `security change`).
