# Fixture lifecycle pipeline

## Pipeline graph

```mermaid
flowchart TD
    HOME_PIPELINE_NODE[HOME_PIPELINE_MARK]
    HOME_PIPELINE_NODE --> NEXT[next-legal-step]
    Threat[sdlc-threat-modeler]
    Sec[sdlc-security-reviewer]
    Triage[sdlc-bug-triager]
    PRSum[sdlc-pr-summarizer]
    HOME_PIPELINE_NODE --> Threat
    HOME_PIPELINE_NODE --> Sec
    HOME_PIPELINE_NODE --> Triage
    HOME_PIPELINE_NODE --> PRSum
```

Other template prose should not become a second diagram source of truth.
