# Accessibility Audit

Assistive review against a **WCAG 2.2 Level AA** checklist for in-scope UI. Pair with rule `sdlc-a11y-auditor` and DoD `ui change`. This is not a certification and not a legal opinion.

**Quality bar:** Each issue names a component, the barrier, and a concrete remediation. Note when a check needs a browser, screen reader, or measured contrast. Do not claim the product "meets WCAG" or is "AA certified".

## Metadata

| Field | Value |
|---|---|
| Scope | routes / components / diff |
| Layer consultant | `ui` / `frontend` / name listed by MCP |
| User-supplied designs | yes/no (do not invent visual specs) |

## Summary

Counts by severity and whether blockers are keyboard, name, or contrast. Residual risk: untested assistive tech.

## Findings

| ID | Sev | Component | Barrier | Remediation | Needs runtime check? |
|---|---|---|---|---|---|
| A-1 | … | … | … | … | yes/no |

Severity: `Blocker` (cannot complete a task) | `Should fix` | `Nit`.

## Checklist (in-scope files only)

- [ ] **Names and labels** — controls have accessible names; inputs have associated labels
- [ ] **Images and media** — meaningful `alt` or empty `alt` if decorative; captions/transcripts when media is in scope
- [ ] **Keyboard** — no trap; logical order; custom widgets reachable and operable
- [ ] **Focus visibility** — focus not removed without an equivalent
- [ ] **Color and contrast** — not color-only; likely contrast issues flagged (do not invent ratios unless measured)
- [ ] **Structure** — headings, landmarks, lists — not div soup for semantics
- [ ] **ARIA** — native first; ARIA valid and non-contradictory
- [ ] **Errors** — exposed to assistive tech and tied to fields
- [ ] **Motion** — new motion can be reduced if the change introduces it
- [ ] **Target size / zoom** — obvious collisions or clipped text at 200% if inspected
- [ ] **Name, role, value** — custom controls expose state (expanded, selected, invalid)

## What was not tested

Screen readers, speech, real devices, design-token contrast math — list honestly.

## Anti-patterns

- Conformance or legal-compliance claims
- "Add ARIA everywhere" on native elements
- Invented contrast ratios
- Marketing language ("fully accessible")
- Reviewing files not in scope
