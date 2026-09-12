import os
from pathlib import Path
from mcp.server.mcpserver import MCPServer
from thefuzz import process

# Initialize MCPServer server
mcp = MCPServer("SDLC Knowledge Base")

DATA_DIR = Path(os.path.dirname(os.path.dirname(__file__))) / "data"

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

if __name__ == "__main__":
    mcp.run()
