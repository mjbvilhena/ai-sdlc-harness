# API Contract

Field-level contract for an interface consumers will generate or test against. Pair with `api_design` for why the shape exists, skill `sdlc-api-designer`, and DoD `api change`.

**Quality bar:** Request/response schemas, status codes, and compatibility rules are complete enough to write a contract test. Examples are realistic but contain **no secrets or personal data**.

## Metadata

| Field | Value |
|---|---|
| Surface | name + version |
| Spec artifact | OpenAPI / proto / JSON Schema path in repo (or "proposed") |
| Compatibility | additive / breaking vs version N |

## Endpoints

Repeat per operation.

### `METHOD /path`

- **Summary:** one sentence
- **Authn:** scheme already used in-repo
- **Authz:** permission or role
- **Idempotency:** key header / natural key / not idempotent
- **Headers:** required/optional (no API keys in examples)

#### Path/query parameters

| Name | In | Type | Required | Constraints | Notes |
|---|---|---|---|---|---|
| id | path | string | yes | … | … |

#### Request body

| Field | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| … | … | … | … | … |

#### Responses

| Status | When | Body fields |
|---|---|---|
| 200/201 | success | … |
| 400 | validation | error envelope |
| 401/403 | authn/z | … |
| 404 | missing | … |
| 409 | conflict | … |
| 429 | rate limit | retry-after if used |

**Example (synthetic):**

```json
{
  "id": "ex_123",
  "status": "active"
}
```

## Shared types and error envelope

Document once; reference from operations. Match existing repo types when present.

## Pagination and lists

Cursor vs offset, `next` token opacity, max page size, empty list shape.

## Compatibility rules

- [ ] New optional fields only, or a documented version bump
- [ ] Enum additions are treated as the repo treats them (tolerant readers?)
- [ ] Field removals / type changes listed as breaking
- [ ] Default value changes called out

## Contract tests

- Consumer or provider tests to add
- What must stay frozen in CI

## Anti-patterns

- Examples with real emails, tokens, or account numbers
- Undocumented 200-error hybrids
- "See source code" as the contract
- Changing meaning of a field without a rename or version
