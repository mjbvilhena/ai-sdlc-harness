# Definition of Done: Bugfix

A bugfix is **Done** when the failure is gone for the reported case, cannot silently return, and a reviewer can see why. Use with template `bug_report` and skill `sdlc-bug-triager`.

## Required

- [ ] **Reproduced or tightly characterized** — steps or a failing test match the report; if intermittent, the characterization is in the ticket (env, rate, correlation), not "works on my machine"
- [ ] **Root cause identified** — proximate cause in code/config/data, written in the PR; speculation labeled `hypothesis`
- [ ] **Fix is scoped** — no unrelated refactors; blast radius stated
- [ ] **Regression test** — an automated test that failed on the old behavior and passes now (unit/integration preferred; E2E only if that is the only honest layer)
- [ ] **Unhappy neighbors** — if the bug was a missing validation or authz path, that path is tested
- [ ] **Reviewed** — at least one human review; Domain/Layer MUST/NEVER still hold
- [ ] **CI green** on the merge revision
- [ ] **Observability** — if the bug escaped because a signal was missing, a log/metric/assertion is added *or* an explicit follow-up ticket exists
- [ ] **No secrets** introduced or left in the diff

## Not done if

- The PR "fixes" symptoms by catching-all exceptions
- The report's actual behavior still occurs on the stated steps
- Tests were deleted or weakened to go green
- Product claims or root causes are invented without evidence

## Agent notes

Fetch this DoD via `get_definition_of_done` (`bugfix`, `bug fix`). Fetch `bug_report` when triaging. Prefer `get_domain_consultant` / `get_layer_consultant` for the suspected surface.
