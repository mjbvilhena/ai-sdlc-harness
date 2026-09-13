---
name: sdlc-api-designer
description: |
  Designs or revises an HTTP/RPC API using the api_design and api_contract templates.
---

# Api Designer

## Purpose

Design or revise an HTTP or RPC API so a client author can implement without a meeting. Produce design rationale first, then a field-level contract. Pair with Definition of Done `api change`.

## MCP tools (required)

When MCP is available:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="api design"`. Follow that structure for the design section.
2. **CRITICAL**: Call `get_sdlc_template` with `template_type="api contract"` (aliases `openapi`, `api spec` also resolve). Fill schemas, statuses, and compatibility rules there (or merge if the user asked for one document).
3. Call `get_definition_of_done` with `component="api change"` and treat gaps as open work.
4. Call `get_domain_consultant` and `get_layer_consultant` for the owning domain and API/layer. Honor published language and forbidden dependencies.
5. If the surface is public or crosses a trust boundary, also fetch `security change` DoD and keep the design defensive.

If MCP is unavailable, say so and still separate resources/operations, error model, compatibility, and field tables.

## Instructions

1. Name consumers and the problem with the current interface (if any). Non-goals stay explicit.
2. Align style (REST/RPC/GraphQL, error envelope, pagination) with **existing** APIs in the repo. Do not invent a new house style without saying so.
3. Mark each operation's idempotency, authz, and documented errors. Breaking vs additive must be honest.
4. Examples are synthetic — no real emails, tokens, or account numbers.
5. List contract tests to add. Do not claim OpenAPI was published unless you wrote or updated the artifact.

## Safety

- Do not write exploit examples, fuzz-as-attack payloads, or bypass recipes.
- Do not invent OAuth, compliance, or product-security certifications.
- Do not silently change the meaning of an existing field.
- Do not introduce secrets in examples.
