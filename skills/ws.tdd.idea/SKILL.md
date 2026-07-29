---
name: ws.tdd.idea
description: Phase 1 -- forest-level test case discovery, mapping the full problem space.
---
# ws.tdd.idea

Load shared context: `ws.tdd._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also read `ws.tdd._meta/bdd-workflow.md`, `ws.tdd._meta/visibility-patterns.md`, and `ws.tdd._meta/traceability.md`.

## Purpose

Map problem space at high altitude — WHAT needs testing, not HOW. Complete coverage before any test designed. **Forest, not trees.** Think adversarially (what could go wrong / which assumptions false / which boundaries break) but stay grounded in actual scope: a small internal tool doesn't need scaling or enterprise-security scenarios. State areas **intentionally not considered** and why.

Prereq: feature / requirement / AC / bug report / code to test; detected test framework (see `ws.tdd._meta`).

## Process

### 1. Detect Context
Identify test framework, locate existing test files. Survey current coverage to prevent duplication. **With SDD context**: Load `requirements.md` / `umbrella-requirements.md`, extract ACs -- seed idea generation but don't limit it.

### 2. BDD Inventory
Scan existing `.feature` files for related scenarios. Report: "Found N existing BDD scenarios (X implemented, Y `@todo`)." `@todo` exist: "Need `/ws.bdd.outline` -> `/ws.bdd.red` before or alongside TDD inner loop." Task spec promises "BDD green" but no matching scenarios: "WARNING: Expected BDD scenarios don't exist yet."

### 3. Decide Test Levels
Decide which levels needed (see "Test Level" in `ws.tdd._meta`): **User-observable behavior** -> BDD scenario titles + unit test ideas. **Internal plumbing** -> unit tests only. Not every feature needs BDD. When both appropriate, BDD first (outside-in), unit tests derived from implementation. **BDD implies documentation** -- feature needing BDD also needs operator docs.

### 4. Generate Ideas
**Unit test ideas** are real, framework-registered test cases marked `todo` (see "Test Visibility" in `ws.tdd._meta`): a named, skipped stub visible to the runner. This is the harness-truthfulness invariant's first checkpoint (see `ws.bdd.red` § Purpose): represent each idea as faithfully as the framework allows, in this order — framework-native `todo`/skip marking (default) > a registered-but-pending test where no native marker exists (collected by the runner, explicitly non-asserting) > a comment block in the destination test file naming the planned case, only where the framework can't register an empty case at all. Never a vacuous green — a stub that would pass by asserting nothing is worse than no stub.

<!-- WS:EXAMPLE test-visibility-syntax -->
Framework-native markers, by way of illustration: `@pytest.mark.todo` / `test.todo` / `[.][todo]` / `t.Skip` / `#[ignore]`.
<!-- /WS -->

**BDD scenario ideas are titles only, not yet framework-registered.** A `Scenario:` with an `@todo` tag in the `.feature` file has no test binding until `/ws.bdd.red` writes the step wiring — this phase's honesty ceiling for BDD is title + intent comment; registration is that later phase's job, not this one's to fake or imply parity with the unit-test stub above.

**When ACs exist**: At least one idea per AC. Most criteria need multiple tests (happy path / error cases / boundaries). Tag with AC it covers (see "Requirement Traceability" in `ws.tdd._meta`). Then look beyond ACs -- edge cases, error conditions, invariants.

```python
# pytest -- with AC traceability
@pytest.mark.todo
def test_output_mapper_throws_on_missing_file():
    """AC: R-3 (missing files must cause immediate, clear failure)"""
    pytest.skip("TODO")

@pytest.mark.todo
def test_output_mapper_parses_valid_xml():
    """AC: R-1 (valid XML produces correct output structure)"""
    pytest.skip("TODO")

@pytest.mark.todo
def test_output_mapper_rejects_malformed_xml_with_clear_error():
    """AC: R-2 (malformed input rejected with actionable error message)"""
    pytest.skip("TODO")

# Beyond ACs: edge cases and invariants
@pytest.mark.todo
def test_output_mapper_handles_empty_xml():
    pytest.skip("TODO")
```

```javascript
// Jest -- built-in todo support
test.todo("OutputMapper throws on missing file (AC: R-3, immediate clear failure)");
test.todo("OutputMapper parses valid XML correctly (AC: R-1, correct output structure)");
test.todo("OutputMapper rejects malformed XML with clear error (AC: R-2, actionable error)");
// Beyond ACs
test.todo("OutputMapper handles empty XML");
```

```cpp
// Catch2
TEST_CASE("OutputMapper throws on missing file", "[.][todo]") { SKIP("TODO (AC: R-3, immediate clear failure)"); }
TEST_CASE("OutputMapper parses valid XML correctly", "[.][todo]") { SKIP("TODO (AC: R-1, correct output structure)"); }
TEST_CASE("OutputMapper rejects malformed XML with clear error", "[.][todo]") { SKIP("TODO (AC: R-2, actionable error)"); }
// Beyond ACs
TEST_CASE("OutputMapper handles empty XML", "[.][todo]") { SKIP("TODO"); }
```

