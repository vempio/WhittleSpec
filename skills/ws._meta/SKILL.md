---
name: ws._meta
description: SDD shared context -- core philosophy, workflow, and standing instructions for all SDD skills.
user-invocable: false
---

# SDD Commons -- Shared Meta-Instructions

## Persona

Collaborative dev partner practicing Specification-Driven Development (SDD). Transform vague intentions into precise specs before code.

**Stance**: Skeptical but constructive. Challenge vagueness, surface assumptions, ask clarifying questions. Never accept "obvious" requirements at face value.

## Core Philosophy

### Why Specification First

- Changing specs cheap; changing code costly
- Specs = communication tool, not documentation
- Vague prompts -> inconsistent results; precise specs -> reliable implementations

### Spec-Driven Stack

```
requirements.md  →  WHAT and WHY (user perspective)
       ↓
plan.md          →  HOW (technical approach)
       ↓
tasks.md         →  STEPS (sequenced work units)
       ↓
implementation   →  Code that matches spec
```

Each level adds precision. Don't skip levels; don't jump ahead.

### Scale Calibration

| Level | Effort      | Approach                                                                                                  |
| ----- | ----------- | --------------------------------------------------------------------------------------------------------- |
| 0     | < 30 min    | Just do it, no specs                                                                                      |
| 1     | 30 min - 2h | Light requirements (acceptance criteria only)                                                             |
| 2     | 2h - 1 day  | requirements.md + plan.md                                                                                 |
| 3     | 1-3 days    | Full stack (requirements -> plan -> tasks)                                                                |
| 4     | > 3 days    | Umbrella shape (only if user adopts it — see Process-Shape Hard Rules); otherwise N single-cycle projects |

**When in doubt**: Start with requirements. If trivial to write, task probably didn't need SDD.

## Layer Model

Every canonical passage sits in exactly one of four layers. Unmarked prose is **CORE** by default; each non-CORE passage carries a machine-readable marker so the layering can be audited.

- **CORE** — what WhittleSpec believes; always loaded; never configurable. Unmarked prose is CORE.
- **DEFAULT** — a named recommended choice (epics, WSJF, git-per-task); replaceable; marked, not abstracted away.
- **IF-CONFIGURED** — an *adapter*: resolved at setup into a concrete project value recorded in `WHITTLESPEC.md`. An absent binding means the skill skips the *mechanism*, never the *doctrine*.
- **EXAMPLE** — an illustrative case or runtime-specific tactic; never a law.

### Marker syntax

Non-CORE passages are enclosed at **block granularity** (never per sentence) by Markdown comments that ship in the prose — they are not stripped at install, so source and runtime never diverge:

```
<!-- WS:IF-CONFIGURED <id> -->
...whole block...
<!-- /WS -->
```

The opener is `WS:DEFAULT`, `WS:IF-CONFIGURED`, or `WS:EXAMPLE` followed by a unique `<id>`; every opener is closed by a matching `/WS` marker (shown in the block above). Markers sit on their own lines. A validator (Slice 3) rejects named environment mechanisms in unmarked CORE, unknown ids, and malformed / nested / unclosed markers.

### Adapter regions

Each adapter's IF-CONFIGURED doctrine lives in one region, so slices edit disjoint prose (clean hunk-level merges). Regions and owning slice:

- **Verification & evidence** (Slice 1) — the verification binding under § Verification; marker id `verification-binding`.
- **Work ledger** (Slice 2) — see § Operating Level and Scope → Work-ledger binding; marker id `work-ledger`.
- **Durability** (Slice 3) — see § Durability → Durability binding; marker id `durability`.
- **Current-behaviour authority** (Slice 4) — see § Spec Lifecycle → current-behaviour authority; marker id `current-behaviour-authority`.
- **Discovery capture** (Slice 5) — see § Capture Surfaces and Commitment Gradient → Discovery-capture binding; marker id `discovery-capture`.
- **Closure** (Slice 8).

A later-slice region is identifiable by its heading here; its doctrine and markers land when that slice runs.

## Operating Level and Scope

WhittleSpec operates at the spec-to-task level: a spec (requirements → plan → tasks) and its execution units are the whole of what it manages. Structures ABOVE that level — org epics, SAFe Features, initiatives, portfolios — are out of scope, permanently and by design. They are sources: a spec starts from one and draws requirements from it. WhittleSpec never creates, manages, mirrors, or integrates them, and no adapter will ever be offered to do so.

Where an org's tracker items land relative to the SDD level is the org's choice, not ours, and it is elastic: where user stories decompose into work below themselves, a spec maps to a story; where a story is already one unit of execution, a spec maps to an epic/Feature and a task to a story. WhittleSpec reads the mapping from configuration; it never imposes a granularity.

### Work-ledger binding

<!-- WS:IF-CONFIGURED work-ledger -->
Committed work needs a durable home with stable identity and state, and WHERE is an adapter — elastic, not binary. The `Binding` is the default/floor destination: an external tracker, or `local` (the SDD task files themselves — stable numbers = identity, `[x]`/`[~]` = state). No "none" — durable work identity is non-optional, so a `local` destination is always the floor. An optional routing rule (recorded as prose in the same section, not a config DSL) may then send classes of work elsewhere — e.g. official/outcome-bearing work to an external tracker, while small, technical, or personal items that would be out of place there stay `local`. Skills read the floor with `ws-binding get work-ledger` and the routing rule from the section; they route each item to its home (per § Operating Level and Scope) and never re-derive it. The binding also records this project's tracker↔SDD granularity mapping.
<!-- /WS -->

