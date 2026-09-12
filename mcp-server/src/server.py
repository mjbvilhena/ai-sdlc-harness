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

ALIASES = {
    "pull request": "pr",
    "pull requests": "pr",
    "pull request template": "pr",
    "stories": "user story",
    "stories template": "user story",
    "story": "user story",
    "bug": "bug report",
    "issue": "bug report",
    "postmortem": "incident postmortem",
    "incident": "incident postmortem",
    "request for comments": "rfc",
    "request for comment": "rfc",
    "bug fix": "bugfix",
    "hot fix": "hotfix",
    "domain template": "domain",
    "layer template": "layer",
}

def fuzzy_match(query: str, options: list[str]) -> str | None:
    """Finds the best match for the query in the options list."""
    if not options:
        return None
        
    query_lower = query.lower().strip()
    
    # Try exact alias match first
    for alias, canonical in ALIASES.items():
        if alias in query_lower:
            query_lower = canonical
            break
            
    if query_lower in options:
        return query_lower
    
    best_match, score = process.extractOne(query_lower, options)
    if score >= 70:  # Restore threshold
        return best_match
    return None

@mcp.tool()
def get_sdlc_template(template_type: str) -> str:
    """
    Retrieve a standard SDLC template (e.g., 'ADR', 'PR', 'User Story').
    
    Args:
        template_type: The type of template you are looking for.
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
        component: The component (e.g., 'frontend', 'backend', 'feature').
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