```gherkin
# BDD/Gherkin (pytest-bdd, behave, Cucumber) -- scenario titles ONLY, no steps
# CRITICAL: Do NOT write Given/When/Then steps at this phase

@config @todo
Scenario: Daemon loads config from default path when no args provided
  # AC: R-16 - verify backward compatibility without CLI args

@config @error @todo
Scenario: Daemon exits with error on missing config file
  # AC: R-17 - fail-fast principle, no silent fallback

@config @sensors @todo
Scenario: Multi-sensor config processes all configured devices
  # AC: R-16 - config-driven filtering

@config @sensors @todo
Scenario: Unknown sensors filtered at INFO level not ERROR
  # AC: R-16 - expected operational behavior, not a failure

# Beyond ACs: entry-point test
@integration @e2e @todo
Scenario: Config to monitoring to state transition end-to-end
  # Entry point: Full integration from main() through state machine
```

**For BDD:** Scenario **titles with intent comments** only -- do NOT write Given/When/Then (that's `/ws.bdd.outline`). `@todo` keeps scenarios visible but skipped. Tag with **domain concerns** (`@config`, `@auth`, `@billing`), not just test level. Reserve `@integration` for scenarios genuinely requiring external systems. No limit on ideas per turn.

### 4b. CLI Usability and Documentation Group
**When BDD used for CLI feature**, generate `@cli` scenario group covering operational surface:

```gherkin
# CLI usability -- mechanical checks for operational surface
@cli @todo
Scenario: CLI shows usage information with --help

@cli @todo
Scenario: Each subcommand shows its own help with --help

@cli @todo
Scenario: Unknown subcommand reports error with available alternatives

@cli @docs @todo
Scenario: Operator documentation exists for the workflow
  # Verifies docs/<workflow>.md exists and contains expected sections
  # (Quick Reference, Typical Operator Workflow, Subcommands, Error Catalog)
```

`@docs` scenario mechanically enforces doc file exists with sections from `ws._meta/workflow-doc.md`. Non-CLI features (API, UI): adapt group to interface.

### 5. Organize
Group by logical concern (error handling / happy path / edge cases / boundaries). Grouping informs test file structure.

### 6. Error Severity Checkpoint
Principle: **fail fast, fail clearly, fail completely.** Swallowing errors produces hidden corruption, not graceful behaviour. For each error/edge case idea, state intended failure mode (error / warning / silent), then challenge — "Would this let problems slip through? Cause harm? Am I defaulting to leniency because errors feel unfriendly?" Can't articulate why warning is safer than error → make it error. **Autonomous mode**: default to error; warning/silent requires explicit inline justification.

### 7. State Non-Coverage

```
# NOT COVERING:
# - Concurrent access: single-user tool, no threading
# - Network failure: no network dependencies
# - Permissions: runs as local user only
```

### 8. Traceability (when SDD context available)
Note which criteria each idea covers. After listing: "X of Y acceptance criteria have test ideas. Uncovered: [list]."

## Output
Framework-registered, `todo`-marked test stubs in test file, grouped by concern, followed by non-coverage section. Visible to runner, do not execute. **Unit tests:** Stubs with skip/todo markers and docstrings. **BDD:** Scenario titles with `@todo` -- **NO steps**.

**Report `todo`/pending counts separately from passing ones, always.** "N ideas registered" is not "N tests complete," and a zero exit code from a suite that skips `todo`-marked cases is not evidence the stated behaviour was exercised -- only that nothing *else* is broken. Carry this distinction forward into every later phase's reporting rather than letting a clean run read as done.

## Behaviors
- Ground ideas in job-to-be-done: tests validate code solves user's actual problem, not just methods execute.
- **Entry-point test**: At least one idea exercising feature from real call site (CLI / API / public interface). Catches "tested but never wired" dead code.
- **Stay at naming level** -- name + one-line intent. BDD: title + intent comment only.
- Cover full problem space: happy path / error cases / boundaries / edge cases.
- **State lifecycle test**: Mutable state -> at least one idea exercising full lifecycle: set -> effect -> clear -> verify cleared -> operate again.
- **Adversarial error stance**: "If production handles this silently, what's worst?" Data integrity loss / financial impact / security exposure / invisible compounding -> must verify *loud* failure.
- Spot gaps: note `[NEEDS CLARIFICATION: does X handle Y?]`
- **Upstream transport**: Surface discoveries with structural implications beyond test level (see `ws.tdd._meta`). Don't bury gaps in test file comments.

## Anti-Patterns
- Writing test bodies/assertions (Phase 2-3) / **BDD: Writing Given/When/Then** (that's `/ws.bdd.outline`)
- Importing dependencies or setup code / Going deep on single test case / Premature fixture decisions
- Generating only happy path / Inventing threat scenarios inapplicable to project's actual context

## Gate
Write stubs to test file (or scenario titles to `.feature`), summarize what was added. Goal is **back-and-forth dialogue** to map problem space together. Human may add/remove ideas, regroup, challenge non-coverage. Wait for explicit confirmation. Next: **BDD present?** -> `/ws.bdd.outline`. **Unit tests only?** -> `/ws.tdd.outline`.
