---
name: ws.3-tasks
description: Level 3 — Break plan into sequenced, atomic work units.
---
# ws.3-tasks

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/parallel-work.md`, `ws._meta/issue-tracking.md`.

## Purpose

Break approved plan into concrete, sequenced tasks. Each 30 min - 2 h (see Task Sizing under Behaviors). Sequence for early integration feedback — walking skeleton first.

## Prerequisites

- `requirements.md` / `umbrella-requirements.md` exists and approved / `plan.md` / `umbrella-plan.md` exists and approved / User confirmed readiness

### Multi-Slice Projects

Umbrella shape is the **exception, not the default** (see `ws._meta` §Process-Shape Hard Rules). If the spec directory has `plan.md` (no `umbrella-plan.md`) → single-cycle: output `tasks.md`, ignore the rest of this section.

If `umbrella-plan.md` exists with a **Slice Status** table (umbrella already adopted — verify, don't infer): pick which slice to task (ask if unclear). Scope to that slice; reference umbrella specs for context. Output `tasks-<slice>.md`.

## Process

### 1. Review Plan

Load and summarize: "Working on: [feature] / Walking skeleton: [summary] / Key components: [list]"

### 2. Identify Tasks

Break into atomic units. Each: 30 min - 2 h (see Task Sizing under Behaviors for full rule, including the no-sub-tasks-at-planning constraint and granularity test) / clear verifiable outcome / **one capability** — name the single user-job it serves; if the name needs an "and", split.

### 3. Sequence for Integration

Order: (1) **Walking skeleton** -- end-to-end path working. (2) **Integration points early** -- surface issues first. (3) **Polish last**. Mark milestones: "After this task, verify [X]"

#### Each Task = Self-Contained Vertical Slice (HARD RULE)

Every task MUST leave project **working and testable**. Not guideline -- structural constraint. Violations fixed before output.

1. **Breaking changes include consumers.** Mandatory field / schema change / API alteration MUST update all consumers (fixtures, configs, tests, docs) in *same* task. Fix deferred to later = **rejected**.
2. **Each task wires itself in.** Component MUST integrate into prod entry point + update integration/BDD tests. Never accumulate unwired components.
3. **BDD/docs advance per task, or the task is recorded exempt.** Each task advances at least one BDD scenario red-to-green — unless its `BDD decision` (see § BDD decision) is `do not use`, recorded with the required reason. Operator docs update per behavior delivered. Separate "write tests"/"write docs" task = **rejected**.

**Invariant**: After every task -- the project's bound verification passes (`ws-binding get verification`; see `ws.4-run` §1a, never a hardcoded runner), BDD reflects reality, no fixture/config silently broken.

### 4. Involvement Triage

Assess each task's involvement level.

| Level | Tag | Mode |
|-------|-----|------|
| **autonomous** | `[autonomous]` | Agent chains TDD phases, presents batch result |
| **checkpoint** | `[checkpoint]` | Pauses at focus points for review |
| **pair** | `[pair]` | Full interaction every TDD phase |

#### Triage Criteria

Autonomous only if ALL dimensions low-risk; any high-risk dimension elevates.

| Dimension | autonomous | checkpoint | pair |
|-----------|-----------|------------|------|
| Reversibility | Trivially undone | Moderate | Hard (migrations, API contracts, data model) |
| Domain risk | Plumbing, config | Business logic, understood | Correctness-critical, regulatory, security |
| Novelty | Established patterns | Some unknowns | Uncharted, first use |
| Blast radius | Local to one module | Module interfaces | Cross-system, affects data |

#### Focus Areas (non-autonomous only)

For `[checkpoint]`/`[pair]`, add `**Focus**` naming ACs needing scrutiny. Rest implicitly autonomous.

```markdown
### Task 2 [pair]: Implement order state machine with persistence
- [ ] **Goal**: Orders transition through states and survive restarts
- **Focus**: ACs 1-2 (state transition rules, error semantics)
- **Touches**: src/order/states.py, src/order/repo.py, src/config/loader.py
```

#### Involvement Summary Table

Add at top of task file after Implementation Constraints:

```markdown
## Involvement Summary
| Task | Level | Focus | Rationale |
|------|-------|-------|-----------|
| 1 [pair] | pair | API contract (ACs 1-2) | Walking skeleton, sets contract |
| 2 [checkpoint] | checkpoint | Migration (AC 3) | Verify before committing to schema |
| 3 [autonomous] | autonomous | -- | Standard CRUD, established patterns |
```

User sign-off artifact. Present with the draft task list before execution.

Agent proposes; user approves/adjusts. User may set blanket policies ("nothing touching DB is autonomous"). Record approved policies as implementation constraints.

#### Slice Ledger (human-scannability)

Above the Involvement Summary, add a one-line-per-task ledger the user can scan in seconds to audit slicing **without** reading every task body:

```markdown
## Slice Ledger
| Task | User-job (what the user DOES) | Surfaces touched | Distinct slice because… |
|------|-------------------------------|------------------|--------------------------|
| 1 | reach & read the Sent folder by alias | list_folders, search_messages, resolver | the discover-then-use loop, end to end |
| 2 | reach Drafts/Trash/threads by alias | list_messages, read_message, get_thread | new user-jobs on new entry points |
```

The ledger is the severed-capability test made visible. Two tells, scannable at a glance: if a row's **User-job** reads as advertising/exposing ("make aliases discoverable", "update the catalog") rather than a thing the user does, or if **Distinct slice because** can only cite a surface ("it's the `list_folders` task"), the slice is suspect — merge. A single surface spanning multiple tasks down the **Surfaces touched** column, or one capability's surfaces scattered across rows, is per-surface severance. Present the ledger FIRST at the STOP gate; it is what lets the human catch a bad cut in one line instead of reading the whole file.

#### Involvement Sign-Off (presented at the single post-compliance gate)

Involvement is **not** presented here. There is exactly one sign-off gate, and it runs **after** vertical-slice compliance passes (see § Validate Sequencing → STOP Gate: Vertical Slice Compliance, then Present). At that gate the task file is presented — Slice Ledger first, then the Involvement Summary, then enough task detail to judge the levels — in a single STOP. The involvement summary only makes sense shown with the task list, so it is never presented before compliance is clean.

### 5. Validate Sequencing

**AC-to-task coverage (mandatory, first)**: For every AC / invariant / enumerated sub-bullet in `requirements.md` / `umbrella-requirements.md` within this slice's scope, name the task that makes it true. Produce the traceability table:

```
AC COVERAGE
| requirements.md / umbrella-requirements.md ref | Covered by task |
|------------------------------------------------|-----------------|
| Cluster X AC 1                                 | Task 2          |
| Cluster X AC 2                                 | Task 2          |
| Invariant 3                                    | Task 4          |
| Cluster Y AC 1 (a)                             | Task 5          |
| Cluster Y AC 1 (b)                             | -- GAP --       |
```

Every AC maps to at least one task. `-- GAP --` = missing task (add one) or scope/spec drift (run `/ws.refine`). **Known LLM failure mode**: drafting tasks from plan-component boundaries and silently dropping ACs that live only in `requirements.md` / `umbrella-requirements.md`. Also: enumerated sub-bullets ("for each of N sites: (a) X, (b) Y") are N×K independent ACs — map each pair explicitly, not the parent bullet.

Cross-check `plan.md` / `umbrella-plan.md` / `decisions.md` too: any prescriptive statement ("`_run_auto_continue` computes start_index from `next_step`") = implicit AC. Unmapped → add a task or remove the prescription.

**Sequencing questions**: "First end-to-end feedback?" / "Dependencies explicit?" / "Should any split?"

**Skip test (mandatory, ALL tasks)**: Mentally skip each task. Nothing demonstrable changes outside test suite -> infrastructure without payoff -> merge into task with demo.

**Underwhelm test (mandatory, ALL tasks)**: Imagine showing demo to senior stakeholder. "You called me in for *this*?" -> too thin or demo hides payoff. Merge thin tasks or rewrite demo.

**Severed-capability / exposure test (mandatory, ALL tasks)**: Name the capability each task serves in one user-job phrase — a thing the user *does*. Then ask: *is this task's entire payload making a capability visible — advertising, cataloguing, documenting, adding to an index / menu / usage-hint — where the capability functions, or will function, without it?* If yes, it is not a slice; it is the exposure-half of another task's behaviour — merge it into the task delivering that behaviour. Discoverability ships WITH its capability, never as its own task. Equally reject **per-surface slicing** (one task per tool / function / endpoint) when those surfaces compose one capability. See `ws._meta` § Slicing > Per-surface slicing + Exposure is not a slice. This test fires where the per-task Reachability pass cannot: an exposure-only task is independently demoable and "wires into prod," so it passes Reachability while still being horizontal.

**Reachability pass (mandatory, every task that produces user-facing output)**: User-facing = page, screen, URL, command, generated artefact a person consumes — not internal modules, refactors, or schema migrations. For each such task, produce TWO outputs *before* the compliance gate. They are complementary: the boss demo forces narrative concreteness; the regret scenarios force adversarial generation. A leaf-only slice that survives one tends to die in the other.

**Output A — Boss demo**: a scenario in which you call your senior stakeholder into a meeting, hand them the running product, and ask them to find and exercise the new capability *themselves*, *after only this task has shipped*. Specify:

1. The opening prompt you give them ("Find me the wireless headphones." / "Try the postal-code validator." / "Show me which orders qualify for free shipping.").
2. The exact sequence of *their* actions — clicks, typed input, commands — starting from the **product's own entry surface** for this kind of feature. Surface depends on artefact:
   - UI page / screen → in-product navigation: home page, menu, index page, in-product search, sitemap, or a workflow that lands here.
   - CLI feature → root command + `--help`, or the discoverable subcommand listing.
   - API endpoint → the consumer's real catalog / OpenAPI doc / SDK surface.
   - Generated artefact (file, export, report) → the real output path or catalog the consumer already uses.
   - Library / module → the package's public surface (`__all__`, exported index, documented import path).

   **README / changelog / docs are supporting evidence, not entry points — where the product has an in-product surface at all.** A page mentioned only in README but not linked from the site is still a leaf. Not your steps as the developer; the boss's steps as a first-time user.

   **Applicability**: where the product has no surface other than what a reader opens — a library consumed by import, a framework distributed as files, a documentation site — the README or docs page *is* the entry point, and wiring it means linking it from wherever a reader actually arrives. Declare which case applies rather than assuming; a rule written for executables silently fails every repo that is not one.
3. What they see at the end.

**Output B — Three "we'd regret shipping ONLY this task" scenarios**, written as real-world phrases, not test cases. Same structure as the walking-skeleton adversarial pass at `[x]` time — and the reason it works here is the same: it forces *generation* of failure modes, which is harder to fake than narrating a smooth demo. If any scenario reads "the new thing exists but no one can find / use / hear about it" → re-cut.

**At least one of the three MUST be a cross-cut, not a within-task bug.** State the product after *"ship every task except this one"* and after *"ship only the tasks before this one."* "Coherent, just less capability" → legitimate additive scope (fan-out, keep). "The product contradicts itself / its catalog lies / a half-built capability ships" → this task is the missing half of another; merge. A within-task quality regret ("the feature has a bug", "INBOX miscategorised") does NOT satisfy this — the regret must be about what the CUT leaves behind. This is the check that catches exposure-only and per-surface-severed tasks, which the boss demo and within-task regrets wave through.

**Re-cut triggers** (apply to either output):

- **"There's nothing to see yet — that'll come N tasks later."** → leaf-only slicing. Re-cut to ship something the boss can reach today.
- **"I can't find it from the menu — here's the URL."** → discoverability deferred. Re-cut to include the **in-product** discoverability surface (menu entry, index page, sitemap inclusion, root-command help, catalog/index entry — see Output A's surface list) in the *same* task. README additions don't count; they're supporting docs, not product navigation.
- **"Now pretend the navigation link is there..."** → pretending bridges the gap = horizontal scaffolding in plain clothes. Re-cut.
- **"It works, but I called you in to see one button."** → too thin. Merge with adjacent task or surface a larger payoff. (Overlaps with Underwhelm test; both fire.)

If the boss can't get from "Find me X" to "ah, here it is" through their own actions on the running product — OR if any of the three regret scenarios reads "exists but unreachable" — the task is not a vertical slice. It is a leaf labelled as one.

Known failure mode: **leaf-only slicing**. Task ships a renderable page or generated artefact; menu entry, index link, or sitemap inclusion gets sequenced to a later task. Sounds reasonable ("content first, navigation later"), IS the well-trodden pattern in training data (MVC layering, "data layer first", "scaffolding then polish"), and IS horizontal scaffolding wearing a slice's clothes. The forbidden-words list in `ws._meta` § Slicing must never be justified by architecture catches *justification* language (`skeleton-then-flesh-out`, `walking-skeleton-with-deferred-X`) but not plain-English equivalents like "don't open discoverability until content is complete" — same antipattern, different words. The two outputs catch it two ways: the boss's narrated actions cannot reach the new artefact without the LLM noticing the gap mid-walkthrough; the regret scenarios cannot be honestly enumerated without one of them reading "exists but no one can find it." A smooth demo papered over the gap? The regret scenarios should still surface it. Vague regret scenarios that miss the gap? The boss demo should still trip on the unreachable click. Both fake at once would require the LLM to actively lie in two complementary registers — much higher friction than letting one slip.

Known failure mode (mirror): **exposure-as-its-own-task**. Real case — an alias-resolution feature sliced as: Tasks 1-2 deliver the resolver and wire it into the message tools; Task 3 "rebuild `list_folders` to advertise the aliases." Task 3 passed every per-task check — `list_folders` is independently demoable, "wires into prod" was literally yes, and its three regret scenarios were all internal bugs (miscategorised INBOX, phantom rows, weak wording). It was still horizontal: the discoverability-half of the capability whose behaviour shipped in Tasks 1-2, leaving a window where the agent's own catalog taught the localized folder names while the tools wanted the aliases. The cross-cut regret that kills it — "ship 1-2 without 3 → the catalog contradicts the tools" — was never generated, because per-task checks cannot see cross-task severance. Caught only by the human. This is why the cross-cut regret (Output B) and the separate-context review (below) are mandatory, not the per-task demo.

**Verify before sequencing**: Ordering relies on assumption ("X unavailable")? Verify first -- filesystem, dry-run, test connection. 30-second check costs nothing; unverified assumption pushes feedback back days. Example: "BDD can't run" -> check dependencies exist. Present? BDD runs now. Missing? Tell user. Principle: **never sequence around unverified constraint.**

**Separate-context slice review (mandatory, before the compliance gate)**: Self-review shares the slicing blind spot — the same context that sliced per-surface also writes the regret scenarios, blind in the same place, so it validates its own cut. Break that loop: the cut MUST be reviewed by a context that did not author it, given **only** task titles + one-line goals + surfaces-touched — NOT your justifications, ledger, or rationale. Single instruction: *"For each task answer: is its entire payload exposing/advertising/cataloguing/documenting a capability another task delivers? Do any tasks split one capability across surfaces (one per tool / endpoint / file / screen)? List every task that is exposure-only or per-surface-severed with one reason each, else reply NONE."* A reviewer with no stake and one sharp question catches what invested self-review misses. Fold its findings (merge flagged tasks) before producing the compliance table. This is the highest-leverage check here — prose guardrails the authoring context skims; a differently-framed reader with no stake does not.

<!-- WS:DEFAULT independent-review-agent -->
The recommended way to obtain that independent context is a fresh subagent (the Agent tool), handed the titles-goals-surfaces list above with an explicit instruction: *"Proceed as if you have no knowledge of prior context — review only what is handed to you."* Where the runtime offers no subagent, fall back to a clean-context second pass — a freshly-cleared session fed the same list and the same instruction, so it cannot see (and rubber-stamp) the authoring rationale — and escalate to a human checkpoint when the stakes are high (irreversible cuts, money/commitment surfaces, or a "NONE" verdict on a large slice). Label this fallback's evidence **self-review fallback**, not independent review: it removes visible context, but not the authoring session's blind spots, habits, or unstated assumptions carried into the fresh pass — the thing genuine independence buys and this cannot. Never skip the review and never block on the mechanism: the requirement above is the invariant; the subagent is the default means.
<!-- /WS -->

#### STOP Gate: Vertical Slice Compliance, then Present

**This is the single sign-off gate, in one order: compliance first, then present.** Do not present the task list until compliance passes. Produce compliance table:

```
VERTICAL SLICE COMPLIANCE
| Task | Tests green after? | Breaks unfixed? | Wires into prod? | Demo? | BDD advanced? |
|------|--------------------|-----------------|-------------------|-------|---------------|
| 1    | [which tests]      | [no / what]     | [yes/no/N/A]      | [concrete demo] | [which / N/A] |
```

**Gate rules -- violation = restructure:**

1. **"Tests green?" blank** -> merge into adjacent task or add verification
2. **"Breaks unfixed?" not "no"** -> fold fix into *this* task
3. **"Wires into prod?" = "no" / "later task" / names a future task** -> unwired = horizontal; the task must connect the new artefact to BOTH (a) the code path that runs in production (imports, routes, registrations) AND (b) the **in-product** user-discoverability surface for this kind of feature (UI page → menu / index / sitemap; CLI feature → root help; API endpoint → catalog; generated artefact → real output path or index — see Reachability pass Output A for the surface list) — in the same task. README / changelog / docs are supporting evidence, not substitutes for in-product wiring. Internal-only tasks (refactor, plumbing, schema migration) write "N/A — no user surface" and skip the user-discoverability half. User-facing tasks failing either half must absorb the missing wiring; deferring discoverability to "Task N+k" = leaf-only slicing (see Reachability pass under §Validate Sequencing).
4. **"Demo?" blank / "run tests"** -> merge into demonstrable task. Qualifying: "open page, see X" / "run command, see Y". NOT: "pytest passes"
5. **"Demo?" fails underwhelm test** -> merge thin tasks or surface user-facing change
6. **"BDD advanced?" blank** -> restructure. Every cell is either progression evidence (which scenario, red-to-green) or the task's own `BDD decision: do not use — <reason>` cited verbatim — never a bare blank, and never excused by being a single occurrence.

**Rejected shapes**: "connect/wire previously built components" / "update fixtures for earlier changes" / "write BDD tests" near end / stubs with no backing behavior.

Re-run compliance after restructuring. Repeat until clean. State changes: "Merged Task 7 into 1 because..."

**Only once compliance is clean, present** the task file for sign-off — Slice Ledger first, then the Involvement Summary, then enough task detail to judge the levels. STOP. Wait for user approval or adjustments before writing the final task file or starting `/ws.4-run`. There is no earlier "present" step; this is the one gate.

## Output Structure

Write to `tasks.md` (or `specs/<feature>/tasks.md`). Multi-slice: `tasks-<slice>.md`.

```markdown
# Tasks: [Feature Name] -- [Slice Name if multi-slice]

