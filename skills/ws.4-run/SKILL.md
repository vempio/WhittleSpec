---
name: ws.4-run
description: Execute a single task from the task file, enforcing constraints.
---
# ws.4-run

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/executing.md`, `ws._meta/parallel-work.md`, `ws._meta/issue-tracking.md`.

## Purpose

Shift from Planning to Execution. Load specific task from task file, lock in constraints, implement *only* that task.

## Process

### 1. Load Context
**Task file discovery**: 1) If user specified file, use it. 2) If exactly one `tasks*.md` in spec directory, use it. 3) If multiple `tasks-*.md` and none specified, list and ask. Read discovered task file and `plan.md` / `umbrella-plan.md` (whichever exists).

**Work-ledger check**: Resolve the work ledger first — `ws-binding get work-ledger` (see `ws._meta/SKILL.md` § Operating Level and Scope); never assume an external tracker.

- **`local`** → the SDD task files ARE the durable ledger (stable task numbers = identity, `[x]`/`[~]` = state). Do **not** propose creating external tickets or expect tracked-issue references; the task file is authoritative. Proceed.
- **an external tracker** → verify `requirements.md` / `umbrella-requirements.md` has tracked-issue reference(s). If missing: propose what to create — read the task file to derive the container + issue breakdown *at the org's granularity* (see `/ws.3-tasks` Tracker Sync), present suggestion. User can create issues now / confirm tracking handled elsewhere / proceed without (but make invisibility cost explicit). If present: check whether the linked issue(s) should transition (e.g., move to "In Progress").

### 1a. Resolve the verification binding (never hardcode)

The project's "full verification check" is a binding, not a fixed command (see `ws._meta/executing.md` § Verification Binding). Whenever this skill runs that check — the completion-gate test run, a "run the tests" step, the invariant comparison — resolve it; never assume a fixed runner.

<!-- WS:EXAMPLE runner-counterexample -->
Concretely, the assumption to avoid: `make test` or `pytest` because they are common, rather than because the project bound them.
<!-- /WS --> The accessor is `ws-binding.sh` in the `ws._meta` skill directory — i.e. `../ws._meta/ws-binding.sh` relative to this skill's own directory, the same sibling rule that resolves `ws._meta/SKILL.md` — a POSIX-sh script invoked from the project root. Run it as `sh …/ws-binding.sh` rather than by path alone: a copied install may arrive without its executable bit, and invoking it directly then fails into the unrunnable branch below, losing the accessor on a machine that could have run it:

- `ws-binding get verification` — the command to run (stdout).
- `ws-binding validate verification` — confirm it is runnable **before** using it.

Branch on the outcome:

- **ok** (validate exit 0, value ≠ `none`) → run that exact command as the verification.
- **`none`** (get returns `none`) → the project has no automated check; completion evidence is a demonstration, not a test pass (see `ws._meta/executing.md` § Exercise-Verified). Do not invent a command.
- **no record** (exit 3) → not configured. Load `ws._meta/binding-setup.md` and run its `verification` block inline, or name that exact action for the operator. Do not route through a full `/ws.0-start` assessment for one binding, and do not guess.
- **command missing** (validate exit 4) → fail loudly, name the command, and offer to re-run the `verification` block from `ws._meta/binding-setup.md`. Do not silently substitute another runner.
- **accessor unrunnable** (no exit code at all — it could not be invoked) → do not stop. Read the binding out of `WHITTLESPEC.md` directly per `ws._meta/binding-setup.md` § The accessor, and say that you did.

### 1b. Resolve the evidence floor (what can never count as done)

What a task must *show* lives on its acceptance criteria — each carries its own `**Demo**:`, and it varies per AC. This step does not re-derive that. It resolves the project-level floor: `ws-binding get evidence-profile`, which says what can never be sufficient here. Compose the two: the AC's Demo is the evidence to produce, the floor is the check that it is of an acceptable kind.

- **empty / unbound** (get returns nothing) → derive the floor from the verification binding: a project with a verification command floors at "automated check plus a demo"; one bound to `none` floors at "the artefact exercised through its real surface". State which floor was applied at the STOP gate. (The accessor cannot distinguish unbound from bound-empty — both are exit 0 with no output — so the branch is on emptiness, not on an exit code.)
- **Executable project** → the bound check passes **and** the AC's Demo is shown. A green check alone never closes a task.
- **Non-executable project** (prose, config, a document) → a test pass is not evidence here at all; the AC's Demo — the artefact exercised through its real surface — is the whole of it.

### 1c. Resolve the durability binding (how "done" is persisted)

Completed work must be persisted (see `ws._meta/executing.md` § Durability). **Git-per-task is the default — assume it unless `ws-binding get durability` returns a non-git binding.**

<!-- WS:IF-CONFIGURED durability -->
- **empty / unbound** (get returns nothing — a record written by hand with no Durability section) → the git default: `git status --porcelain` is the persistence-state check, persist by committing. (No `WHITTLESPEC.md` at all is already caught at §1a.)
- **git (explicit)** → same as the default.
- **a non-git binding** → drive it by the persistence how-to recorded with the binding at setup (see `ws._meta/executing.md` § Durability); do not substitute git for it.
- **timing = per-slice / boundary** → do not nag to persist each task; check persistence at the declared boundary instead.
<!-- /WS -->

This block is the one place that names the git default concretely. Everything downstream resolves the persistence-state check from here rather than restating a command, so a non-git project reads one mechanism, not five.

### 2. Select Task
Ask: "Which task number?" (or confirm if provided). **Parallel awareness**: After selecting, note other parallel-available tasks (tasks with `**Parallel**: yes` and no unfinished dependencies).

**Persistence-state check**: Run the durability persistence-state check (§1c). If the task file shows completed `[x]` tasks but the directories those tasks touched hold un-persisted changes, flag the mismatch: "Task N-1 is marked [x] but <path> is un-persisted — persist before proceeding, or confirm the state is intentional." Task-file checkmarks are not the durable record — the bound mechanism is. This catches the "prior task 'done' in task file but never persisted" pattern that accumulates across slices.

### 3. Enforce Constraints
Extract "Implementation Constraints" from task file. State clearly: "Implementing Task [N]: [Name]" / "Involvement: [autonomous / checkpoint / pair]" / "Constraints: [summary]" / "Goal: [Acceptance Criteria]" / For checkpoint/pair: "Focus: [which ACs need scrutiny]"

**Mark in-flight**: Update task file `[ ]` to `[~]` (or `[~:hint]` with session identifier). **Conflict check**: If task already `[~]`, warn: "Task N already in-flight. Another session may be working on it. Proceed anyway?" Do not continue without explicit confirmation. **Skeleton marker check**: If walking skeleton task, scan `plan.md` / `umbrella-plan.md` for `[VERIFY IN WALKING SKELETON]` markers relevant to this task's scope. Include in acceptance criteria.

### 4. Implementation Loop
Adapts to task's involvement level from `[autonomous]`, `[checkpoint]`, or `[pair]` tag and `**Focus**` line.

#### Involvement Modes
**Pair** (default): Full interaction at every TDD phase. Each step ends with human gate.

**Autonomous**: Chains through all TDD phases without human gates. Still follows TDD discipline, presents results only after task complete as batch summary. If agent hits spec gap / unexpected test failure unresolvable in two attempts / design decision outside brief -- **escalates to pair mode** for that issue, then returns.

**Checkpoint**: Executes autonomously for ACs *not* in `**Focus**` line. For focus ACs, pauses for review. Middle ground: blast through plumbing, surface design decisions.

#### Autonomous Chaining
When current task `[autonomous]` and *next* also `[autonomous]` (no unfinished dependencies), agent chains directly. Results accumulate into single batch summary. Chaining stops when: next task is `[checkpoint]`/`[pair]` / next has unfinished dependencies / escalation occurred / no more tasks.

```
AUTONOMOUS BATCH COMPLETE: Tasks [N]-[M]

