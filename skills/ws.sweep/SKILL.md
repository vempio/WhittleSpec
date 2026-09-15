---
name: ws-sweep
description: Completeness sweep -- exhaustively verify nothing was missed after a change.
---
# ws.sweep

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/executing.md`, `ws._meta/sweep-procedure.md` (steps 1-4c), and `ws.tdd._meta/debt-protocol.md` (step 6's debt audit).

## Purpose

After any non-trivial change, exhaustively verify nothing missed. Goes beyond search-and-replace: covers stale references, orphaned content, broken cross-references, inconsistent docs. Shallow verification is proven, recurring failure mode. Checking only files you touched is not verification -- value is in finding what you DIDN'T touch but should have.

**This skill never mutates.** That is the promise, and it is not carved out for trivial findings: a sweep that also edits is a diff to review rather than an observation to trust. Findings go out as a report with a one-line fix each; `/ws.fix` is the skill that applies them.

## When to Use

After renaming files/functions/variables/commands / after migrating patterns / after moving content between files / after changing doc structure/workflows / after any change applying consistently across multiple files / paranoia check before committing cross-cutting changes.

## Process

Steps 1 through 4c live in `ws._meta/sweep-procedure.md`: state what changed, think
through what could ripple, run the exhaustive residual search, then the structural, CLI
and BDD-correspondence checks that a text search cannot reach. `ws.fix` loads the same
file as its completeness stream, so a sweep run either way covers the same ground.

### 5. Report

```markdown
## Sweep Results

**Change**: [Brief description]
**Scope**: [What was searched]

### Residual Matches (old patterns)

| Pattern | Matches | Files |
|---------|---------|-------|
| `old_name` | 0 | -- |
| `/old_name` | 2 | file_a.md:31, file_b.md:72 |

### Structural Issues

| Issue | Location | Detail |
|-------|----------|--------|
| Stale cross-ref | workflow.md:68 | Points to old command name |
| Index mismatch | README.md | Lists 5 items, 6 exist on disk |

### BDD Scenario Audit (when .feature and task files exist)

| Scenario | Task | Task Status | Scenario Status | Finding |
|----------|------|-------------|-----------------|---------|
| ... | ... | ... | ... | OK / CRITICAL / ORPHAN / MISSING |

- **Critical**: N scenarios @todo under completed tasks
- **Orphans**: N scenarios not traced to any task
- **Missing**: N task commitments with no corresponding scenario

### Verdict

[CLEAN / N issues found -- list them]
```

### 6. Technical Debt Spot Check

After residual/structural checks: dead imports/config from removing/renaming? / orphaned files from migration? / stale comments referencing old names? / debt marker consistency (run the audit from `ws.tdd._meta/debt-protocol.md` § Technical Debt Protocol -- each `FIXME: [DEBT]` must have paired `@debt` test and vice versa; has any marker's re-enable condition been met?).

**Threshold**: Trivial debt (< 5 min, no risk) -- report it with the one-line fix, do not
apply it. Substantial -- flag for a dedicated task. The sweep's job is to leave nothing
unseen, not to leave the tree changed.

### 7. Hand Off

Sweep does not mutate -- that is the promise, and it is what lets a finding be read as an
observation rather than a diff to review. Give every finding a one-line proposed fix, so
the operator can answer "fix the reported issues as proposed" in one sentence, or reach
for `/ws.fix` next time as the no-stop shortcut. Once the fixes land, re-run the sweep:
zero residuals is the close.

## Anti-Patterns

- Declaring "done" once the reported matches are fixed, without re-running the sweep
- Searching only files you touched
- Searching one variant but not others (`/foo` but not `foo` in backticks)
- Asserting "nothing references X" without grep proof
- Checking only text patterns when change was structural
- Skipping docs and workflow files because "they're not code"
- Trusting task `[x]` status without verifying BDD scenario state -- `@todo` invisible to runner (skipped), "all tests pass" is not evidence
- Checking only top-down from task claims -- always also scan bottom-up from scenarios
- Grepping for `--help` handling instead of actually running CLI
- Assuming documentation exists because no one complained
- Trusting BDD scenarios cover documented workflows without bidirectional check
