---
name: ws.bdd.red
description: Phase 3 -- implement step definitions for BDD scenarios (undefined to pending/failing).
---
# ws.bdd.red

Load shared context: `ws.tdd._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also read `ws.tdd._meta/bdd-workflow.md` and `ws.tdd._meta/traceability.md`.

## Purpose

Turn outlined Gherkin scenarios into executable (but failing/pending) tests by writing step definition code. BDD counterpart of `/ws.tdd.red`. **Critical distinction:** Unit TDD "red" = assertion failure. BDD "red" = steps **undefined or pending** -- runner can't find matching step definition, or step signals "not yet implemented."

> The test harness must tell the truth at all times. Every known test obligation is represented as faithfully as the selected framework permits, and its actual state is visible: planned, outlined, pending/undefined, genuinely failing, passing, deliberately deferred, or environment-blocked. Green means the stated behaviour was exercised and verified. No placeholder may claim green.

**Target output is behavioural red, not pending.** Pending/undefined is a legitimate intermediate state while a step is being written, and a legitimate terminal state only where the selected framework genuinely cannot express a failing assertion yet — never because this phase stopped before finishing the step. A step left on `NotImplementedError`/pending after a real call became possible has not reached this phase's target.

Prereq: outlined BDD scenarios from `/ws.bdd.outline` (Phase 2), reviewed and approved.

## Process

### 1. Select Scenarios
Ask: "Which scenarios to implement step definitions for?" (or confirm if specified). **Max 3 per turn.** Remove `@todo` from selected scenarios -- they now execute (and fail).

### 2. Check Existing Step Definitions
**Before writing any new step**, search existing step files for matching/similar steps. Step reuse is how BDD scales.

```bash
# pytest-bdd: check existing steps
grep -rE "@given|@when|@then" tests/bdd/ --include="*.py"

# behave: check existing steps
grep -r "given\|when\|then" features/steps/ --include="*.py"

# Cucumber: check existing steps
grep -r "Given\|When\|Then" features/step_definitions/
```

For each step: **Already defined?** Reuse. **Similar exists?** Parameterize existing. **New?** Write new definition. Flag all reuse decisions.

### 3. Write Step Definitions
Each step definition matches the Gherkin step text with a descriptive function name, and defaults to a **real failing assertion**: call the not-yet-existing production code and assert on its actual behaviour, so the failure is a genuine `AttributeError` / `ImportError` / assertion failure, not a deliberate stub. For example, a step "the daemon begins monitoring N sensors" that can already call `Daemon.status()` should assert on the real return (`assert daemon.status().monitored_count == count`) even though `Daemon` doesn't exist yet — that failure is more informative than a hand-written stub. Fall back to `raise NotImplementedError(...)` / `pending` only when there is genuinely nothing to call yet — not merely "the interface isn't written." A step frozen at that fallback once a real call became possible has not reached this phase's target (see the truthfulness invariant in § Purpose).

<!-- WS:EXAMPLE bdd-red-step-syntax -->
**pytest-bdd (Python):**

```python
# tests/bdd/test_daemon.py

from pytest_bdd import scenario, given, when, then, parsers

@scenario("daemon.feature", "Daemon loads config from default path when no args provided")
def test_daemon_default_config():
    pass

@given('the daemon configuration file exists at the default path',
       target_fixture="config_path")
def config_at_default_path():
    raise NotImplementedError(
        "TODO: Create config fixture at default path"
    )

@given(parsers.parse('the configuration defines {count:d} sensors'))
def config_defines_sensors(config_path, count):
    raise NotImplementedError(
        "TODO: Write config file with specified sensor count"
    )

@when('the daemon starts without command-line arguments',
      target_fixture="daemon")
def daemon_starts_no_args(config_path):
    raise NotImplementedError(
        "TODO: Start daemon process with empty argv"
    )

