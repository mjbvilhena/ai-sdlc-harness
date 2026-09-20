# Code Review Template

Structured review of a diff. Pair with skill `sdlc-code-reviewer` and Definition of Done `pr` plus the change-type DoD (`feature`, `bugfix`, `api change`, …). If the PR description is missing or too thin, run `sdlc-pr-summarizer` first (packaging before or with this review). For a security-sensitive change, also use `sdlc-security-reviewer`.

**Quality bar:** Every issue is grounded in the diff or fetched Domain/Layer/DoD rules. Suggestions are concrete. Verdict is merge, comment, or request-changes — not "LGTM" when secrets or blocking DoD gaps remain.

## Metadata

| Field | Value |
|---|---|
| Scope | PR / branch / `git diff` range |
| Reviewer stance | first pass / re-review |
| DoD used | component name fetched |
| Consultants used | domain/layer names or "MCP unavailable" |

## Summary

2–5 sentences: what the change intends, whether the diff matches that intent, overall risk.

## Verdict

One of: `Approve` | `Comment` | `Request changes`.

Blocking issues must be listed before nits.

## Findings

Severity: `Blocker` | `Should fix` | `Nit` | `Question`.

| Sev | File:line or flow | Issue | Why it matters | Suggested fix |
|---|---|---|---|---|
| … | … | … | … | … |

Group by theme if helpful: correctness, security (defensive), performance, maintainability, tests, docs, Domain/Layer/DoD.

## Checklist

- [ ] Intent vs diff: no unexplained drive-bys
- [ ] Correctness: edge cases and error paths in the changed code
- [ ] Security: injection, XSS, authz, secrets **locations only** — no exploit steps
- [ ] Performance: obvious N+1, unbounded loops, missing pagination/timeouts
- [ ] Tests: added/updated where behavior changed; no tests that lock in a bug
- [ ] API / UI / data contracts updated when the change is user- or client-visible
- [ ] Domain MUST/NEVER and Layer MUST/NEVER hold
- [ ] DoD criteria for this change type are met or explicitly waived by a human

## Residual questions

What the author must answer before merge. Do not invent missing product requirements.

## Anti-patterns

- Style-only reviews that ignore correctness
- Invented bugs not supported by the diff
- Exploit payloads or attack reproduction
- Approve despite hardcoded secrets
- Rewriting the author's design without saying why the current one fails
