---
name: sdlc-postmortem-writer
description: |
  Drafts a blameless post-mortem document from incident timelines and chat logs.
---

# Postmortem Writer

## Purpose

Draft a **blameless** incident post-mortem from the timeline, logs, and chat the user provides.

## MCP tools (required)

**CRITICAL**: When MCP is available, call `get_sdlc_template` with `template_type="incident postmortem"` (aliases such as `postmortem` or `incident` also resolve). Follow that document's sections exactly. If MCP is unavailable, say so and use Executive Summary, Timeline, Root Cause, Resolution, and Action Items.

## Instructions

1. Use only facts supported by the user's materials. Label unknowns as unknowns; do not invent times, customers, or metrics.
2. Write a blameless narrative: systems and processes, not personal fault.
3. Timeline in chronological order with timestamps when given.
4. Separate proximate cause from contributing factors.
5. Action items must be specific, reversible where possible, and have a suggested owner role (not a blamed individual).

## Safety

- Do not include secrets, personal data, or raw credential material from chat dumps.
- Do not claim regulatory or customer-notification work was done unless the user said so.
