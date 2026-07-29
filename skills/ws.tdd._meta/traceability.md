# Requirement Traceability

Reference material for linking tests to acceptance criteria when SDD context is available. The summary lives in `SKILL.md`; this file has the full procedure.

## AC References in Test Comments

Use an `AC:` tag in the test's Goal comment to identify which acceptance criterion a test covers, with a brief summary so the reader doesn't have to look it up:

```python
# Goal: Verify fail-fast on missing file (AC: R-3, immediate clear failure)
```

The identifier (`R-3`, `AC-2`, etc.) matches however criteria are numbered in `requirements.md` / `umbrella-requirements.md`. The summary is a few words, not a copy of the full AC. A single test may cover multiple criteria; a single criterion may need multiple tests. Many tests (edge cases, invariants) won't trace to any AC -- that's normal and expected.

## Coverage Reporting

At two points in the cycle, report coverage status:

1. **After `/ws.tdd.idea`**: "X of Y acceptance criteria have test ideas. Uncovered: [list]." This catches missing coverage before any implementation.
2. **After each `/ws.tdd.red` batch**: "X of Y acceptance criteria now have executable tests. Still in outline/idea only: [list]. Uncovered: [list]." This tracks progress as tests become real.

## Without SDD Context

When TDD skills are used standalone (no `requirements.md` / `umbrella-requirements.md`), skip AC references and coverage reporting. Tests are still valuable without formal traceability -- the convention is additive, not required.