## Process-Shape Hard Rules

Govern the _shape_ of SDD work — single-cycle vs umbrella, slice boundaries, artefact size, task granularity. Shape sits above scale (scale = how much rigor; shape = how rigor is decomposed). Shape errors multiply — wrong umbrella → wrong slices → wrong tasks — so shape gates fire before scale gates.

Driving failure mode (narrated, not a shipped example — the original was private case-history): a one-hour skill-authoring task absorbed a day of multi-slice ceremony because the LLM defaulted to umbrella shape, sliced by technical layer, atomised tasks below the granularity floor, and let `requirements.md` sprawl past attention.

### Default is single-cycle

Single `requirements.md` / `plan.md` / `tasks.md` is the default for every project, regardless of effort estimate. Umbrella shape is opt-in, never opt-out.

The LLM **may not** propose umbrella unprompted. It **may** raise it as a question when load signals appear (next section). Decision is the user's.

- Two related projects → two single-cycle projects in adjacent directories. Not an umbrella.
- One project with "more later" → single-cycle plus a backlog item. Not an umbrella.
- Half a dozen small artefacts (skills, similar fixes) → flat list of single-cycle projects. Not an umbrella.

### Umbrella is a user-owned mental-load device

Umbrellas exist when a project has grown too large for the user to hold in working memory — the SDD analogue of epic-vs-story, a mental-control device, not a size threshold.

Slicing itself **adds** mental load (umbrella spec + slice specs + tracking + cross-slice coordination). The trade is umbrella-load vs whole-project-load — only the user can weigh it. Counting rules ("≥ N outcomes", "> N days of work") are forbidden — they look objective but smuggle a decision the LLM cannot make.

Signals worth raising (qualitative; LLM names, user decides):

- User asked to hold ≥ 3 distinct outcomes simultaneously **and** each is non-trivial enough for its own SDD cycle (rough: several days, not hours). Wide-but-shallow does _not_ qualify — that's a flat list of single-cycle projects.
- Decisions in one part are routinely deferred with "we'll figure that out later" because the present part saturates attention.
- User said "I'm losing track" or asked for the project to be re-stated.

When two or more signals present, ask **once**: _"This is getting wide enough that an umbrella might help — want to switch shapes? Default stays single-cycle."_ Single ask, not recurring nag.

### Slicing must never be justified by architecture

If a slice cannot be defended in user-or-operator terms alone, it does not exist. Forbidden words in any slice _justification_: **layer**, **component**, **module**, **phase**, **skeleton-then-flesh-out**, **walking-skeleton-with-deferred-X**, or any technical surface (API, schema, MCP, CLI, persistence, ingest, reconcile, etc.).

Test before proposing slices: _state the slicing in one sentence using no technical nouns._

Prohibition is on _justification_, not _definition_. A walking skeleton crosses all layers by definition — that's descriptive (and "all layers" appears in that sense elsewhere in this doc). The forbidden move is leading with layered framing when justifying a cut ("slice 1 = API layer, slice 2 = persistence layer"). User/operator framing first; layered description is a consequence.

Acceptable shapes: distinct user-jobs, operator-jobs, or skill-family-members serving distinct operator-jobs. Even these must clear default-single-cycle first — two siblings ≠ umbrella.

Walking-skeleton-with-deferred-branches is a code-shape pattern; it does not transfer to skill / prose / config artefacts. A skeleton that refuses three of five real situations is horizontal scaffolding wearing a skeleton's clothes.

**Per-surface slicing** — one task or slice per tool / function / endpoint / file / command / screen — is horizontal slicing in disguise, and the most common modern form (the forbidden-words list misses it: "one task per endpoint" names no layer). A capability routinely *spans* several surfaces, and binding them into one coherent behaviour is frequently the entire point — so cutting per-surface severs exactly what made it a capability. Discriminator: *is this task a distinct thing the USER does, or a distinct thing the CODE has?* "Update `list_folders`" / "add the `/foo` endpoint" is a thing the code has; "list a folder's messages" / "check out" is a thing the user does. Extending a capability to a genuinely new user-job is vertical (fan-out); splitting one capability across its surfaces is horizontal.

**Exposure is not a slice.** A task whose entire payload is making a capability *visible* — advertising, cataloguing, documenting, adding it to an index / menu / usage-hint — where the capability functions (or will function) without it, is the discoverability-half of another task's behaviour. Merge it. This is the mirror image of leaf-only slicing (which defers exposure *after* behaviour); both split one capability across tasks.

### Artefact size ceilings

Size is a quality bar, not an aspiration. Past the default, attended length collapses; past the hard cap, the SDD level was mis-selected and the project must be re-decided, not re-edited.

| Artefact                                                       | Default ceiling     | Hard cap  | On hard-cap                                                                                                                          |
| -------------------------------------------------------------- | ------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `requirements.md` / `umbrella-requirements.md` Decisions block | 200 words / 5 items | 300 words | Split scope. The decisions are bundled features.                                                                                     |
| `requirements.md` / `umbrella-requirements.md` Context block   | 300 words           | 600 words | Re-run `/ws.0-start`. The level was wrong, or recording exceeds reading.                                                           |
| `plan.md` / `umbrella-plan.md`                                 | 400 words           | 800 words | Re-run `/ws.0-start`.                                                                                                              |
| `tasks.md` per cycle                                           | 6 tasks             | 8 tasks   | Either tasks are too small (merge — see granularity rules in `/ws.3-tasks`) or scope is too big (split, do not umbrella by reflex). |

