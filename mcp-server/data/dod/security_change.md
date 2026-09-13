# Definition of Done: Security Change

A change that alters a trust boundary, authn/z, data class, crypto-adjacent config, or audit surface is **Done** only when defensive controls are reviewed and residual risk is explicit. Pair with `security_review` and `threat_model`. Complements — does not replace — `feature` / `bugfix`.

## Required

- [ ] **Threat or security review filed** — STRIDE note and/or `security_review` against the actual diff
- [ ] **Authn/z** — new entry points enforce authentication and object/action authorization already used in this repo (no novel scheme without an ADR)
- [ ] **Data** — sensitive fields not logged, not placed in URLs, not stored beyond stated need
- [ ] **Secrets** — no new hard-coded credentials; rotations noted if a secret was exposed (location only)
- [ ] **Limits** — timeouts, size, and rate limits considered where the surface is new or public
- [ ] **Audit** — sensitive actions emit an existing or newly named event *without* secret payloads
- [ ] **Tests** — authz negative tests where a new permission path exists
- [ ] **Human review** by someone other than the sole author when the org has that practice
- [ ] **No exploit PoCs** in the PR, tickets, or docs
- [ ] **No certification claims** (SOC, ISO, "compliant", "secure")

## Not done if

- "Trust the client" is the authorization model
- Review is a checkbox with empty findings on a new public endpoint
- Threat model invented architecture not in the change

## Agent notes

`get_definition_of_done("security change")`. Fetch `security_review` and, for design-heavy work, `threat model`. Use `sdlc-security-reviewer` / `sdlc-threat-modeler`. Stay defensive.
