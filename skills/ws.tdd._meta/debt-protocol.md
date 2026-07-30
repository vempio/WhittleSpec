# WhittleSpec Reference: Technical Debt Protocol

Every workaround visible and traceable, and the marker/test pair that makes it so.
Extracted from the TDD spine because four skills audit debt and only one of them is a
TDD phase skill -- `ws.review`, `ws.sweep` and `ws.fix` needed this procedure and were
loading the whole spine to reach it. Which skills load this is recorded in
`ws._meta/SKILL.md` § Procedure routing.

## Technical Debt Protocol

Every workaround **visible and traceable** -- pending test describing intended behavior + clear removal path. **Signal word:** `FIXME: [DEBT]` (never bare `TODO` or plain `FIXME`). Find all:
```bash
grep -rn "FIXME: \[DEBT\]" .
```

### At Workaround Site

```
FIXME: [DEBT] <one-line description>
Debt scenario: <path/to/test>:<line> (@debt)
Re-enable when: <concrete, verifiable condition>
```

### Paired `@debt` Test

Write `@debt`-tagged test **in same commit** as workaround. Must include:

```
Background: <what was disabled>
Reason: <root cause>
Effects: <what impaired>
Re-enable when: <concrete condition>
Code reference: <path/to/source> (FIXME: [DEBT])
```

Framework-specific syntax below. Register custom markers where needed.

<details>
<summary>BDD (pytest-bdd / behave / Cucumber)</summary>

```gherkin
# @debt - Technical Debt
# Background: <what was disabled or worked around>
# Reason: <root cause>
# Effects: <what's impaired>
# Re-enable when: <condition>
# Code reference: <path/to/source> (FIXME: [DEBT])
@debt
Scenario: <intended behaviour once debt is resolved>
  Given ...
  When ...
  Then ...
```
</details>

<details>
<summary>C++ (Catch2)</summary>

```cpp
// Technical Debt:
// Background: <what was disabled>
// Reason: <root cause>
// Effects: <what's impaired>
// Re-enable when: <condition>
// Code reference: <path/to/source> (FIXME: [DEBT])
TEST_CASE("Intended behaviour once debt resolved", "[debt]") {
    SKIP("DEBT: re-enable when ...");
}
```
</details>

<details>
<summary>Python (pytest)</summary>

```python
# Technical Debt:
# Background: <what was disabled>
# Reason: <root cause>
# Effects: <what's impaired>
# Re-enable when: <condition>
# Code reference: <path/to/source> (FIXME: [DEBT])
@pytest.mark.debt
def test_intended_behaviour_once_resolved():
    pytest.skip("DEBT: re-enable when ...")
```
</details>

### Debt Audit

```bash
grep -rn "FIXME: \[DEBT\]" .             # all code-level markers
pytest -m debt --collect-only -k bdd      # pytest-bdd debt scenarios
behave --tags @debt --dry-run             # behave debt scenarios
pytest -m debt --collect-only             # pytest debt tests
./test_executable "[debt]"                # Catch2 debt tests
```

### Non-Trivial Debt

Requires meaningful work -> create task linking `@debt` scenario and `FIXME: [DEBT]` location. Done = scenario passes, markers deleted. **Invariant**: Never commit `FIXME: [DEBT]` without `@debt` test in same commit. Marker without test = invisible debt. Test without `Code reference` = orphan. Both = process violations.