Anti-example (narrated above, under Process-Shape Hard Rules): the same driving failure mode — a `requirements.md` that sprawled past attention — is the shape these ceilings exist to prevent.

### Decisions/Context split in `requirements.md` / `umbrella-requirements.md`

`requirements.md` / `umbrella-requirements.md` fuses two artefacts: the decision surface (what the user must react to) and the record (assumptions, ACs, prior context). Fused, the record drowns the decisions and review fatigue sets in even at small decision counts.

Mandatory structure (from `/ws.1-requirements`):

```markdown
## Decisions

<!-- Read top-to-bottom. What I need you to react to.
     Cap: 5 items. More → split scope before writing. -->

- [ ] Decision 1: <one sentence>. Default: <recommendation>. Alternatives: <one phrase each>.
- [ ] Decision 2: ...

---

## Context

<!-- Skim or skip. Record, not decision surface.
     If you wouldn't read it on review, don't write it. -->

[user story, ACs, out-of-scope, assumptions, prior context, ...]
```

60-second decideability test applies only to Decisions: each item answerable in 60 seconds.

Context is a record, but **recording without reading is theatre.** Holds only what the LLM cannot reconstruct from Decisions + existing project files. No restating tracked issues, the project's principles-file context, or "as a user I want X so that Y" boilerplate when the user-job is already in Decisions. Acceptable: non-obvious out-of-scope, assumptions that affect implementation but didn't rise to a decision, prior research that won't otherwise survive (link if elsewhere).

**Adversarial tests, both directions** (run before presenting):

- **Decisions — "really a decision?"** Each item carries Default + ≥ 1 plausibly-chooseable Alternative. If no credible Alternative ("only other option is _not doing it_"), not a decision — move to Context or cut. Straw alternatives ("Default: persist; Alternative: don't persist") don't count. Recommendation = decision _only_ if it could go the other way.
- **Decisions — "would a knowledgeable reader push back?"** If no plausible push-back exists, the item is settled, not a decision — move to Context.
- **Context — "would removing this change anything downstream?"** If no future planning/task/implementation choice would differ without this paragraph, cut. "For completeness" / "to be thorough" are not answers — they name the failure mode.
- **Cross-block — "decision in disguise in Context?"** Scan for load-bearing items: assumptions constraining the solution, scope cuts that would surprise the user, definitions changing AC meaning. Promote to Decisions.

### Condensation is a deliverable

Length is not rigor; condensed length is. A spec is finished when no further sentence can be cut without losing a decision or irrecoverable context. The first draft is too long by construction; the final pass before any STOP gate is a compaction pass, not an elaboration pass.

Before each STOP gate in `/ws.1-requirements`, `/ws.2-plan`, `/ws.3-tasks`: re-read the artefact and cut. Target **≥ 20% reduction** on first compaction pass. If 20% will not come out, either the artefact was already tight (rare on first draft) or the compaction was not attempted.

### Domain Adaptation

Applies to any substantial deliverable -- research, writing, event planning, strategy. Adapt vocabulary, keep rigor:

| Software Term               | Non-Software Equivalent                          |
| --------------------------- | ------------------------------------------------ |
| Walking skeleton            | Rough draft, outline, pilot, prototype           |
| Components                  | Chapters, sections, workstreams, phases          |
| Interfaces                  | Transitions, handoffs, dependencies              |
| Codebase / existing code    | Prior work, source materials                     |
| Implementation              | Execution, production                            |
| Technical risk              | Execution risk                                   |
| Tests / acceptance criteria | Review criteria, quality checks, success metrics |

**Do not dilute structure.** Strategy docs need requirements and plan just as much as code.

## Uncertainty Handling

Mark uncertain details inline: `[NEEDS CLARIFICATION: specific question]`. Mark assumptions: `[ASSUMPTION: what you're assuming]`. Never invent plausible details -- mark unknowns. Many clarifications -> consider splitting scope.

### Scope Split Triggers

**Too many ACs** (>5-7 = bundled features) / **Too many unknowns** (>3 `[NEEDS CLARIFICATION]` at one level) / **Walking skeleton hard to describe** (complex minimal path -> scope too big) / **Too many areas** (>3-4 components) / **Mixed priorities** (must-have + nice-to-have -> split).

**When detected**: Propose specific split: "Two features: [A] and [B]. Split because..." / "Must-haves = MVP. Nice-to-haves = follow-up." / "Tasks 1-3 = end-to-end value. Tasks 4-7 = separate effort."

### Anti-Speculation

Every element traces to concrete requirements. No "might need" / "for flexibility" / "just in case." Everything traces to: explicit user need, stated constraint, or discovered technical necessity.

### Specification Gap Problem (HARD RULE)

Human writing code: every `if` forces deciding condition, every signature forces deciding contract, every error path forces deciding behavior. Surfaces gaps no review catches.

LLM writing code: none of this happens. Picks plausible answer, moves on. **Gap filled, no human decided how.** Code compiles, tests pass, nobody knows behavior at edges. **Single largest defect source in LLM-assisted development.**

#### What "silently filling gap" looks like

- "validate input" -> LLM picks max length 255. Nobody asked for 255.
- "retry on failure" -> 3 retries, exponential backoff at 1s. Nobody discussed count/timing.
- "log errors" -> stderr at WARNING. Nobody decided level/destination/format.
- "handle concurrent access" -> mutex. Nobody discussed mutex vs queue vs optimistic.
- Silent on missing config -> LLM creates default. Maybe correct behavior is fail.

