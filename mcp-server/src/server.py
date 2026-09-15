import os
from pathlib import Path
from mcp.server.mcpserver import MCPServer
from thefuzz import process

# Initialize MCPServer server
mcp = MCPServer("SDLC Knowledge Base")

DATA_DIR = Path(os.path.dirname(os.path.dirname(__file__))) / "data"
WORKSPACE_ROOT = Path(os.getenv("WORKSPACE_ROOT", os.getcwd()))

def get_available_files(directory: str) -> dict[str, str]:
    """Returns a dictionary mapping logical names to file paths."""
    dir_path = DATA_DIR / directory
    if not dir_path.exists():
        return {}
    
    files = {}
    for f in dir_path.iterdir():
        if f.is_file() and f.suffix == '.md':
            logical_name = f.stem.replace('-', ' ').replace('_', ' ')
            files[logical_name] = str(f)
    return files

# Longer aliases win when several match as substrings (see resolve_alias).
# Canonical values are logical names: stem with '-' and '_' turned into spaces.
ALIASES = {
    # Existing templates
    "architectural decision record": "adr",
    "architecture decision record": "adr",
    "architecture decision": "adr",
    "decision record": "adr",
    "pull request template": "pr",
    "pull requests": "pr",
    "pull request": "pr",
    "stories template": "user story",
    "user stories": "user story",
    "user story": "user story",
    "stories": "user story",
    "story": "user story",
    "bug report": "bug report",
    "bug ticket": "bug report",
    "defect": "bug report",
    "bug": "bug report",
    "issue": "bug report",
    "incident postmortem": "incident postmortem",
    "incident post-mortem": "incident postmortem",
    "post mortem": "incident postmortem",
    "post-mortem": "incident postmortem",
    "postmortem": "incident postmortem",
    "incident": "incident postmortem",
    "request for comments": "rfc",
    "request for comment": "rfc",
    "domain template": "domain",
    "domain consultant": "domain",
    "layer template": "layer",
    "layer consultant": "layer",
    # New templates
    "threat model": "threat model",
    "stride": "threat model",
    "code review": "code review",
    "review checklist": "code review",
    "e2e test plan": "e2e test plan",
    "end to end test plan": "e2e test plan",
    "end-to-end test plan": "e2e test plan",
    "e2e plan": "e2e test plan",
    "test plan": "test plan",
    "qa plan": "test plan",
    "release notes": "release notes",
    "changelog": "release notes",
    "run book": "runbook",
    "ops runbook": "runbook",
    "playbook": "runbook",
    "api contract": "api contract",
    "openapi": "api contract",
    "api spec": "api contract",
    "api design": "api design",
    "rest design": "api design",
    "security review": "security review",
    "sec review": "security review",
    "accessibility audit": "accessibility audit",
    "a11y audit": "accessibility audit",
    "wcag": "accessibility audit",
    "migration plan": "migration plan",
    "schema migration": "migration plan",
    "onboarding guide": "onboarding guide",
    "onboarding": "onboarding guide",
    "new hire": "onboarding guide",
    "rollout plan": "rollout plan",
    "launch plan": "rollout plan",
    "product spec": "product spec",
    "prd": "product spec",
    "epic": "product spec",
    "research report": "research",
    "spike": "research",
    "investigation": "research",
    # DoD (logical names share some aliases with templates; catalogs are separate)
    "bug fix": "bugfix",
    "hot fix": "hotfix",
    "security change": "security change",
    "ui change": "ui change",
    "frontend change": "ui change",
    "api change": "api change",
    "data migration": "data migration",
    "user story dod": "user story",
    "story dod": "user story",
    "pr dod": "pr",
}


def resolve_alias(query: str) -> str:
    """Map a natural-language query to a canonical logical name.

    When multiple alias phrases appear in the query, the longest alias wins
    so that e.g. 'e2e test plan' does not collapse to 'test plan'.
    """
    query_lower = query.lower().strip()
    matches = [
        (alias, canonical)
        for alias, canonical in ALIASES.items()
        if alias in query_lower
    ]
    if not matches:
        return query_lower
    _, canonical = max(matches, key=lambda pair: len(pair[0]))
    return canonical


