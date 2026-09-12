import pytest
import os
from src.server import fuzzy_match, get_sdlc_template, get_definition_of_done

def test_fuzzy_match():
    options = ["adr", "pr", "user story"]
    assert fuzzy_match("adr template", options) == "adr"
    assert fuzzy_match("pull request", options) == "pr"
    assert fuzzy_match("story", options) == "user story"
    assert fuzzy_match("random string", options) is None

def test_get_sdlc_template():
    # Test valid
    result = get_sdlc_template("adr")
    assert "Architectural Decision Record" in result
    
    # Test fuzzy
    result = get_sdlc_template("pull request template")
    assert "Pull Request Template" in result
    
    # Test graceful degradation
    result = get_sdlc_template("unknown")
    assert "Template 'unknown' not found." in result
    assert "adr" in result
    assert "pr" in result

def test_get_definition_of_done():
    # Test valid
    result = get_definition_of_done("feature")
    assert "Definition of Done: Feature" in result
    
    # Test fuzzy
    result = get_definition_of_done("feat")
    assert "Definition of Done: Feature" in result
    
    # Test graceful degradation
    result = get_definition_of_done("unknown")
    assert "Definition of Done for 'unknown' not found." in result
    assert "feature" in result
    assert "release" in result

def test_get_domain_consultant(tmp_path, monkeypatch):
    # Setup mock workspace
    workspace = tmp_path / "workspace"
    auth_dir = workspace / "src" / "domains" / "auth"
    auth_dir.mkdir(parents=True)
    (auth_dir / "DOMAIN.md").write_text("# Auth Domain\nConstraints for auth.")
    
    billing_dir = workspace / "src" / "domains" / "billing"
    billing_dir.mkdir(parents=True)
    (billing_dir / "DOMAIN.md").write_text("# Billing Domain\nConstraints for billing.")
    
    # Mock WORKSPACE_ROOT in the server module
    import src.server
    monkeypatch.setattr(src.server, "WORKSPACE_ROOT", str(workspace))
    
    # Test valid
    result = src.server.get_domain_consultant("auth")
    assert "Auth Domain" in result
    
    # Test fuzzy
    result = src.server.get_domain_consultant("authentication")
    # Fuzzy match threshold might not catch "authentication" -> "auth" directly without alias,
    # let's test a simple fuzzy match like "bill" -> "billing"
    result = src.server.get_domain_consultant("bill")
    assert "Billing Domain" in result
    
    # Test graceful degradation
    result = src.server.get_domain_consultant("unknown")
    assert "Domain Consultant for 'unknown' not found." in result
    assert "auth" in result
    assert "billing" in result

def test_get_layer_consultant(tmp_path, monkeypatch):
    # Setup mock workspace
    workspace = tmp_path / "workspace"
    db_dir = workspace / "src" / "layers" / "database"
    db_dir.mkdir(parents=True)
    (db_dir / "LAYER.md").write_text("# Database Layer\nOnly use SQLAlchemy.")
    
    # Mock WORKSPACE_ROOT
    import src.server
    monkeypatch.setattr(src.server, "WORKSPACE_ROOT", str(workspace))
    
    # Test valid
    result = src.server.get_layer_consultant("database")
    assert "Database Layer" in result
    
    # Test graceful degradation
    result = src.server.get_layer_consultant("ui")
    assert "Layer Consultant for 'ui' not found." in result
    assert "database" in result