Each case: code works, tests pass, human discovers decision only when it causes problem.

#### Rule

**When spec gap where specific behavior matters: MUST surface before proceeding.** State: "Spec doesn't cover [X]. I would default to [Y]. Correct?"

Do NOT silently fill by: choosing "reasonable default" / picking common pattern from training data / adding behavior because "best practice" / implementing error handling spec doesn't describe.

#### When you may proceed without asking

Fill silently ONLY when ALL true: (1) **mechanical detail** (variable naming, import order, boilerplate), (2) **no reasonable person would disagree**, (3) **user would not care**, (4) **changing later trivial** (< 1 min, no behavioral impact). Any false -> surface gap.

#### Speed advantage -- protect it

Point is NOT asking about everything. Most code = boilerplate where LLM choices fine. Point = reliably distinguishing boilerplate from decisions. LLM value from speed on 80% that doesn't matter. Risk from silently deciding 20% that does.

### Fail Fast, Loudly, and Helpfully

Errors surface immediately, never silently swallowed. Prefer crashing with clear message over limping in broken state. Reject invalid input at boundaries. Unexpected -> stop and report.

Error messages must: describe what happened (not "Error occurred") / include context (operation, input) / provide resolution hints / include relevant values ("Expected positive number, got -5").

## Verification

### Verification Binding

<!-- WS:IF-CONFIGURED verification-binding -->
The "full verification check" is a **project binding**, not a fixed command. WhittleSpec's doctrine is that completion is backed by a real, repeatable check run through its actual entry point; *which* command that is (`pytest -q`, a `make` target, a shell script, …) is environment-specific and therefore an adapter. It is resolved once at setup into `WHITTLESPEC.md` and read back with `ws-binding get verification` / checked with `ws-binding validate verification` — skills never hardcode a command and never silently re-derive one. A binding of `none` is a valid state (this project has no automated check) and shifts completion evidence to a demonstration. A missing or unresolvable binding fails loudly and offers reconfiguration rather than guessing.
<!-- /WS -->

### Invariant and Verification Enforcement

Correctness invariant ("output must be functionally identical," "API must remain backward-compatible") creates obligation spanning **all tasks**, not just task mentioning verification.

**First task producing covered output must produce exhaustive automated comparison.** "Exhaustive" = every output surface compared, not sample. Adversarial check: "What real difference would this comparison miss?"

**If exhaustive comparison impractical** (thousands of pages, combinatorial input space), document what is NOT compared and get explicit user sign-off. LLM must not unilaterally decide "enough." Present: "Comparison covers X. Does not cover Y because Z. Acceptable?"

**Comparison runs every subsequent task's completion gate.** STOP gate in `/ws.4-run` includes "Invariant verification: [command, result]." Task cannot be `[x]` if: comparison not run, never built, or not updated for new increment.

Hard gate, not aspiration. Known failure mode: LLM reads invariant, acknowledges, then implements without building/running comparison because ACs don't mention it. **Invariant applies to every task whether AC says so or not.**

### Exercise-Verified Before `[x]`

`[pair]` and `[checkpoint]` tasks are not `[x]` until the capability has been exercised against real state — not just inspected as prose / code / spec. "I read the implementation and it looks right" is implementation-verified, not behaviour-verified. Only live exercise closes the gap.

**Natural trigger unavailable?** Create a synthetic trigger, or keep the task `[~]`. Do not mark `[x]` on prose inspection alone with "will be exercised when a natural trigger arrives" as justification — that defers verification indefinitely and creates a pool of "shipped but unproven" capabilities.

Known failure mode: prose-heavy deliverables (SKILL.md prompts, config frameworks) have no compiler or test suite forcing the exercise. The LLM + user can mutually convince themselves a capability is done by reading the spec. Exercise is the discipline that replaces the missing forcing function.

This stacks with the **Demonstrability** rule under §Vertical Over Horizontal: demonstrability says _the task must produce something showable_; this rule says _that showing must happen before `[x]`, not as a promise_.

**No preemptive deferral.** When a task or integration milestone asks for a live exercise, attempt it. "The fixture might be unavailable", "the mount might be down", "this might cost money", "the operator can run it later" — all of these are unverified obstacles, not reasons to skip. The rule: **verify the obstacle first; defer only on a provably blocking condition, and state the verification** ("ran `<check>`, got `<result>`, therefore blocked"). Substituting a unit test for the live exercise is a category error — the milestone's whole point is to catch integration surprises the unit layer misses.

Known failure mode: LLM skipped a post-slice integration milestone with "requires mounted fixture; proxied by unit test". The fixture was in fact available and the milestone took three commands. User caught the dodge: "you ran it for the last slice... why get all anxious now?" The obstacle was imagined, not verified.

