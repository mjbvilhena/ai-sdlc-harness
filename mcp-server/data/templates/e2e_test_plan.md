# End-to-End Test Plan

Plan for journey-level tests (Playwright, Cypress, or the repo's runner). Pair with skill `sdlc-test-planner` (strategy, before implement) and the `user story` template for AC shape. `sdlc-e2e-scripter` **executes** this plan at verify time.

**Quality bar:** One journey per critical user outcome. Selectors prefer role/name/label. Environments are local or explicitly documented — not production unless the user supplied that base URL.

## Metadata

| Field | Value |
|---|---|
| Journeys in scope | story ids or flows |
| Runner | Playwright / Cypress / other (match repo) |
| Base URL source | env var / local docs |
| Layer constraints | UI consultant names fetched |

## Journeys

For each journey:

### J-1: {user-visible outcome}

- **Actor** and precondition (seed data, flag, role)
- **Steps** mapped 1:1 from Given/When/Then
- **Assertions** (URL, accessible name, text, network status — no pixel-only unless necessary)
- **Unhappy sibling** (permission denied, validation, empty list) if the story has one

## Stability

- [ ] Roles/labels over brittle CSS or nth-child
- [ ] Network/wait strategy stated (no arbitrary `sleep` as the default)
- [ ] Isolation: no shared mutable user if tests run in parallel
- [ ] Seeds are idempotent or namespaced

## Data and secrets

- Fixtures or env vars for credentials — never commit real tokens
- No real personal data in traces or screenshots committed to git
- Third-party sandboxes only if the repo already uses them

## Environments

| Env | When to run | Forbidden |
|---|---|---|
| Local / CI ephemeral | default | production data |
| Shared staging | if user said so | mutating other teams' tenants without permission |

## Out of scope

Visual snapshot farms, load tests, or third-party admin consoles unless requested.

## Anti-patterns

- One giant script that clicks the whole app
- Production URLs by default
- Hard-coded session cookies
- Invented UI copy or routes not in the story or codebase
- Asserting only that a page loaded
