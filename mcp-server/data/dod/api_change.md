# Definition of Done: API Change

An API change is **Done** when clients can implement or migrate from a written contract and compatibility is honest. Pair with `api_design` / `api_contract` and skill `sdlc-api-designer`.

## Required

- [ ] **Contract updated** — OpenAPI/proto/schema in repo *or* a completed `api_contract` checked in where the project keeps contracts
- [ ] **Compatibility labeled** — additive vs breaking; breaking has version, flag, or dual-run as the repo practices
- [ ] **Error model** — documented statuses; no new undocumented 200-with-error unless that is already the house style
- [ ] **Authn/z** — every new operation states scheme and permission; negative tests for forbidden access
- [ ] **Idempotency** — stated for writes; keys or natural keys tested if claimed
- [ ] **Validation** — bad input covered; size limits if the surface accepts bulk data
- [ ] **Examples** — synthetic, no secrets or personal data
- [ ] **Provider/consumer tests** — at least one contract or integration test for the new/changed operation
- [ ] **Changelog / release notes** — breaking and required client action called out
- [ ] **Layer/Domain** — API and domain consultants not violated

## Not done if

- "See the handler" is the documentation
- Field meaning changed in place without a rename or version
- Public endpoint shipped without `security change` review

## Agent notes

`get_definition_of_done("api change")`. Fetch `api design` and `api contract`. For public or trust-boundary APIs also fetch `security change`.
