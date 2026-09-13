# Security Review

Defensive review of a change that affects trust boundaries, identity, data class, or abuse surface. Complements the STRIDE `threat_model` (design-time). Pair with skill `sdlc-security-reviewer` and DoD `security change`.

**Quality bar:** Findings are evidence-based and mitigations are controls (authz, validation, limits, logging, encryption in transit). No exploit PoCs, no "certified secure" language, no invented CVEs.

## Metadata

| Field | Value |
|---|---|
| Subject | PR / RFC / service |
| Reviewer role | |
| Threat model linked | id or "none yet" |
| Consultants fetched | domain/layer names or MCP unavailable |
| Data classes in play | public / internal / personal / secrets — as evidenced |

## Change narrative

What is new or different in the trust model. Quote paths or design bullets. Do not invent architecture.

## Control review

For each control, state `present` / `missing` / `not applicable` with evidence.

| Control | Status | Evidence | Gap (defensive fix) |
|---|---|---|---|
| Authentication on new entry points | | | |
| Authorization on object/action | | | |
| Session / token handling (no tokens in logs or URLs) | | | |
| Input validation / allow-lists where the change takes input | | | |
| Output encoding / safe rendering if UI | | | |
| Sensitive data minimization | | | |
| Encryption in transit (and at rest if newly stored) | | | |
| Audit log of sensitive actions | | | |
| Rate, size, and timeout limits | | | |
| Dependency or supply-chain change (pin, known issues *if evidenced*) | | | |
| Secrets management (no new hard-coded credentials) | | | |

## Findings

| ID | Severity | Surface | Evidence | Defensive recommendation | Observed or hypothesis |
|---|---|---|---|---|---|
| S-1 | … | … | … | … | … |

Severity: `Blocker` | `Should fix` | `Info`.

## Secrets incident note

If a secret is in the diff: **path only**, recommend rotation and history purge per the project's practice. Do not repeat the secret.

## Residual risk and out of scope

What this review did not cover (pen test, formal verification, third-party SOC). Do not imply those were done.

## Verdict

`Request changes` | `Comment` | `No blocking issues found` — never "approved as secure" or "compliant".

## Anti-patterns

- Exploit payloads, fuzz strings-as-attacks, or step-by-step abuse
- Conformance, ISO, SOC2, or "bank-grade" claims
- Copy-pasting vulnerability write-ups unrelated to this change
- Ignoring Domain/Layer NEVER rules that already exist
