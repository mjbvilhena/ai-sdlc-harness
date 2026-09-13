# Pull Request Template

Use this to describe a change that is ready for human review. Pair with Definition of Done `pr` and skill `sdlc-pr-summarizer`.

**Quality bar:** A reviewer can decide merge/hold from this text plus the diff — without a hallway conversation. Claims match the diff. No invented product capabilities.

## Title

Conventional, imperative: `type(scope): summary` (feat, fix, docs, refactor, test, chore). One change-intent per PR.

## Summary

- **Why** this change exists (user/problem, incident, debt) — 2–4 sentences
- **What** changed in product or engineering terms
- **Why this design** if a non-obvious approach was taken (link ADR/RFC)

## Related work

- Fixes #…
- Relates to RFC / ADR / story ids
- Follow-ups explicitly *not* in this PR

## Change type

Mark all that apply:

- [ ] Feature
- [ ] Bugfix
- [ ] Hotfix / incident mitigation
- [ ] API change (additive / breaking — say which)
- [ ] Data migration
- [ ] Security or privacy-sensitive
- [ ] UI / accessibility-sensitive
- [ ] Docs / chores only

## Testing

How a reviewer or CI proves it:

- [ ] Automated tests added or updated (name the suites)
- [ ] Manual checks performed (env, account type, steps)
- [ ] Unhappy paths exercised when the change touches them
- [ ] Feature flag / migration / rollback notes if relevant

## Reviewer guide

- Files or flows to read first
- Known limitations and residual risk
- Screenshots described in words if UI changed (no need to invent images)

## Risk and rollout

- Blast radius (tenants, endpoints, jobs)
- Rollout / flag default
- Rollback: revert-safe? migration reversible? cache/session impact?

## Checklist

- [ ] Diff matches the summary (no drive-by refactors unless explained)
- [ ] Domain and Layer MUST/NEVER still hold (fetch consultants if MCP is available)
- [ ] No secrets, credentials, or personal data in the diff
- [ ] Docs / runbooks / OpenAPI updated when the contract or ops path changed
- [ ] Self-reviewed as if you did not write it

## Anti-patterns

- "Fixed stuff" / empty summary
- Listing files instead of intent
- Claiming tests or docs were updated when the diff says otherwise
- Mixing unrelated features to dodge a second review