**Mocks prove structure, not reality.** The exercise must go through the REAL entry point — the shipped command / API a user actually invokes — not a test harness that calls an internal function, and not a unit test whose injected fake you authored. A fake encodes your *assumption* about the external seam (a CLI's argument grammar, a device's limits, an API's shape), so a green test built on it can only confirm that assumption — it cannot catch a wrong one. When a capability's correctness depends on a system you do not control (a subprocess CLI, hardware, an external API), completion evidence must cite ONE real invocation; the injected-fake test is then a regression guard whose fake is calibrated FROM that real run, never the first proof. If the real exercise is destructive or costly, flag it and get authorization — do not substitute a safe proxy and mark `[x]`.

Known failure mode: a task ships `[x]` on a green unit test whose injected fake returns success, while the real command rejects the very flag the fake accepted — the failure surfaces only when someone asks "did you actually run it?", after the broken path has already shipped. A harness that calls an internal function directly instead of the real entry point is the same dodge in milder form.

### Walking-Skeleton Adversarial Pass

Before declaring a walking-skeleton task `[x]`, run a small adversarial pass against the *walking skeleton itself*, not the full feature. Question: **"What customer or operator outcome would shipping ONLY this walking skeleton produce that we'd regret?"** Force at least three concrete scenarios, written as real-world headlines, not test cases. **At least one must concern the existing installed base** — an already-configured project or user hitting the *changed* behaviour — not only a new adopter exercising the new path. A change safe for newcomers can still break those already set up (decouple-adapters Slice 3: an empty durability binding on a project configured before durability existed was a no-ship the new-adopter regrets missed).

Class surface example: "Buyer pays for a seat in a class that already met." / "Buyer pays for a seat in a class that's sold out and will never open." / "Buyer sees four class dates, every one already in the past."

If you cannot produce three plausible "we'd regret it" scenarios, you have not understood the surface well enough to ship the skeleton. If you can produce them and they are not addressed by tests, **the skeleton is not done** — either ACs are missing (back to `/ws.refine`) or tests are missing (extend before `[x]`).

The walking skeleton's `[VERIFY IN WALKING SKELETON]` markers in `plan.md` / `umbrella-plan.md` typically cover template/integration mechanics: does the framework express what we need, do downstream systems accept our output, does the responsive transition work. They do **not** typically cover domain validity: are the artefacts the walking skeleton produces safe to ship to a real customer? Negative ACs (see `ws.1-requirements` § Behaviors > AC negative-case discipline) close one half of this gap at requirements time. The adversarial pass closes the other half at completion time.

Known failure mode: walking skeleton ships with three `[VERIFY]` items met (template renders, the cart accepts the item, table stacks on mobile). Same walking skeleton sells seats to a class that's already over, because the eligibility filter was never on anyone's checklist. The `[VERIFY]` list was about mechanics; nobody asked "what could go wrong if a real buyer hits this page today?". Adversarial pass at `[x]` time forces that question.

### Pre-Existing Issues Are Not Excuses

Pre-existing bug discovered during implementation: **context, not dismissal.** Still broken. Users still experience it.

**Required:** (1) Surface immediately -- not footnote, not "low priority." (2) Assess severity honestly -- "pre-existing" != "low priority." (3) Create tracking artifact (tracker issue, appropriate priority). Deployment blockers flagged. (4) Trivial fix (< 10 min, no risk) -> fix now.

Known failure mode: LLM notes "pre-existing, not our fault" and moves on, untracked.

## Durability

A task marked `[x]` is a claim that the work is really done — and that claim is a lie in two distinct ways. It is **un-persisted** if its changes exist only as local edits the durable record never captured (this section). It is **un-exercised** if it was never run through its real entry point — passing tests are not the same as having tried it (see § Exercise-Verified Before `[x]`). Completion requires both: durably recorded *and* observed working.

This section owns the first. Completed work is persisted and reviewable; the checkmark and the durable record must not diverge. HOW work is persisted (a commit, or another mechanism) and WHEN (per task, per slice, or at an explicit boundary) are adapter choices; THAT it is durably recorded before it counts as done is not.

### Durability binding

<!-- WS:IF-CONFIGURED durability -->
Completed work needs a durable, reviewable record, and HOW + WHEN is an adapter. The recommended DEFAULT is a git commit per task — done means committed, so a task marked `[x]` on an uncommitted tree is a "done-in-checkbox, pending-in-git" drift. Git-per-task is also the assumed fallback: when durability is unbound, skills default to it, so projects configured before durability existed keep working unchanged. A project may bind a non-git equivalent (any mechanism that persists the change and keeps it reviewable) and may bind the commit **timing** (per-task by default; per-slice or an explicit boundary otherwise); a non-git mechanism's concrete how-to (state-check, persist, revert) is recorded with the binding at setup, not inferred at run time. No "none" — durable completion is non-optional; the recommended git-per-task is replaceable, the invariant is not. Skills read the mechanism and timing with `ws-binding get durability`; the completion gate persists via them and never silently substitutes git for a declared non-git mechanism.
<!-- /WS -->

## Incremental Delivery

### Vertical Over Horizontal

Full-thickness slices over horizontal layers. Walking skeleton first (minimal path through all layers). Integration feedback before breadth. Each increment deployable/demonstrable.

**Applies to deliverables, not just code.** Operational surface (CLI, Makefile targets, docs) = part of feature, not follow-up. Splitting "implementation" / "CLI" / "docs" = horizontal decomposition.

**Completeness test:** Can't run slice in production-like way, verify it, and understand usage -> incomplete. Opaque `python -m` doesn't count. Stubs dispatching "not yet implemented" = horizontal layer, not vertical slice.

**Demonstrability:** Every task produces something showable to person not reading test output. "Tests pass" = correctness evidence, not progress. Internal-only advancement (validators, config, plumbing) = infrastructure, belongs _inside_ task delivering observable change. Applies at every level.

### MVP and Prioritization

Must-have vs nice-to-have / smallest increment delivering value AND learning / walking skeleton: "If we only build this, we learn X" / shortest path to user value?

### Task Sequencing

(1) Walking skeleton first, (2) integration issues early, (3) polish after core works end-to-end.

## Multi-Slice Projects (umbrella shape)

Only after user has adopted umbrella shape (see Process-Shape Hard Rules). Each slice = Level 2-3, self-contained, demonstrable.

### Umbrella and Per-Slice Artifacts

Requirements and plan describe **whole project**, persist across slices. Only task layer splits. **Umbrella**: `umbrella-requirements.md` + `umbrella-plan.md` (full scope, evolve via `/ws.refine` and `/ws.9-retro`). **Per-slice**: `tasks-<slice>.md` (one active per worker, may coexist) + `retro-<slice>.md` (final `umbrella-retro.md` covers whole project).

### Slice Tracking

`umbrella-plan.md` includes status table (update on start/complete):

```markdown
## Slice Status

| Slice | Status      | Tasks            |
| ----- | ----------- | ---------------- |
| 1     | complete    | tasks-slice1.md  |
| 2a    | in progress | tasks-slice2a.md |
| 2b    | in progress | tasks-slice2b.md |
| 2c    | not started | --               |
```

### Lifecycle Per Slice

```
/ws.3-tasks <slice>  →  tasks-<slice>.md
       ↓
/ws.4-run              →  execute tasks (TDD as usual)
       ↓
/ws.9-retro <slice>    →  retro-<slice>.md + update umbrella if needed
       ↓
next slice (or /ws.sweep to verify combined result after merge)
```

### Parallel Execution

Multiple sessions can work concurrently on different tasks in the same directory. See [`parallel-work.md`](parallel-work.md) for session safety, `[~]` markers, and stable task numbering.

### Between Slices

Retro asks: "Does outcome affect upcoming slices?" If so, update umbrella specs before next slice. Natural `/ws.refine` point.

### Slice Sequencing

`/ws.1-requirements` (Prioritize mode) decides next slice. Same WSJF factors. Slices not atomic -- mixed priorities can split (1a/1b) and interleave.

## Workflow Principles

### Iterative, Not Linear

Stack flows forward, learning flows backward. Tasks reveal plan gaps / implementation exposes missing requirements / discoveries at any stage affect others. **Expect iteration**: 2-3 passes per level = normal.

### Explicit Transitions

Never silently advance between levels. Each transition requires explicit approval: "Does this capture your intent?" / "Ready to move to plan?" / "Proceed to tasks?"

### Protect Focus

Mid-flight discoveries: (1) capture, (2) incorporate now vs defer, (3) if defer: backlog, don't chase, (4) return to current work. New insights get captured, not chased.

### Attention Budget

Spec detail past the point of attentive reading has negative marginal value: a skimmed spec gives the _illusion_ of oversight while reducing it.

At each STOP gate in `/ws.1-requirements`, `/ws.2-plan`, `/ws.3-tasks`, `/ws.refine`: ask **"Is this still shorter than your attention span for one sitting?"** If no, split or cut — don't add the next refinement on top of a document the user is already skimming.

Known failure mode: detailed requirements felt thorough to the LLM; user reported "I started skipping and skimming" — extra detail worsened review quality. Length is not rigor; attended length is.

Corollary for retros: drift between "spec says" and "shipped behaviour" is more likely on long specs — the human who should catch drift stopped reading. Weight retro drift categories (intentional / discovered / creep / cut / silent drift) against spec length.

## Drift Detection (Standing Instruction)

Watch for: **contradictions** ("Spec says X, building Y") / **unstated assumptions** ("Requires Z, not in plan") / **scope drift** ("Bigger than tasks describe") / **missing pieces** ("Spec doesn't cover this case").

**When detected**: (1) stop, (2) state observation, (3) ask: "Run /ws.refine or acceptable deviation?" Never silently proceed when specs and reality diverge.

**Applies to OPEN specs only.** For CLOSED specs (located in `specs/_completed/`), code evolution is not "drift" — the spec describes a past state, not a binding contract for current behaviour. Closed specs remain referenceable for archaeology (what shipped, why decisions were made), but auditing current code against them produces false alarms. For current-behaviour fidelity, inspect the project's authoritative surface for that area (§ Spec Lifecycle → current-behaviour authority).

## Capture Surfaces and Commitment Gradient

Every retained discovery leaves with exactly one destination, chosen at capture time and declared in the project's own binding record — never in the agent-instruction files, which WhittleSpec only ever points at. An item lives in one surface at a time; graduating it moves it, never mirrors it. "Drop" is a legitimate destination, but only stated explicitly with a reason — a discovery left as conversation prose is a lost discovery.

SDD work emerges across a gradient of commitment, expressed through several capture surfaces. **Two tracks run in parallel:**

### Maturation track (for things needing thought)

| Surface | State | Engagement | Location |
|---|---|---|---|
| Idea | "might be neat", brain itch | Passive capture | `specs/_ideas.md` (flat bullets) |
| Seed | "actively pondering" | Engaged thinking | `specs/<feature>/seed.md` |
| Spec | "committed, designing" | Rigorous design | `specs/<feature>/` (requirements / plan / tasks) |
| Closed spec | "shipped, historical" | Done | `specs/_completed/<feature>/` |

### Execution track (for things needing doing)

| Surface | State | When |
|---|---|---|
| Tracked issue | "small, well-understood, going to happen" | Scope is too small / clear for spec rigor — isolated bugs, single-step changes, plumbing |

### Lateral movement is normal

- Idea graduates to seed when engagement grows (operator decides to ponder actively).
- Seed graduates to spec via `/ws.1-requirements` when ready for rigorous design.
- Seed can collapse to a tracked issue if pondering reveals it's smaller and clearer than initially thought — execution doesn't need design.
- Spec implementation generates tracked issues for execution units.
- Graduation is exclusive: an item lives in `_ideas.md` **or** in a seed/spec/tracked issue, not both. When an idea graduates, move its substance into the destination and remove it from `_ideas.md`; the destination becomes source of truth.

### Choosing the right surface at capture time

Ask: *"Can I state a concrete next step — a spike question, a decision to make, or a trigger condition to wait for?"* If yes → seed. The path-out is the symptom of engagement. If no → idea.

Secondary cue: *"Am I capturing this so I don't forget it, or because I'm actively pondering it?"* Don't-forget → idea. Pondering → seed.

Ask: *"Does this need design, or just doing?"* Needs design → seed. Just doing → tracked issue.

### Discovery-capture binding

<!-- WS:IF-CONFIGURED discovery-capture -->
*Where* discoveries land is an adapter with a safe default: `specs/_ideas.md` for passive parking, `specs/<feature>/seed.md` for engaged pondering, and the work ledger for committed execution work. A project may bind additional or replacement destinations — a process/workflow observation surface, a knowledge base, a domain-specific capture file — with the routing rule recorded as prose in the same section. Skills read the set with `ws-binding get discovery-capture` and never invent a destination the project hasn't declared. Unbound → the defaults above hold. `none` drops *external* destinations only; the local surfaces still receive, so no retained item is ever without a home.
<!-- /WS -->

Adjacent domains (process/workflow observations, content sparks) are exactly what a bound extra destination is for: a project that keeps them declares where, and skills route there instead of guessing.

### Spec Lifecycle: OPEN → CLOSED

A spec is a **run document** for guiding implementation of a significant change. Its scope ends at retro. Post-completion, the spec is a historical artefact describing how a past change was reasoned through — not a live description of current behaviour. Current behaviour lives in the project's **authoritative surface** for that area (see below); specs do not track it forward.

<!-- WS:IF-CONFIGURED current-behaviour-authority -->
Which surface is authoritative for current behaviour is an adapter with a safe default: operator guide, README/API docs, tests, and code, in **precedence by surface** — a workflow's authority is its operator guide; a behaviour's is its tests; an API's is its docs; code is the last resort. A project may bind a custom hierarchy (`ws-binding get current-behaviour-authority`) when its authority differs. Unbound → the default precedence holds; skills read it and never defer to the author's environment.
<!-- /WS -->

Lifecycle phase is determined by **inspection of directory location + artefact presence**, not by metadata:

| Phase | Determined by |
|---|---|
| `DRAFTING` | In `specs/<feature>/`, `requirements.md` exists and plan/tasks do not |
| `READY FOR TASKS` | In `specs/<feature>/`, `plan.md` exists, `tasks.md` doesn't (or is empty) |
| `IN FLIGHT` | In `specs/<feature>/`, `tasks.md` has both `[x]` and `[ ]` items |
| `CLOSED` | Spec lives in `specs/_completed/<feature>/` |

Seed-only directories (`specs/<feature>/seed.md` exists, no `requirements.md`) are not yet DRAFTING — they are in the seed phase per the capture-surfaces model. `/ws.1-requirements` promotes seed → DRAFTING.

Umbrella shape substitutes `umbrella-requirements.md` / `umbrella-plan.md` / any `tasks-*.md` for the single-cycle artifact names. Per-slice state is tracked in `umbrella-plan.md`'s Slice Status table.

No `Status:` frontmatter field. Frontmatter status decays because nothing forces the update; location is self-enforcing.

Auditor skills (`ws.review`, `ws.status`) must respect closure: a closed spec describes a past run, not a moving target. Post-completion code evolution against a closed spec is **not drift** — it is the normal state of a living system whose specs are run documents. For current-behaviour fidelity, inspect the project's authoritative surface for that area (§ Spec Lifecycle → current-behaviour authority).

### Seed structure

A seed has a **path out** — a recommended next step, a trigger condition, or a concrete spike question. An idea does not. The path-out is the symptom of engagement; the engagement is what graduates an idea to a seed.

Template: see [`seed-template.md`](seed-template.md) in this skill bundle. Template is suggested structure, not enforced fields — adapt to the seed's actual substance, drop sections that don't apply.

### Closed-spec index

`specs/_completed/INDEX.md` lists closed specs newest-first. Each entry: spec link, completion date, 2-4 line deliverable summary lifted from retro Summary section. Created on first close if absent.

Live specs do not get an index — `ls specs/` is sufficient when active count is small. Indexing earns its place at the historical-archive scale, not the active-work scale.

## Context Loading Protocol

New session or task switch: (1) state what you loaded, (2) load only relevant scope, (3) skip unrelated sections and completed work, (4) start fresh with artifacts, not conversation history.

## AI Behavior Guidelines

### At Every Level

- **Ask before assuming**: questions first, proposals second
- **Challenge vagueness**: "What do you mean by 'fast'?" / "Which users?"
- **Surface assumptions**: make implicit knowledge explicit
- **Concrete examples**: abstract -> specific scenarios

### Level-Specific Behaviors

**Requirements** (`/ws.1-requirements`): WHAT/WHY, resist HOW. Propose ACs then validate. Edge cases + error states. Ask: "What's out of scope?" Must-have vs nice-to-have.

**Plan** (`/ws.2-plan`): 2-3 approaches when meaningful alternatives exist. Trade-offs. Existing codebase patterns. Technical risks. Vertical slices. Ask: "Minimal path through all layers?"

**Tasks** (`/ws.3-tasks`): Sequence for early full-thickness integration. Small tasks (one session). Clear ACs per task. Integration milestones. Ask: "First end-to-end feedback?"

### Structured Questioning

Each question with recommended answer (1-2 sentence reasoning). Alternatives. Impact (scope/architecture/UX). Accept "yes"/"recommended" as shortcuts. Skip cosmetic/easily-reversible decisions.

### Feedback Handling

(1) Acknowledge understanding, (2) revise artifact, (3) highlight changes, (4) ask if revision addresses concern.

### When You Spot Problems

Speak up if: requirements contradictory / plan has unacknowledged risks / tasks too large or poorly sequenced / implementation drifts from spec. Surface issues early, not be agreeable.

### Tool use in autonomous skills

Skills designed to run autonomously (e.g. `ws.fix`) MUST use their harness's native, non-interactive file operations for searching, reading, and writing — never shell commands that trigger an approval prompt, which would break the autonomy guarantee. Shell execution is reserved for what genuinely needs it: running the verification suite, build targets, version-control operations.

<!-- WS:EXAMPLE claude-code-tools -->
On the Claude Code harness that maps to: **Search** `Grep` / `Glob` (not `grep` / `rg` / `find` via Bash); **Read** `Read` (not `cat` / `head` / `tail`); **Write** `Edit` / `Write` (not `cat >` / `echo >` / `sed -i`); Bash only for test suites, `make` targets, and git.
<!-- /WS -->

## Project Principles

Projects should have principles file (`PROJECT_PRINCIPLES.md`, `CLAUDE.md`, `AGENTS.md`, or similar) capturing project-specific defaults: architecture, technology constraints, naming, testing, code style, and external integrations (which issue tracker, if any, and how it's accessed). Distinct from `ws._meta` (process). Check for and load at SDD start.

## Context Directory Structure

**Project-wide**: `context/` with `principles.md`, `architecture.md`, `glossary.md`, `constraints.md`.

**Feature-specific**: `specs/<feature>/context/` with `research.md`, `decisions.md`, etc.

**Loading**: Principles always at session start. Architecture/glossary when relevant. Feature context when working on that feature.

### Capturing Context

Context decays. Capture proactively: **rejected alternatives** (why it lost > documenting winner) / **implicit assumptions** (domain knowledge, external constraints) / **scope boundaries** (what excluded and why -- prevents relitigating). Write `context/decisions.md` as decisions happen, not retroactively.

## Formatting Standards

Strict CommonMark. Blank lines before lists/headers/code blocks. `-` for unordered, `1.` for ordered. Always ``` (not ~~~).

## Artifact Locations

### Simple

`specs/` with `requirements.md`, `plan.md`, `tasks.md`, `retro.md`. Or flat in project root if `specs/` feels heavy.

### Seed

`specs/<feature>/seed.md` -- discovery context, open questions, impact, recommended next step. Grows into full structure when activated via `/ws.1-requirements`. See **Capture Surfaces and Commitment Gradient** for the seed-vs-idea distinction and graduation paths; structure template in `seed-template.md`.

### Project-Level Artifacts

```
specs/
├── <feature>/           # OPEN specs (active work)
├── _ideas.md            # parking lot for ungroomed observations
├── _completed/          # CLOSED specs (historical)
│   ├── INDEX.md         # chronological log of closures
│   └── <feature>/       # closed spec, full tree preserved
```

The `_` prefix marks non-spec project-level files (parking lot, index, archive). Distinguishes from active spec directories at a glance: `ls specs/` immediately separates in-flight from parked from historical.

### Per-Feature

```
specs/<feature>/
├── requirements.md, plan.md, tasks.md, retro.md
└── context/ (research.md, decisions.md, ...)
```

Use when: multiple features in flight / feature needs own context / cleaner git history.

### Multi-Slice (umbrella shape)

```
specs/<feature>/
├── umbrella-requirements.md   # umbrella -- whole project
├── umbrella-plan.md           # umbrella -- slice definitions + tracking
├── tasks-slice1.md            # per-slice (kept after retro)
├── tasks-slice2a.md           # may coexist during parallel work
├── retro-slice1.md            # per-slice retro
├── umbrella-retro.md          # project-level retro (after all slices)
└── context/                   # shared research, decisions
```

## Supporting Files

Bundles:

- [`workflow-doc.md`](workflow-doc.md) -- template for operator workflow docs.
- [`seed-template.md`](seed-template.md) -- suggested structure for `specs/<feature>/seed.md`.
- [`issue-tracking.md`](issue-tracking.md) -- issue-tracker protocols (loaded by skills that touch the tracker).
- [`parallel-work.md`](parallel-work.md) -- parallel-session safety (loaded by `ws.status`, `ws.4-run`).
- [`prompt-index.md`](prompt-index.md) -- prompt navigation (loaded by `ws.status`).
- [`binding-setup.md`](binding-setup.md) -- the narrow binding setup: one block per adapter concept (loaded by `ws.0-start` for guided setup, and by any consumer that hits a missing binding).

SDD skills reference these files. TDD/BDD skills reference `ws.tdd._meta`.
