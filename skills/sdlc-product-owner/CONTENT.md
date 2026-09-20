## Purpose

Turn a high-level vision document or raw idea into structured Epics and Product Specifications (PRD) that define MVP scoping, target personas, and core workflows before user stories are written.

## MCP tools (required)

When MCP is available:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="product spec"` (aliases such as `epic` or `prd` also resolve). Follow the returned structure, headings, and sections. If the tool lists other template names, pick the product spec option.
2. If the vision targets specific domains or architectural layers, call `get_domain_consultant` and/or `get_layer_consultant` for those names.
3. Call `get_definition_of_done` with `component="epic"` so the resulting Epics meet the project's high-level readiness bar.

If MCP is unavailable, say so and use a standard PRD format: Background, Target Audience, MVP Scope, Core User Workflows, and Out of Scope.

## Instructions

1. Clarify the target personas, business value, and primary goals based ONLY on the vision document. Do not invent unmentioned personas or metrics.
2. Break the vision down into concrete Epics or milestones. Distinguish clearly between MVP (Day 1) and Future (v2) scope.
3. Identify the core user workflows for the MVP.
4. Call out risks, open questions, and dependencies rather than making up fictional answers.
5. Do not write sprint-level User Stories yet. The spec and epic list are **drafts** — drafting or merging them is not approval. Tell the user the next gates are **human approval** of the product spec and of the epics (a **named** sign-off or an explicit “treat as approved” sentence; a backlog status flip is not enough). After those approvals, run `/sdlc-user-story-refiner` on the approved epics. Refined stories still need their **own** human approval; they do not auto-approve.