def fuzzy_match(query: str, options: list[str]) -> str | None:
    """Finds the best match for the query in the options list."""
    if not options:
        return None

    raw = query.lower().strip()
    if raw in options:
        return raw

    query_lower = resolve_alias(query)

    if query_lower in options:
        return query_lower

    best_match, score = process.extractOne(query_lower, options)
    if score >= 70:  # Restore threshold
        return best_match
    return None

@mcp.tool()
def get_sdlc_template(template_type: str) -> str:
    """
    Retrieve a standard SDLC template (e.g., 'ADR', 'PR', 'User Story',
    'threat model', 'api design', 'runbook').

    Args:
        template_type: The type of template you are looking for. Aliases
            such as 'pull request', 'stride', or 'changelog' also resolve.
    """
    files = get_available_files("templates")
    options = list(files.keys())
    
    best_match = fuzzy_match(template_type, options)
    
    if best_match:
        try:
            with open(files[best_match], 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            return f"Error reading template: {e}"
            
    # Graceful degradation
    msg = f"Template '{template_type}' not found.\n\nAvailable templates are:\n"
    for opt in options:
        msg += f"- {opt}\n"
    msg += "\nPlease try again with one of the options above."
    return msg

@mcp.tool()
def get_definition_of_done(component: str) -> str:
    """
    Retrieve the Definition of Done (DoD) for a specific project component or phase.

    Args:
        component: The component (e.g., 'feature', 'bugfix', 'pr',
            'security change', 'api change', 'data migration').
    """
    files = get_available_files("dod")
    options = list(files.keys())
    
    best_match = fuzzy_match(component, options)
    
    if best_match:
        try:
            with open(files[best_match], 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            return f"Error reading DoD: {e}"
            
    # Graceful degradation
    msg = f"Definition of Done for '{component}' not found.\n\nAvailable components are:\n"
    for opt in options:
        msg += f"- {opt}\n"
    msg += "\nPlease try again with one of the options above."
    return msg

def scan_for_consultants(filename: str) -> dict[str, str]:
    """
    Dynamically scans the workspace for specific consultant knowledge payloads.
    Returns a dictionary mapping the parent directory name to the file path.
    """
    consultants = {}
    for root, _, files in os.walk(WORKSPACE_ROOT):
        # Ignore common hidden/build directories
        if any(ignored in root for ignored in ['.git', 'node_modules', 'venv', '__pycache__']):
            continue
        if filename in files:
            logical_name = os.path.basename(root).lower().replace('-', ' ').replace('_', ' ')
            consultants[logical_name] = os.path.join(root, filename)
    return consultants

@mcp.tool()
def get_domain_consultant(domain: str) -> str:
    """
    Retrieve the Domain Consultant payload dynamically from the workspace.
    
    Args:
        domain: The domain you need constraints or context for (e.g., 'auth', 'billing').
    """
    files = scan_for_consultants("DOMAIN.md")
    options = list(files.keys())
    
    best_match = fuzzy_match(domain, options)
    
    if best_match:
        try:
            with open(files[best_match], 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            return f"Error reading Domain Consultant: {e}"
            
    msg = f"Domain Consultant for '{domain}' not found.\n\nAvailable domains are:\n"
    for opt in options:
        msg += f"- {opt}\n"
    return msg

@mcp.tool()
def get_layer_consultant(layer: str) -> str:
    """
    Retrieve the Layer Consultant payload dynamically from the workspace.
    
    Args:
        layer: The architectural layer you need constraints for (e.g., 'database', 'ui').
    """
    files = scan_for_consultants("LAYER.md")
    options = list(files.keys())
    
    best_match = fuzzy_match(layer, options)
    
    if best_match:
        try:
            with open(files[best_match], 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            return f"Error reading Layer Consultant: {e}"
            
    msg = f"Layer Consultant for '{layer}' not found.\n\nAvailable layers are:\n"
    for opt in options:
        msg += f"- {opt}\n"
    return msg

if __name__ == "__main__":
    mcp.run()
