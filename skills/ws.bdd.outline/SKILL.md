---
name: ws-bdd-outline
description: Phase 2 -- design BDD scenario steps in domain language (Given/When/Then).
---
# ws.bdd.outline

Load shared context: `ws.tdd._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also read `ws.tdd._meta/bdd-workflow.md`.

## Purpose

Transform BDD scenario titles from `/ws.tdd.idea` into Given/When/Then scenarios. BDD counterpart of `/ws.tdd.outline` -- domain language instead of AAA.

**Cognitive mode: Specification, not implementation.** Every step understandable without seeing codebase.

**Track guard:** Must be `.feature` files (Gherkin). Editing pytest/Jest/Catch2 files = wrong track, use `/ws.tdd.outline`.

## Prerequisites

- BDD scenario titles from `/ws.tdd.idea` (Phase 1), reviewed and approved
- Detected BDD framework (see `ws.tdd._meta` language detection)

## Process

### 1. Select Scenarios

Ask: "Which scenarios should I outline?" (or confirm if human specified). If "all", proceed in logical groups.

### 2. Write Given/When/Then Steps

Enrich `@todo`-tagged scenario with Given/When/Then steps. `@todo` **remains** -- no step definitions yet. Steps use **domain language**, surviving into final `.feature` as user-readable spec.

Three failure modes (parallel to AAA in `/ws.tdd.outline`):
1. **Implementation language** (leaks internals): `Given a user row exists in the database with id=5` -- refactoring invalidates.
2. **Too vague**: `Then the system works correctly` -- correct how?
3. **Domain language** (sweet spot): `Given a registered user` / `When the user submits the registration form` / `Then the dashboard shows a welcome message`

Good-step test: survives complete rewrite of production code? Mentions database tables / API endpoints / variable names = coupled.

```gherkin
# BAD -- implementation language:
@config @todo
Scenario: Daemon loads config from default path when no args provided
  Given the file /etc/daemon/config.yaml contains valid YAML with key "sensors"
  When the main() function is called with an empty argv
  Then the DaemonConfig object has sensors attribute with 3 items

# BAD -- too vague:
@config @todo
Scenario: Daemon loads config from default path when no args provided
  Given a config file
  When the daemon starts
  Then it works

# GOOD -- domain language:
@config @todo
Scenario: Daemon loads config from default path when no args provided
  # AC: R-16 - verify backward compatibility without CLI args
  Given the daemon configuration file exists at the default path
  And the configuration defines 3 sensors
  When the daemon starts without command-line arguments
  Then the daemon begins monitoring all 3 configured sensors
```

### 3. Check Step Reuse

Search existing step definitions for matching/similar patterns before writing new. BDD power = shared vocabulary.

- **Exact match**: Reuse. Adjust scenario wording to match existing pattern.
- **Near match**: Parameterize existing vs. create new.
- **No match**: Write new, note it.

Flag decisions: "Reusing 'Given a registered user' from `tests/bdd/conftest.py`" (pytest-bdd) / `features/steps/user_steps.py` (behave).

### 4. Structural Patterns

- **Background**: Same Given in 3+ scenarios in same feature -> note for extraction. Don't extract prematurely.
- **Scenario Outline**: Same step structure, different data values. Don't force when behavior differs.

### 5. Challenge Assertion Precision

For each Then: User-observable? / Specific enough? ("sees error" weaker than "sees 'Config file not found'") / Subtly wrong implementation still satisfies?

**Batch size: the Outline rate limit in `ws.tdd._meta`.** See also "Batch Processing Flow" there.

## Output

`@todo`-tagged scenarios with Given/When/Then in `.feature` files. Still no step definitions.

## Behaviors

- Domain language only. Class name / database table / API path in step = rewrite.
- Each scenario self-contained. No shared mutable state.
- Intent comment: what scenario validates, what it does NOT cover.
- New idea discovered: record as `@todo`, flag to human. Don't silently expand scope.
- **Shared setup**: Common Given patterns -> note for Background during `/ws.bdd.red`.
- **Outline desired behavior**: Scenario describes *should*, not *does*. Will go red; production code satisfies.

## Anti-Patterns

- Writing step definitions (Phase 3 -- `/ws.bdd.red`)
- Implementation-level / internal-testing / overly generic steps
- Scenarios as unit tests with Gherkin syntax sugar (tests single function return = unit test)
- Exceeding the Outline rate limit
- Drifting to forest-level -- flag: "Should we return to `/ws.tdd.idea`?"

## Gate

Write scenarios to `.feature` file, summarize changes. File is deliverable -- not conversation-only.

Wait for review before `/ws.bdd.red`. After outer red, transition to TDD inner loop. See "Double-Loop Model" in `ws.tdd._meta`.
