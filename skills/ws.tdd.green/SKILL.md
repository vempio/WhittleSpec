---
name: ws-tdd-green
description: Phase 4 -- write minimal production code to make failing tests pass.
---
# ws.tdd.green

Load shared context: `ws.tdd._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also read `ws.tdd._meta/bdd-workflow.md`.

## Purpose

Transition from test design to production code. Heavy lifting (discovering what to test, designing assertions, validating depth) done in Phases 1-3. This phase writes simplest code making tests pass.

Interaction signal: tells LLM test design is complete and production code may be written. Without explicit transition, LLM blurs test writing and production coding, undermining review gates.

## Prerequisites

- Failing tests from `/ws.tdd.red` (Phase 3), confirmed failing for right reasons

## Process

### 1. Write Minimal Code

Implement production code making failing tests pass. Minimal = enough to pass, no more / no speculative features / no premature abstractions.

### 2. Run Full Suite

Run **entire** test suite, not just new tests. All new tests must pass / all previous tests must still pass / previously passing test now fails = **stop and investigate** (regression, not acceptable side effect).

### 3. BDD Verification Checkpoint

Run BDD suite for feature's tags after unit tests green. **Not optional** when BDD scenarios exist or are expected. Report: "BDD outer loop: X of Y scenarios pass. Z still `@todo`."

- All pass: double loop complete for batch. Note in gate report.
- Still fail: identify which steps need more production code. Feeds next TDD inner loop.
- **Still `@todo`** (never got step definitions): flag: "WARNING: N scenarios still stubs. Route to `/ws.bdd.outline` -> `/ws.bdd.red` before declaring complete."
- No BDD scenarios exist/expected: skip, state why.

**Early wiring check** (critical for multi-component tasks): BDD scenarios fail at entry point level ("unknown subcommand," "function not found")? Wire component into entry point now -- typically few lines of glue. Scenario stuck at "subcommand not found" for entire build = zero integration feedback. Scenario advancing to next failure tells you what to build next. **Do not defer wiring to end.**

### 4. Documentation Update

If green cycle changed operator-visible behavior (new subcommand/flags, changed output, new errors), update `docs/<workflow>.md` in same cycle. Documentation = deliverable alongside code, not afterthought.

- **New subcommand/flag**: Quick Reference + Subcommands sections
- **New error**: Error Catalog with exact message and fix
- **Changed workflow**: Typical Operator Workflow
- **New config/env var**: Configuration section

No docs file yet and task spec names one: create from `workflow-doc.md` template in `ws._meta`. Skip for internal plumbing with no operator-visible effect.

### 5. Refactor (if needed)

Refactor while keeping tests green / run suite after each step / breaks test = revert and reconsider / consult user first.

## Anti-Patterns

- **Gold plating**: behavior beyond what tests require
- **Untested additions**: production code no test exercises
- **"While I'm here"**: fixing/refactoring unrelated code
- **Skipping full suite**: running only new tests misses regressions
- **Deferring docs**: "I'll write docs later" = docs won't exist
- **Building without wiring**: primitive + tests complete, production never calls the primitive. Dominant failure mode -- not a defensible scope boundary. "The wiring is out of scope / a follow-up task" is this pattern renamed. If the primitive's purpose is to serve production, wiring is part of the same cycle.
- **Spec drift out of the green cycle**: new behavior landed in code, `requirements.md` / `umbrella-requirements.md` silent. Treating spec-sync as a later sweep concern rather than a green-phase deliverable is how concurrency protocols, locking behaviors, and contract changes go spec-dark.

## Gate

Present passing suite with **mandatory checklist**. Every item needs visible evidence (command output, grep result, explicit statement) -- not "I checked."

```
POST-GREEN CHECKLIST:
1. Production wiring: [for each new primitive / method / Protocol / type /
   config knob introduced, grep production code (NOT tests) for call sites
   or type-annotated uses. Zero hits = DEAD CODE, task not complete.
   "Will be wired later / out of scope" does NOT satisfy this -- building
   without wiring is the dominant failure mode, not a scope boundary.]
   New element: <name> -> Wired at: <file:line> (or DEAD CODE -- STOP)
2. Test honesty: Did any new test pass immediately (never red)?
   [yes/no -- if yes, list which; backfill or genuine?]
3. BDD status: [N active, M @todo, K green out of total]
   "Can't run" requires verified evidence, not assumption.
4. Regressions: [N existing tests pass, 0 failures]
5. Documentation: [no operator-visible changes / updated <file>]
6. Spec sync: [for each new user-visible behavior or protocol this cycle
   introduced, name the requirements.md / umbrella-requirements.md AC
   covering it with line number. No spec for this work: state "no spec"
   and why. Spec exists but lacks coverage for the new behavior: STOP --
   update spec before declaring green. Spec-sync is a green-phase
   deliverable, not a later-sweep rescue.]
```

**If any item cannot be completed honestly, say so.** "I didn't check" beats fabricated answer. Checklist exists because LLM has bias toward declaring green prematurely -- particularly on items 1 (wiring) and 6 (spec sync).

Wait for confirmation before proceeding.

## Completion

All tests pass and human confirms -> follow batch processing flow (see `ws.tdd._meta`):

1. **More outlines waiting?** Return to `/ws.tdd.red` for the next red batch.
2. **Outlines exhausted, ideas waiting?** Return to `/ws.tdd.outline` for the next outline batch.
3. **Unit ideas exhausted, BDD still red?** Continue TDD inner loop -- derive unit test ideas from failing BDD steps.
4. **Both exhausted / green?** TDD cycle complete. Via `/ws.4-run`: return to ws.4-run flow. Standalone: stop or `/ws.tdd.idea` if new needs emerged.
