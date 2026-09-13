# Bug Report Template

Use this when a defect must be diagnosable by someone who cannot reproduce it from a chat snippet. Pair with Definition of Done `bugfix` before calling the fix done.

**Quality bar:** A new engineer can reproduce (or explain why they cannot), isolate the suspected surface, and write a failing test from this report alone.

## Title

`<surface>: <failure in user terms>` — e.g. `Checkout: tax omitted when shipping address differs from billing`.

## Summary

2–4 sentences: what broke, who is affected, and how bad it is. No root-cause speculation here.

## Severity and priority

| Field | Value |
|---|---|
| Severity | `S1` blocker / `S2` major / `S3` minor / `S4` polish |
| User impact | Who, how many if known, workaround |
| Detected in | env / version / commit / release channel |
| First seen | date or deploy id (unknown is allowed) |

## Steps to reproduce

Numbered, starting from a clean, stated state. One action per step. Last step is the failure.

1. …
2. …
3. Observe …

If not reproducible: what was tried, how often it fails, and any correlation (region, account type, time).

## Expected behavior

Observable outcome the product already promised (docs, AC, prior release). Do not invent new requirements.

## Actual behavior

What happened instead: UI text, status codes, logs *without secrets*, screenshots described in words.

## Environment

- App version / git SHA / feature flags
- OS, browser or runtime, device class
- Tenant / plan / locale / timezone if relevant
- Data shape (anonymized): e.g. "cart with 0-tax line item"

## Evidence

- Log pointers (service, timestamp, request id) — redact tokens
- Related tickets, dashboards, failing tests
- Suspected component (domain/layer) marked `hypothesis` unless proven

## Scope and regression risk

- Known good: last version/path that worked
- Nearby features that may share the code path
- Data that must not be mutated while investigating

## Anti-patterns

- "Doesn't work" with no surface, steps, or expected result
- Pasting secrets, session cookies, or personal data
- Declaring root cause in the report before a fix investigation
- Mixing several unrelated failures in one ticket