| Task | Goal | Tests added | AC sub-bullet coverage | Status |
|------|------|-------------|------------------------|--------|
| N | [goal] | [test names] | [e.g. "AC 1 (a) -> test_foo; AC 1 (b) -> test_bar"] | done |
| M | [goal] | [test names] | [per sub-bullet mapping] | done / escalated at AC X |

Key changes: [files modified, entry points added]
Test suite: [N tests pass, 0 failures]
[If escalation: what and why]
```

Each task in the batch MUST still emit its own COMPLETION EVIDENCE block (see STOP Gate below) before being counted as done. The summary table is a rollup, not a substitute.

#### Pair Mode Detail
1. **Check**: Read relevant files, verify current state.
2. **Build**:
   - **Executable code** -- follow TDD phased protocol. **Invoke each phase as separate skill.**

     **User-observable behavior** (double-loop BDD outer + TDD inner):
     1. `/ws.tdd.idea` -- BDD scenario titles + unit test ideas, STOP
     2. `/ws.bdd.outline` -- Given/When/Then steps, STOP
     3. `/ws.bdd.red` -- implement step definitions (scenarios go red), STOP
     4. `/ws.tdd.outline` -- outline unit tests for internals, STOP
     5. `/ws.tdd.red` -- implement failing unit tests, STOP
     6. `/ws.tdd.green` -- minimal code to pass + verify BDD status, STOP
     7. Repeat TDD inner loop until BDD scenarios green
     8. Return to `/ws.bdd.outline` for next batch

     Each step ends with human gate. Do not combine.

     **Early wiring rule** (multi-component tasks): Wire entry point after first component lands, not after all built. Transforms BDD failures from "entry point not found" to "fails at step X" -- actionable feedback. After each `/ws.tdd.green` completing component, run BDD suite; if wiring would advance any scenario to later failure point, wire before next TDD cycle.

     **BDD pre-flight check** (before TDD inner loop at step 4): Scan `.feature` files for `@todo` scenarios matching this task's scope. Cross-check task's "BDD green" line against actual feature files. `@todo` exists: route to `/ws.bdd.outline` -> `/ws.bdd.red` first. Task promises BDD but none exist: route to `/ws.tdd.idea`. No BDD expected: proceed to TDD inner loop.

     **Internal plumbing** (unit tests only):
     1. `/ws.tdd.idea` -> 2. `/ws.tdd.outline` -> 3. `/ws.tdd.red` -> 4. `/ws.tdd.green` -> 5. Repeat red/green until outlines drained -> 6. Return to outline for next batch; repeat until all ideas drained

   - **Artifacts with testable effects** (config / data migrations / IaC) -- apply TDD at testable boundary.
   - **No testable boundary** (docs / design artifacts / manual processes) -- implement directly, verify by inspection.

### 5. Completeness Sweep
Before marking done:
1. **What changed**: Names / patterns / references introduced / removed / renamed?
2. **Grep residuals**: Search entire repo for old/replaced patterns. Success: zero matches.
3. **Grep consistency**: New patterns appear everywhere they should?
4. **Verify claims**: If task asserts "nothing references X," prove with grep.
5. **Call site check**: For each new public function/class, grep production code (NOT tests) for call sites. Zero hits = dead code, task not complete.
5a. **Touches check**: Compare the task's **Touches** list against what the change actually touched, read from the durability mechanism's own view of the change (§1c: what the persist step recorded, or the persistence-state check before persisting). A mismatch means either the task grew silently or the list was wrong when authored — say which, and correct the record. Scope hints that quietly drift mislead every later reader.
6. **Operational surface**: Entry points and documentation making feature usable? Makefile targets / CLI wiring present? Flag if missing.
7. **Doc deliverable check**: Task names doc file? Verify exists with expected sections (per `workflow-doc.md`). No doc file named but BDD scenarios exist? Flag gap. Run `<cli> --help` and verify output.
8. **Debt spot check**: Dead imports / stale config / orphaned files? Trivial (< 5 min, no risk): fix now.
9. **BDD outer loop**: Task's "BDD green" scenarios actually passed? Run BDD suite with relevant tags. Zero `@todo` must remain for this task's scope. **`@todo` staleness sweep**: Grep for `@todo` scenarios *outside* scope whose blocker was this task. Activate them or convert to `@debt` with paired markers.
10. **Workaround check**: Temporary workaround introduced? Same commit must contain: `FIXME: [DEBT]` comment (with `Debt scenario:` link + `Re-enable when:` condition) / paired `@debt` test with structured comment / debt-clearing task if fix non-trivial. See `ws.tdd._meta` > Technical Debt Protocol.
11. **AC sub-bullet coverage**: For each enumerated sub-bullet in the task's Acceptance section, identify the test that asserts it. Enumerated contracts ("for each of N sites: (a) X, (b) Y") are N*K assertions. Reporting a test count ("N tests added") without mapping each sub-bullet to an asserting test is the known failure mode. Unmapped sub-bullet = missing test, task not complete.

#### STOP Gate: Completion Evidence (mandatory before marking [x])

**Do not mark complete until this block appears with real evidence.** Gate exists because LLM has demonstrated bias toward declaring tasks complete without verifying production wiring, BDD coverage, or dead code.

```
COMPLETION EVIDENCE:
1. Production wiring: [for each new public function/class, grep production code
   (NOT test files) for call sites. Show command + result.]
   Method: <name> -> Called from: <file:line> (or DEAD CODE -- STOP)
