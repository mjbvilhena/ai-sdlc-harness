# UX Design

Structured UX artefact for skill `sdlc-ux-designer`. Pair with `get_sdlc_template("ux design")` (aliases `ux`, `wireframe`) and template `user story` so flows and copy stay aligned with story/AC language. Pair with Definition of Done `ui change` for implement/verify — that DoD is **not** permission to invent screens.

**Quality bar:** A developer can implement the named screens without inventing navigation or copy. Every flow step maps to an acceptance criterion. Anything not in the stories is `out of scope` or an open question.

This skill sits in the conductor **design & planning** band **after** story refine and **before** first implement. `sdlc-a11y-auditor` and template `accessibility audit` are **verify-time**, not a substitute for this payload.

## Metadata

| Field | Value |
|---|---|
| Slice / epic | |
| Stories / AC cited | paths actually opened |
| Related spec | |
| Status | Draft / Review / Agreed |
| Skip? | no / explicit skip recorded (e.g. no UI) |

## Evidence

- Stories and Must AC (paths)
- Product spec claims used (no invented personas or features)
- Existing UX artefact the user pointed at (if any)
- Domain / UI-layer MUST/NEVER fetched (names only)

If stories (or Must AC) are missing, **stop**. Recommend `/sdlc-user-story-refiner` (or `/sdlc-conductor`). Do not design from a vibe.

## Flows

For each journey the stories require:

| Flow | Actor | Trigger | Success path | Unhappy path (only if stories imply it) | AC mapping |
|---|---|---|---|---|---|
| … | role from the story | … | numbered steps | numbered steps or `n/a — not in stories` | story id / AC |

Do not add extra journeys (onboarding, settings, marketing) the stories did not ask for.

## Wireframes

Markdown is enough; ASCII wireframes are fine — no pixel mockup required.

One heading per **screen the stories require**. For each screen:

- Regions (header, main, aside, footer as the stories imply)
- Controls and fields
- Navigation to/from other in-scope screens
- Empty / loading / error / success **only** when the stories or Must AC name those states

Mark anything not in the stories as `out of scope` or an open question. If a control is needed to satisfy an AC but is unnamed, ask one short question — do not pick a product claim.

```
+------------------+
| [Screen name]    |
| region / control |
+------------------+
```

## Copy

Labels, empty/loading/error/success strings **only** for the screens above. No marketing slogans the product docs did not already use.

| Screen | Element | Copy | Source (story / spec / existing UI) |
|---|---|---|---|
| … | button / label / empty | … | path or quote |

## Open questions

Numbered, with the role that can answer. Do not silently resolve product choices.

## Relationship

- **Upstream:** `sdlc-user-story-refiner` (stories/AC); `sdlc-product-owner` (spec). This payload does not write those.
- **Parallel:** `sdlc-rfc-drafter` / `sdlc-api-designer` / `sdlc-adr-drafter` author technical design.
- **Front door:** `sdlc-conductor` recommends this skill for the UI/UX design state, then confirms before hand-off. Hand artefact paths back so Job B can update the design-artefact index.
- **Verify-time only:** `sdlc-a11y-auditor` (and template `accessibility audit`) run against implemented UI.

## Anti-patterns

- Invented screens, navigation, settings, or “nice to have” flows
- Invented personas, SLOs, certifications, or product claims
- WCAG / AA / legal accessibility conformance claims at design time
- Treating `sdlc-a11y-auditor` as a UX designer
- Exploit, phishing, or dark-pattern guidance
- Secrets, tokens, or real personal data in copy examples
- Merging PRs or treating green CI as design approval