@then(parsers.parse('the daemon begins monitoring all {count:d} configured sensors'))
def daemon_monitors_sensors(daemon, count):
    raise NotImplementedError(
        "TODO: Assert daemon state reflects monitoring of N sensors"
    )
```

**behave (Python):**

```python
# features/steps/daemon_steps.py

@given('the daemon configuration file exists at the default path')
def step_config_at_default_path(context):
    raise NotImplementedError(
        "TODO: Create config fixture at default path"
    )

@given('the configuration defines {count:d} sensors')
def step_config_defines_sensors(context, count):
    raise NotImplementedError(
        "TODO: Write config file with specified sensor count"
    )

@when('the daemon starts without command-line arguments')
def step_daemon_starts_no_args(context):
    raise NotImplementedError(
        "TODO: Start daemon process with empty argv"
    )

@then('the daemon begins monitoring all {count:d} configured sensors')
def step_daemon_monitors_sensors(context, count):
    raise NotImplementedError(
        "TODO: Assert daemon state reflects monitoring of N sensors"
    )
```

**Cucumber (Ruby):**

```ruby
# features/step_definitions/daemon_steps.rb

Given('the daemon configuration file exists at the default path') do
  pending 'Create config fixture at default path'
end

When('the daemon starts without command-line arguments') do
  pending 'Start daemon process with empty argv'
end

Then('the daemon begins monitoring all {int} configured sensors') do |count|
  pending "Assert daemon monitors #{count} sensors"
end
```
<!-- /WS -->

### 4. Organize Step Files
Group by domain concern, not by scenario — single step may serve many scenarios, and organizing by concern prevents duplication.

<!-- WS:EXAMPLE bdd-red-step-syntax -->
**pytest-bdd:** Shared Given steps + common fixtures in `tests/bdd/conftest.py`; feature-specific in `tests/bdd/test_*.py`. **behave:** Steps in `features/steps/` by domain concern.
<!-- /WS -->

### 5. Run BDD Suite
Run against selected scenarios. Should report **failing** by default (genuine assertion), or **pending** only where step 3's fallback applied. Previously passing scenarios must still pass. If scenario passes immediately: investigate -- vacuously passing (success theater) or existing code already handles case?

### 6. Coverage Report (when SDD context available)
After each batch: "X of Y acceptance criteria now have executable BDD scenarios (outer red). Still outline/idea only: [list]. Uncovered: [list]."

## Output
Step definition files, failing by default and pending only where step 3's fallback applied. BDD runner executed, reports failing/pending status per scenario. BDD scenarios now "outer red." Next: **TDD inner loop (recommended)**: `/ws.tdd.idea` -> `/ws.tdd.outline` -> `/ws.tdd.red` -> `/ws.tdd.green` (also verifies BDD scenarios). **Direct implementation (trivial cases)**: Human writes production code directly. See "Double-Loop Model" in `ws.tdd._meta`.

## Behaviors
- Step definitions = **boundary** between domain language and code. `.feature` speaks user's language; step definition translates into system's language.
- **Step reuse paramount.** Every duplicate = maintenance burden + missed shared vocabulary.
- Awkward Gherkin wording? Propose rewording scenario step rather than one-off definition.
- Complex step definition (many lines setup) = scenario at too low abstraction -- flag for split/rewrite.

## Anti-Patterns
- **Empty step body silently passing**: BDD's `assert True`. Every body must raise `NotImplementedError` or contain real logic.
- Writing production code to make steps pass (that's TDD inner loop) / Duplicating step definitions already in other files
- **Implementation-coupled steps**: Step directly imports/calls internal modules -- wrong test level?
- **Success Theater**: analysing logs instead of asserting system state / printing "TODO" and passing / making up API keys / creating alternate paths.

## Gate
Present step definitions and BDD runner output (pending/failing). Confirm: step definitions match scenario steps / reuse decisions sound / pending/failing state genuine / ready for TDD inner loop.
