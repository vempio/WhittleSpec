---
name: ws.tdd.review
description: Audit existing test code for quality, depth, and adherence to TDD principles.
---
# ws.tdd.review

Load shared context: `ws.tdd._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws.tdd._meta/test-quality-checklist.md` (step 3's criteria) and `ws.tdd._meta/debt-protocol.md` (the debt scan that opens it).

## Purpose

Review existing test code against TDD quality standards. Distinct from `/ws.review` (reviews **specifications** for testability) -- this reviews **actual test code** for quality.

## Process

### 1. Scope

Ask: "Which test files or modules should I review?" (or confirm if specified).

### 2. Depth

**Default: thorough.** Examine every test file in scope, read each test function. Most common complaint: superficial review missing issues careful reading would catch.

If scope large (> 20 files), state and propose batching: "N files in scope. I'll review in batches of 8, starting with [area]."

### 3. Evaluate

Work through `ws.tdd._meta/test-quality-checklist.md`, against
`ws.tdd._meta/SKILL.md` § Quality Standards. The criteria and the adversarial pass both
live in that file, so this skill and `ws.fix` hold one bar rather than two paraphrases
of it.

The adversarial pass is not optional. A checklist run without it reports what the tests
say; it does not establish that they would catch a wrong implementation.

### 4. Report

```markdown
## Test Quality Review: [scope]

### Summary

- **Files reviewed**: [count]
- **Tests reviewed**: [count]
- **Critical issues**: [count] (success theater, broken assertions)
- **Improvements**: [count] (depth, structure, documentation)

### Critical Issues

[Tests not actually validating anything, including untested state clearing paths]

- [File:line] `test_name`: [what's wrong, why it matters]

### Depth Issues

[Assertions checking too shallowly]

- [File:line] `test_name`: checks [what it checks], should check [what it should check]

### Structural Issues

[AAA violations, lumped behaviors, poor naming]

### Dead Code & Usage

- [File:line] `function_name`: defined and tested but never called from production flow

### Test Level

- [File:line] `test_name`: unit-tests coordination logic, should be integration-tested (or vice versa)

### BDD Quality (when .feature files exist)

- [File:line] `scenario_name`: [what's wrong]

### Task Completion Audit (when task file and .feature files exist)

| Scenario | Task | Task Status | Scenario Status | Finding |
|----------|------|-------------|-----------------|---------|
| Generate pending certs | 2b | [x] | active | OK |
| Field validation x3 | 2a | [x] | @todo | CRITICAL: task claims done |
| Send with attachment | 3a | [~] | active | OK (in progress) |
| Full pipeline | -- | -- | @todo | Orphan: no task claims this |

- **Critical**: [count] scenarios still @todo under completed tasks
- **Orphans**: [count] scenarios not traced to any task
- **Pending**: [count] scenarios awaiting activation for incomplete tasks

### BDD-Documentation Correspondence (when operator docs and .feature files exist)

- **Documented workflows without BDD**: [list workflow steps with no matching scenario]
- **BDD scenarios without documentation**: [list scenarios exercising undocumented workflows]
- **CLI usability gaps**: [missing @cli scenarios for --help, unknown subcommand]

### Traceability (when SDD context available)

- **Criteria with tests**: [list with AC identifiers]
- **Criteria without tests**: [list -- these need `/ws.tdd.idea`]
- **Tests without AC reference**: [list -- typically fine; flag only if scope creep]

### Recommendations

[Prioritized list, most impactful first]
```

## Output

Report following template above, delivered for discussion. Report is conversation starter, not final verdict -- human may disagree with severity or priorities.

## Relationship to `/ws.review`

Complementary: `/ws.review` reviews **specifications** for testability. `/ws.tdd.review` reviews **actual test code** for quality. Both invoked by `/ws.fix` during quality passes.

## Anti-Patterns

- Reviewing spec testability (that's `/ws.review`)
- Suggesting new tests to write (that's `/ws.tdd.idea`)
- Rewriting tests during review (review first, fix separately)
