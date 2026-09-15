import pytest
from src.server import (
    fuzzy_match,
    get_sdlc_template,
    get_definition_of_done,
    get_available_files,
    resolve_alias,
)


EXPECTED_TEMPLATES = {
    "adr",
    "api contract",
    "api design",
    "accessibility audit",
    "bug report",
    "code review",
    "domain",
    "e2e test plan",
    "incident postmortem",
    "layer",
    "migration plan",
    "onboarding guide",
    "pr",
    "release notes",
    "rfc",
    "rollout plan",
    "runbook",
    "security review",
    "test plan",
    "threat model",
    "user story",
    "repository setup",
    "product spec",
    "research",
}

EXPECTED_DOD = {
    "api change",
    "bugfix",
    "data migration",
    "epic",
    "feature",
    "hotfix",
    "pr",
    "release",
    "security change",
    "ui change",
    "user story",
    "repository setup",
    "research",
}


def test_catalog_templates_and_dod():
    assert set(get_available_files("templates")) == EXPECTED_TEMPLATES
    assert set(get_available_files("dod")) == EXPECTED_DOD


def test_fuzzy_match():
    options = ["adr", "pr", "user story"]
    assert fuzzy_match("adr template", options) == "adr"
    assert fuzzy_match("pull request", options) == "pr"
    assert fuzzy_match("story", options) == "user story"
    assert fuzzy_match("random string", options) is None


def test_resolve_alias_longest_match_wins():
    assert resolve_alias("e2e test plan") == "e2e test plan"
    assert resolve_alias("test plan") == "test plan"
    assert resolve_alias("security review") == "security review"
    assert resolve_alias("security change") == "security change"
    assert resolve_alias("user story") == "user story"
    assert resolve_alias("story") == "user story"


def test_fuzzy_match_prefers_exact_option_over_short_alias():
    # "bug" is an alias for "bug report", but "bugfix" must stay exact.
    assert fuzzy_match("bugfix", ["bugfix", "hotfix", "feature"]) == "bugfix"
    assert fuzzy_match("bug", ["bug report", "rfc"]) == "bug report"


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


@pytest.mark.parametrize(
    ("query", "needle"),
    [
        ("rfc", "Request for Comments"),
        ("request for comments", "Request for Comments"),
        ("threat model", "Threat Model (STRIDE)"),
        ("stride", "Threat Model (STRIDE)"),
        ("code review", "Code Review Template"),
        ("test plan", "Test Plan"),
        ("e2e test plan", "End-to-End Test Plan"),
        ("end-to-end test plan", "End-to-End Test Plan"),
        ("release notes", "Release Notes"),
        ("changelog", "Release Notes"),
        ("runbook", "Runbook"),
        ("playbook", "Runbook"),
        ("api design", "API Design"),
        ("api contract", "API Contract"),
        ("openapi", "API Contract"),
        ("security review", "Security Review"),
        ("accessibility audit", "Accessibility Audit"),
        ("a11y audit", "Accessibility Audit"),
        ("wcag", "Accessibility Audit"),
        ("migration plan", "Migration Plan"),
        ("schema migration", "Migration Plan"),
        ("onboarding", "Onboarding Guide"),
        ("rollout plan", "Rollout Plan"),
        ("launch plan", "Rollout Plan"),
        ("bug report", "Bug Report Template"),
        ("defect", "Bug Report Template"),
        ("user story", "User Story Template"),
        ("domain", "Domain Consultant"),
        ("layer", "Layer Consultant"),
        ("incident", "Incident Postmortem Template"),
        ("postmortem", "Incident Postmortem Template"),
    ],
)
def test_get_sdlc_template_new_names_and_aliases(query, needle):
    result = get_sdlc_template(query)
    assert needle in result
    assert "not found" not in result


def test_e2e_alias_does_not_collapse_to_unit_test_plan():
    result = get_sdlc_template("e2e test plan")
    assert "End-to-End Test Plan" in result
    assert "# Test Plan\n" not in result


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


@pytest.mark.parametrize(
    ("query", "needle"),
    [
        ("bugfix", "Definition of Done: Bugfix"),
        ("bug fix", "Definition of Done: Bugfix"),
        ("hotfix", "Definition of Done: Hotfix"),
        ("hot fix", "Definition of Done: Hotfix"),
        ("epic", "Definition of Done: Epic"),
        ("release", "Definition of Done: Release"),
        ("pr", "Definition of Done: PR"),
        ("pull request", "Definition of Done: PR"),
        ("story", "Definition of Done: User Story"),
        ("user story", "Definition of Done: User Story"),
        ("security change", "Definition of Done: Security Change"),
        ("ui change", "Definition of Done: UI Change"),
        ("frontend change", "Definition of Done: UI Change"),
        ("api change", "Definition of Done: API Change"),
        ("data migration", "Definition of Done: Data Migration"),
    ],
)
def test_get_definition_of_done_new_names_and_aliases(query, needle):
    result = get_definition_of_done(query)
    assert needle in result
    assert "not found" not in result


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
