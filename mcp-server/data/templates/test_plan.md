# Test Plan

Plan for proving a change at unit and integration level. Pair with skill `sdlc-test-writer`. For full user journeys use `e2e_test_plan`.

**Quality bar:** Each item names the behavior, the layer, and how it fails closed. Tests match the repo's existing framework. No invented product behavior.

## Metadata

| Field | Value |
|---|---|
| Subject | story / PR / module |
| Framework | as in repo (pytest, Jest, …) — do not switch stacks |
| Related DoD | `feature`, `bugfix`, `api change`, … |

## Scope

- **In:** modules, endpoints, or functions under test
- **Out:** E2E, performance, or security lab tests unless requested
- **Oracles:** how we know pass/fail (assertions, contracts, fixtures)

## Risk-based coverage

List the behaviors that would hurt users or data if wrong. Order by risk, not by file.

| ID | Behavior | Level (unit / integration / contract) | Risk if wrong | Status |
|---|---|---|---|---|
| TP-1 | … | unit | … | planned |

Always include:

- Happy path that the story or diff claims
- At least one validation / authorization / empty-input case when those surfaces exist
- Regression case for a bugfix (reproduce, then pass)

## Fixtures and doubles

- Data builders / fixtures (anonymized; no real personal data)
- What to mock (I/O, time, randomness) vs what to use real
- Determinism: clocks, UUIDs, locale

## Unhappy paths

Table of expected errors (type or status) and the test that locks them.

## Definition of ready for this plan

- [ ] Framework and paths match the repo
- [ ] No secrets or production URLs in tests
- [ ] Bugfix plans include a test that failed on the old code (stated or shown)
- [ ] Domain/Layer constraints that affect test setup are noted

## Anti-patterns

- Tests that only assert mocks were called
- Snapshot spam that cannot fail on behavior
- Hitting production or shared mutable accounts
- Inventing APIs or return shapes not in the code
- "80% coverage" as a goal with no risk ranking
