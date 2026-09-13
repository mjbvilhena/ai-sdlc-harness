## Purpose

Perform a high-level STRIDE security review of proposed design or code changes. This is a structured threat-modeling aid, not a penetration test and not a security certification.

## MCP tools (required)

Before listing findings, query the SDLC Knowledge MCP server when it is available:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="threat model"` (alias `stride` also resolve). Follow that document's sections, finding table, and quality bar.
2. Call `get_definition_of_done` with `component="security change"` and note Done gaps. For a dedicated control checklist use `sdlc-security-reviewer` / `security review` — this skill stays on STRIDE.
3. Call `get_domain_consultant` for each business domain touched by the change (for example `auth`, `billing`). Use whatever domains you can infer from paths or the user; if a lookup fails, read the tool's list of available domains and retry only those that exist.
4. Call `get_layer_consultant` for each architectural layer touched (for example `ui`, `api`, `database`). Same retry rule as above.

Apply retrieved Domain and Layer constraints when judging impact. If MCP is unavailable, say so and continue from the repo and the user's description only. Do not invent Domain/Layer rules that were not retrieved or present in the workspace.

## Instructions

1. Identify the change under review (diff, design note, or user description). Do not invent architecture that is not in evidence.
2. Walk each STRIDE category that is relevant to the change:
   - **Spoofing** — identity and authentication assumptions
   - **Tampering** — integrity of data or control flow
   - **Repudiation** — auditability of sensitive actions
   - **Information Disclosure** — confidentiality of secrets and personal data
   - **Denial of Service** — resource exhaustion or availability
   - **Elevation of Privilege** — authorization boundaries
3. For each finding, record: category, asset/component, evidence (file, flow, or assumption), likely impact, and a **defensive** mitigation. Mark each item as **observed** (supported by the change) or **hypothesis** (needs confirmation).
4. Call out missing controls (authn/z, validation, logging, encryption in transit/at rest) only when the change actually involves that surface.

## Safety

- Do not write exploit payloads, proof-of-concept attacks, or step-by-step abuse procedures.
- Do not claim the product is "secure", "STRIDE-compliant", or certified.
- Do not invent CVEs, product security features, or threats that have no basis in the change.
- If you find secrets or credentials in the diff, report the location and recommend rotation — do not repeat the secret value.
