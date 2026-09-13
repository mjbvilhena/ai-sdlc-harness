# Threat Model (STRIDE)

High-level, **defensive** threat model for a proposed design or diff. Pair with skill `sdlc-threat-modeler`. This is not a penetration test, not a certification, and not a vulnerability disclosure.

**Quality bar:** Each finding cites evidence (file, flow, or stated assumption) and a defensive mitigation. Observed vs hypothesis is labeled. No exploit payloads or abuse recipes.

## Metadata

| Field | Value |
|---|---|
| Subject | system / change / RFC id |
| Author role | |
| Inputs reviewed | diff, design, DOMAIN/LAYER names fetched |
| Residual risk accepted by | role (if any) |

## System under review

- Trust boundaries (browser, edge, app, data store, third party) *as evidenced*
- Actors and privileges
- Sensitive assets (secrets, personal data, money movement, admin actions)
- Out of scope (and why)

Do not invent architecture that is not in the repo or the user's description.

## STRIDE findings

Walk only categories that apply to this change. Skip the rest with "not applicable — {reason}".

For each finding:

| ID | Category | Asset / component | Evidence | Impact | Mitigation (defensive) | Observed or hypothesis |
|---|---|---|---|---|---|---|
| T-1 | Spoofing | … | path or flow | … | control to add or verify | observed |

Categories (use as prompts, not a score):

- **Spoofing** — identity and authentication assumptions
- **Tampering** — integrity of data, artifacts, or control flow
- **Repudiation** — whether sensitive actions are attributable
- **Information disclosure** — secrets, personal data, overly broad responses
- **Denial of service** — unbounded work, missing timeouts, single-tenant noisy neighbor
- **Elevation of privilege** — authorization gaps, confused deputy, admin bypass

## Missing controls (defensive)

Only if the change actually involves that surface:

- [ ] Authentication / session
- [ ] Authorization checks on the new path
- [ ] Input validation and output encoding as appropriate
- [ ] Encryption in transit (and at rest if the change stores sensitive data)
- [ ] Audit logging of sensitive actions (no secrets in logs)
- [ ] Rate / size limits

## Secrets handling

If credentials appear in the diff: record **location only**, recommend rotation, do not repeat values.

## Residual risk

What remains after the listed mitigations, and what is explicitly out of scope for this review.

## Anti-patterns

- Exploit PoCs, payloads, or step-by-step attack procedures
- "Secure" / "STRIDE-compliant" / certified claims
- Invented CVEs or product security features
- Findings with no evidence and no hypothesis label