## Implementation Constraints
**Permitted**: Libraries: [list] / Patterns: [list] / Files: [scope]
**Not Permitted**: [constraints]
**Style**: [project conventions]

## Slice Ledger
| # | User-job (what someone DOES) | Surfaces touched | Distinct slice because… |
|---|------------------------------|------------------|-------------------------|
| 1 | [a thing the user/operator does] | [surfaces] | [user/operator-term reason — no layer/component/surface nouns] |

## Involvement Summary
| Task | Level | Focus | Rationale |
|------|-------|-------|-----------|
| 1 | pair | [ACs] | [why] |
| 2 | autonomous | -- | [why] |

## Walking Skeleton

### Task 1 [pair]: [Name]
- [ ] **Goal**: [achievement]
- **Focus**: [ACs needing scrutiny -- omit for autonomous]
- **Touches**: [files]
- **Depends on**: None
- **Parallel**: yes (alongside Task 4)
- **Acceptance**:
  1. [Criterion] -- **Demo**: [command + observation]
- **Reachability** (required for user-facing tasks; non-user-facing: `N/A — <reason>`):
  - **Surface**: [in-product entry point added by this task — e.g., "menu item Shop > Headphones added to top nav", "`cli foo bar` listed in root `--help`", "endpoint listed in `/openapi.json`"]
  - **Boss demo**: [opening prompt → boss's actions step-by-step from the surface above → what they see, written out verbatim, e.g., "Tell boss: 'Find the wireless headphones.' Boss lands on `/`. Clicks `Shop` in top nav. Sees `Headphones` category. Clicks. Sees product list with N entries."]
  - **Three regret scenarios**: 1. [scenario] 2. [scenario] 3. [scenario]
- **Tests green after**: [specific tests]
- **BDD decision**: use | do not use — <reason>  (see § BDD decision)

### Task 2 [autonomous]: [Name]
- [ ] **Goal**: [achievement]
- **Touches**: [files]
- **Depends on**: Task 1
- **Acceptance**:
  1. [Criterion] -- **Demo**: [command + observation]
- **Reachability**: [as Task 1, or `N/A — <reason>` for non-user-facing]
- **Tests green after**: [tests]
- **BDD decision**: use | do not use — <reason>  (see § BDD decision)

**INTEGRATION MILESTONE**: After Task 2, verify [point]

## Remaining Tasks
### Task 3 [checkpoint]: [Name]
[same structure]

## Backlog (Deferred)
- [Item] -- [why deferred]
```

## Behaviors

### Task Sizing

Default size: **30 minutes to 2 hours** of focused work. Below 30 min → merge with neighbour. Above 2 h → split *only* if the split passes the slicing-justification rule in `ws._meta` (no technical-layer splits). Verifiable completion ("X does Y", not "work on X"). Vague = too big.

**No sub-tasks at planning time.** `tasks.md` is a flat list (1, 2, 3, …) — never `2a/2b/2c`. Letter suffixes are an *execution-time* numbering tool only: preserve stable numbering when drift during Task 2 forces inserting a new item (record as `2a` so `3` still refers to the same work). Sub-tasks proposed at planning time are LLM sprawl — merge or restructure before presenting.

**Granularity test before presenting:** read each task's Goal aloud. If it sounds like a step *inside* a larger task ("wire X", "configure Y", "add fixture for Z") rather than a unit the operator narrates ("the order lands in the fulfillment queue"), it's too granular — merge.

Anti-example (narrated, not a shipped example — the original was private case-history): a skill-artefact slice decomposed into four tasks along technical-layer lines (schema → meta → book → exercise). Not separable for a skill artefact; produced churn that single-pass authoring would have avoided.

### Outside-In Over Bottom-Up

When feature has operator/user interface, **prefer outside-in**:
1. **Each task delivers working subcommand/endpoint** — interface + behaviour in same task. Not "skeleton now, guts later."
2. **Each task = verifiable behaviour** — BDD scenario goes green / operator runs command / coherent section reviewable. Stubs nothing verifies = horizontal.
3. **Validate dependencies early** — external deps become first real subcommand.

**Stub trap**: "Build CLI skeleton first" = horizontal layer. First task = first *real* subcommand end-to-end.

**Bottom-up smell**: Can operator get real result after first task? "Not implemented" → no. Health check showing deps → yes.

**BDD-worthy features**: draft `@todo` scenario titles in `.feature` alongside task file. Scope to next 1-2 tasks only — 13 failing scenarios from day one = no signal. Later batches via `/ws.tdd.idea` just-in-time. Task goal "write BDD tests for feature" → bottom-up smell: BDD = outer loop *before* `/ws.4-run`, not capstone.

### BDD decision

Every drafted task records exactly one line — `BDD decision: use | do not use — <reason>` — never silently omitted. One applicability test decides it: *does this task introduce a new user-facing behavioural contract?* Not "no observable behaviour changes" — a task with no observable result at all is a slicing smell (see § Validate Sequencing → Skip test), not an exemption.

- **Introduces a new user-facing behavioural contract, with an automatable boundary** → `use` by default; it drives the outer loop unless the user explicitly overrides.
- **Introduces no new user-facing behavioural contract** (prose, config, a doc, a design artefact, or work with no executable boundary at all) → `do not use — not applicable: <reason>`.
- **Behaviour-preserving** (refactor, mechanical migration, internal reorganisation — no *new* contract, but an *existing* one crosses the change unchanged) → `do not use — behaviour-preserving: <reason>`. This still owes **observable equivalence evidence**, never a free pass: a baseline captured *before* the change, compared against the result *after*. "Already protected" means tests existed *before* the change, or a characterisation baseline was captured *before* it — a test written after the change that passes immediately proves nothing (a baseline captured at completion is not a baseline). Capture happens at task drafting (when the pre-change state is already inspectable) or, failing that, at the start of `ws.4-run`'s implementation loop for this task — before the change begins, never after. Record it as an Acceptance sub-bullet (`- [ ] N. Behaviour-preserving: <what was captured, e.g. "existing suite green pre-change" or "characterisation run: <command> → <output>"> — **Demo**: <post-change comparison command + result>`), so the task's own AC sub-bullet coverage gate (`ws.4-run` § Completion Evidence) enforces the post-change comparison the same way it enforces every other AC — no separate mechanism needed.
- **Explicit user override** of an otherwise-BDD-worthy feature → `do not use — user override: <reason>; replacement evidence: <real invocation/demo>`. Replacement evidence is mandatory on an override — a real invocation or demo, not a description of one:
  ```text
  BDD decision: do not use — user override: one-off script;
  replacement evidence: <real invocation/demo>
  ```

**Invalid reasons, standing alone:** small, inconvenient, slow setup, unit tests already exist, behaviour is obvious. None of these answers the applicability test; each needs a real reason from one of the four lines above, or the decision is incomplete.

"Full verification command" and "BDD policy" are separate contracts — one command cannot represent both.

<!-- WS:EXAMPLE bdd-onboarding -->
**Onboarding** (Claude-Code adapter example, not CORE): when the user has no prior BDD policy or asks, the decision point first offers a one-line explanation — "BDD writes the user-visible behaviour as Given/When/Then scenarios that go red before code and green when it works; worth it for executable features with a checkable boundary, skip it for prose/config" — plus a guided pick, before recording the line. Keep it to that one line to protect the always-loaded budget.
<!-- /WS -->

### Parallel-Safe Tasks

No unfinished dependencies = parallel-safe. Add `**Parallel**: yes (alongside Tasks X, Y)`. See `ws._meta/parallel-work.md`.

### Technical Debt Cleanup

Debt from plan/implementation: cleanup in task that created it. Trivial (<5 min) = same task. Substantial = dedicated task immediately after. "Clean up later" = "never."

### Level 0 Additions

Trivially small follow-up discovered (<5 min, 1-2 files): fold into current task.
```markdown
- **Level 0 addition**: [description] (discovered during implementation)
```

### Walking Skeleton Must Test Real Path

Walking skeleton verifying third-party integration: acceptance criteria require **actual system's UI/API**, not simulated equivalent. Convenient test over informative = **higher-order success theater**. Walking skeleton surfaces integration surprises early; shortcuts defeat this.

**Rule**: "Verify how system X sends data" -> test uses X's actual UI/workflow. Setup difficulty = information (riskier integration), not reason for easier test.

### Documentation as Deliverable

Feature with operator/user interface: docs are implicit deliverable -- AC on interface tasks, not separate task.

Task entry names the relevant operator doc: `- **Documentation**: docs/<area-or-workflow>.md (from ws._meta/workflow-doc.md template when applicable)`

BDD `@docs` scenario verifies doc exists. Written incrementally during `ws.tdd.green`.

**Rule**: Task builds something operator runs -> ACs include doc path. Missing = not done.

### What NOT to Do

- Tasks for "might need" features / sequence for "easy" not feedback / batch verifiable-independently tasks / split feature from operational surface / defer docs to "write docs" task / **ship a user-facing artefact with discoverability (menu, index, link) deferred to a later task — leaf-only slicing, see § Validate Sequencing → Reachability pass** / **make exposure its own task (advertise/catalog/document an ability another task delivers) or slice one capability per surface (tool/endpoint/file) — see § Validate Sequencing → Severed-capability test**

## Tracker Sync

Tasks ready = work committed. First resolve the work ledger (`ws-binding get work-ledger`; see `ws._meta` § Work-ledger binding): `local` → the task file itself IS the durable committed record (stable numbers = identity, `[x]`/`[~]` = state); no external issues — skip the rest of this section. When a tracker is bound, make the work visible there at the org's granularity:

**Issue exists**: Verify scope matches. Shifted during planning -> suggest updates.

**No issue**: Propose structure:
```
epic: "[Feature]" -- links to specs/<feature>/
issue 1: "[summary]" -- maps to tasks 1-N
issue 2: "[summary]" -- maps to tasks N-M
```
One issue per logical group. After confirmation, create tracked issues, update `requirements.md` / `umbrella-requirements.md` with refs.

## Transition

### Before the STOP gate (mandatory)

From `ws._meta`, not optional:

1. **Compaction pass** — re-read and cut. Target ≥ 20% on first pass (`ws._meta` §Condensation is a deliverable).
2. **Attention-budget check** — ask: *"Is this still shorter than your attention span for one sitting?"* (`ws._meta` §Attention Budget).
3. **Size ceiling** — check against `ws._meta` §Artefact size ceilings for `tasks.md`. Past hard cap → *merge over-granular tasks* or *split scope*, not "umbrella by reflex".

### Readiness checklist

- [ ] Walking skeleton first
- [ ] Each AC has a concrete demo
- [ ] Dependencies explicit
- [ ] First integration milestone marked
- [ ] Every task names one capability as a concrete observation — what is run, what is seen, what would count as wrong. A property nobody can look at ("patterns are distinguishable", "it's robust") is not testable: restate as an observation or cut.
- [ ] Compliance table clean
- [ ] Severed-capability/exposure test run on every task; no exposure-only or per-surface-severed task survives
- [ ] Cross-cut regret written for each task (Output B): "ship all-but-this" / "ship only-before-this" stated; none reveals a contradiction/half-built capability
- [ ] Separate-context slice review run (fresh subagent by default, or a clean-context second pass when no subagent; titles+goals+surfaces only); findings folded
- [ ] Slice Ledger present and presented first; every User-job is a thing the user does (no advertising/exposing rows), no surface scattered across tasks
- [ ] Reachability pass persisted per user-facing task in tasks.md (Surface + Boss demo + three regret scenarios written into each task entry; non-user-facing tasks have explicit `N/A — <reason>`); no re-cut triggers fire
- [ ] Tests + BDD fields filled
- [ ] Involvement summary approved
- [ ] Doc paths named (BDD)
- [ ] Tracker reflects work
- [ ] Compaction pass run
- [ ] Attention-budget check passed

Ask: "Ready to start? Run `/ws.4-run 1` for first task." Multi-slice: `/ws.4-run` discovers task file if only one `tasks*.md`.

## During Implementation

As tasks complete: mark done / note discoveries for `/ws.refine` / add deferred to Backlog / update the tracker at milestones (not per-task).

**Drift detected**: (1) Stop. (2) `/ws.refine`. (3) Continue only after specs updated.

## After All Tasks Complete

Run `/ws.9-retro` when done / merged / before next feature. Don't skip.

### Multi-Slice: After Slice Completes

1. `/ws.9-retro` scoped to slice (`retro-<slice>.md`)
2. Update slice status in `umbrella-plan.md`
3. Next: `/ws.3-tasks` (next slice) / `/ws.sweep` (verify integration) / `/ws.9-retro` full (all complete)

Slice retro asks: "Outcome affect upcoming slices?" If so, update umbrella specs first.