2. Demo: [concrete action an operator/user can take + what they observe]
   "Run tests" or "validator passes" = NOT A DEMO -- STOP.
   Underwhelm check: would senior stakeholder say "you called me into a
   meeting to show me this?" If yes, task delivered infrastructure, not
   vertical slice -- revisit before marking complete.
3. BDD scenarios: [N active, M @todo under this task's scope, K green]
   Any @todo under completed task = STOP.
4. Residual patterns: [grep for old/replaced patterns -- show zero matches]
5. Test suite: [run the bound verification command (`ws-binding get verification`,
   validated first per §1a); N pass, 0 failures. Binding `none` -> show the
   demonstration instead of a test run. Never a hardcoded `make test`/`pytest`.]
6. Invariant verification: [if requirements define invariant or strong
   verification mechanism, show: comparison command + result for this
   task's output. Must cover ALL output this task affected, not sample.]
   "No invariant defined -- checked: [where you looked, e.g. requirements.md
   / umbrella-requirements.md sections X, Y]" if none exists. Claim must be auditable.
   "NOT BUILT" = STOP -- build comparison tool before proceeding.
   "NOT UPDATED" = STOP -- update comparison to cover this increment.
7. Issues discovered during this work: [list every bug/issue surfaced
   while implementing, regardless of when it was originally introduced.
   Each must have: severity assessment + tracking artifact (tracker issue
   number or "fixed in this task"). When something was introduced is
   context, never a reason to omit it from this line.]
   "None discovered (touched: [files/areas examined])" if clean. State
   what you checked -- silent omission is known failure mode.
8. AC sub-bullet coverage: [for every enumerated AC sub-bullet in this
   task's Acceptance section, name the test that asserts it. Format:
   "AC 3 (a) -> test_foo ; AC 3 (b) -> test_bar". Enumerated contracts
   ("for each of N sites: (a) X, (b) Y") are N*K independent assertions,
   not "some tests exist". **Known LLM failure mode**: counting total
   tests as a number rather than mapping each sub-bullet. If a sub-bullet
   has no asserting test, status is INCOMPLETE -- STOP.]
9. Integration milestone (if declared): [when the task file declares
   an INTEGRATION MILESTONE for this task (typically the last task in a
   slice), show the actual command invoked + observed output. Format:
   "Ran: <command>. Got: <output-or-summary>. Matches expected
   behaviour: yes/no."
   "Deferred to operator", "proxied by unit test", "requires fixture
   (assumed unavailable)" = STOP -- not evidence. Attempt the milestone
   first; if provably blocked, show the verification command that
   proves it ("ran `<check>`, got `<concrete-failure>`" -- not
   "<resource> might be down"). See ws._meta > Exercise-Verified
   Before [x] > No preemptive deferral.]
10. Persistence state: [run the persistence-state check (§1c; git
    default: `git status --porcelain`) and show the output; if files
    this task produced (tests, implementation, docs) are untracked or
    unstaged, status is NOT READY FOR [x]. Options: (a) commit the
    changes now, then re-run the check and continue only if clean for
    this task; (b) if timing is per-slice/boundary, or the change
    belongs in a later cross-task commit, state why and name the
    boundary/task that will carry it. A task marked complete on an
    un-persisted change is a "done-in-checkbox, pending-in-record"
    drift the retro will otherwise have to clean up.]
11. Walking-skeleton adversarial pass (REQUIRED when this is a walking-
    skeleton task; otherwise "N/A -- not a walking skeleton"): Name
    THREE plausible "we'd regret shipping ONLY this" scenarios as
    real-world headlines, not test cases. For each, state which AC or
    test catches it. Unaddressed scenario = STOP: either ACs missing
    (route back to /ws.refine) or tests missing (extend before [x]).
    See ws._meta > Walking-Skeleton Adversarial Pass. Known failure
    mode: shipping a walking skeleton whose [VERIFY] items cover
    mechanics (does the framework express it, does the cart accept it,
    does mobile stack?) while domain validity (are the artefacts safe
    to deliver to a real customer?) is invisible. Caught later by
    adversarial review; would have been caught earlier here.
```

If you cannot fill in a line, say "NOT CHECKED" -- do not fabricate.

### 6. Completion
1. **Mark complete, then persist as one unit**: Complete STOP-gate line 10, then update `[~]` to `[x]` **before** persisting, so the completion claim travels inside the durable unit instead of trailing it. Persist per §1c (git default: commit now, task file included). If timing is per-slice/boundary, deferral is expected — name the carrying boundary/task and reason, and that boundary's persist carries the accumulated markers. Cross-task deferral under per-task timing must name the carrying task and reason.
2. **Verify persistence after marking**: Re-run the durability binding's persistence-state check (§1c). It must show no task-produced files outstanding **and no outstanding task file** — the marker is task-produced state like any other. If anything remains and deferral was NOT explicit, the persist did not complete: revert the marker to `[~]` and return to step 1. A `[x]` sitting outside the durable unit is a completion claim nothing backs, and on a slice's last task nothing later sweeps it up.
3. **What's new**: Summarize concrete behaviors delivered and how to exercise them. Be specific about what the user can now do, naming the real invocation rather than describing it. If demo wouldn't survive underwhelm test, task did not deliver vertical slice -- revisit.

<!-- WS:EXAMPLE demo-phrasing -->
The shape to aim for: "You can now run `cli validate --order-id ABC-123` and see the check reject a malformed one." Concrete command, concrete result — the command is this project's, not a prescribed one.
<!-- /WS -->
4. **Next**: "Ready for Task [N+1]?" (Or note parallel options.)

If last task in **single-cycle project**: "All tasks complete. Run `/ws.9-retro`." If last task in **multi-slice project**: Update slice status in `umbrella-plan.md`. "Slice [X] complete. Run `/ws.9-retro` for this slice." Suggest next: next slice / `/ws.sweep` if parallel sessions completed work / project retro if all slices done.

## Anti-Patterns
- **Scope Creep**: Don't fix "other things" seen while in file.
- **Constraint Violation**: Don't add libraries or patterns forbidden by task file.
- **Gold Plating**: Don't implement beyond specific acceptance criteria.
