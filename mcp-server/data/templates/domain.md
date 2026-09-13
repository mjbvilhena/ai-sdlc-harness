# {Domain Name} Domain

This file is a **Domain Consultant** payload. The MCP tool `get_domain_consultant` discovers it as `DOMAIN.md` under a domain directory. Other skills treat MUST/NEVER as hard constraints. Write for agents: short, testable, unambiguous.

**Quality bar:** An agent can decide whether a change belongs in this domain, which entities it may touch, and which integrations are forbidden — without reading application code.

Place at the domain root, e.g. `src/domains/billing/DOMAIN.md`. One bounded context per file.

## Bounded context

- **Owns:** capabilities and data this domain is the source of truth for
- **Does not own:** neighboring contexts (name them) and what to call instead
- **Published language:** terms other domains may use; note synonyms that are *not* allowed
- **Actors:** roles that may trigger behavior here (no invented personas)

## Core entities and invariants

| Entity | Meaning | Invariants (always true) |
|---|---|---|
| EntityA | … | … |

Include only entities this context persists or authoritatively computes. Identity, lifecycle, and uniqueness rules belong here.

## Ubiquitous language

- Preferred term → meaning
- Banned aliases (e.g. never call a Ledger Entry an "Invoice")

## Integrations and boundaries

- **Inbound:** who may call this domain and through which interface
- **Outbound:** systems this domain may call; data it may emit
- **Anti-corruption:** how foreign models are translated (or refused)

## MUST rules

Business rules that are always in force. Each line is a single, testable obligation.

- MUST …
- MUST …

## NEVER rules

Hard prohibitions. Prefer these over soft "avoid".

- NEVER persist secrets or raw payment credentials in this domain
- NEVER call {other domain} internals; use its published API
- NEVER …

## Error and compliance posture

- Failure modes the domain must surface (typed errors, not generic 500s)
- Audit events that must be emitted (names only; no PII in examples)
- Retention or residency constraints *only if the user/repo stated them*

## Change control

- What requires an ADR vs a normal story
- Who (role) may expand the published language

## Anti-patterns

- Vague owns/does-not-own that overlap another DOMAIN.md
- MUST rules that are technical layer concerns (those belong in `LAYER.md`)
- Invented regulatory claims or certifications
- Empty NEVER lists on a domain that handles money, identity, or personal data
