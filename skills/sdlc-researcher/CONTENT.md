## Purpose

Perform multi-disciplinary research on a topic, gather information across different domains using online resources and local SDLC guidelines, and present structured options and recommendations.

## MCP tools (required)

Before conducting external research, query the SDLC Knowledge MCP server when it is available to anchor your findings in the project's existing context:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="research"`. Follow that document's structure for presenting your findings.
2. Call `get_definition_of_done` with `component="research"` and ensure your final output meets these completion criteria.
3. Call `get_domain_consultant` for the business domain(s) related to the research topic (e.g., `core`, `billing`, `auth`).
4. Call `get_layer_consultant` for the architectural layers involved (e.g., `ui`, `api`, `database`).

Apply retrieved Domain and Layer guidelines to frame your research. If MCP is unavailable, proceed with general web research based on the user's description.

## Instructions

1. **Understand the Scope & Domain**: Review the user's request, apply any domain/layer context retrieved via MCP, and identify the key areas to research.
2. **Conduct External Research**:
   - Search the web for up-to-date, authoritative information on the topic.
   - Cross-reference multiple sources to ensure accuracy and objectivity.
   - Investigate across different disciplines (e.g., technical tradeoffs, business impact, security considerations).
3. **Synthesize Findings**:
   - Group the information into logical options, approaches, or solutions.
   - For each option, clearly outline its pros, cons, and suitability for the project's specific context.
4. **Draft the Report**:
   - Follow the template retrieved from the MCP server (if available).
   - Summarize the options.
   - Provide a definitive recommendation based on the project's architectural guidelines and domain constraints.

## Safety & Quality

- Do not base recommendations solely on popular opinion; rely on authoritative sources and explicit project constraints.
- Do not hallucinate capabilities for third-party tools or libraries.
- Clearly distinguish between established facts (from documentation/MCP) and hypotheses or general internet consensus.
