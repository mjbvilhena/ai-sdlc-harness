# Definition of Done: UI Change

A user-interface change is **Done** when the stated interaction works with keyboard and accessible names, not only a mouse-happy-path screenshot. Pair with `accessibility_audit` and rule `sdlc-a11y-auditor`.

## Required

- [ ] **Story/AC or spec matched** — visible states (empty, loading, error, success) that were in scope
- [ ] **Layer rules** — UI/frontend `LAYER.md` MUST/NEVER honored
- [ ] **Accessibility checklist** — `accessibility_audit` on in-scope components (WCAG 2.2 AA *assistive* pass; no conformance badge)
- [ ] **Keyboard** — operable without a pointer; focus order sensible; focus visible
- [ ] **Names** — controls and fields expose accessible names/labels
- [ ] **Errors** — announced and associated with fields when the change includes forms
- [ ] **No color-only** meaning in the new UI
- [ ] **Tests** — component or e2e coverage for the primary journey when the repo has that harness
- [ ] **Copy** — strings from the user/design/repo; no invented product claims
- [ ] **Motion** — new animation can be reduced if introduced

## Not done if

- Icon-only controls with no name
- Custom widgets that are mouse-only
- "Looks fine" with no keyboard pass on a new form

## Agent notes

Aliases: `ui change`, `frontend change`. Also fetch `feature` or `bugfix`. Never claim legal a11y compliance.
