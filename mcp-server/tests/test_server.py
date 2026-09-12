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
