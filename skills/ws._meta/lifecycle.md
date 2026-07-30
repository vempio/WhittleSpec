# WhittleSpec Reference: Artefact Lifecycle

Where artefacts live, how a discovery moves between surfaces, and how a spec ages from
open to closed. Which skills load this chapter is recorded once, in `ws._meta`
`ws._meta/SKILL.md` § Chapter routing.

## Multi-Slice Projects (umbrella shape)

Only after user has adopted umbrella shape (see Process-Shape Hard Rules). Each slice = Level 2-3, self-contained, demonstrable.

### Umbrella and Per-Slice Artifacts

Requirements and plan describe **whole project**, persist across slices. Only task layer splits. **Umbrella**: `umbrella-requirements.md` + `umbrella-plan.md` (full scope, evolve via `/ws.refine` and `/ws.9-retro`). **Per-slice**: `tasks-<slice>.md` (one active per worker, may coexist) + `retro-<slice>.md` (final `umbrella-retro.md` covers whole project).

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

Auditor skills (`ws.review`, `ws.status`) must respect closure: a closed spec describes a past run, not a moving target. Post-completion code evolution against a closed spec is **not drift** — it is the normal state of a living system whose specs are run documents. For current-behaviour fidelity, inspect the project's authoritative surface for that area (`ws._meta/lifecycle.md` § Spec Lifecycle → current-behaviour authority).

### Seed structure

A seed lives at `specs/<feature>/seed.md` and holds discovery context, open questions,
impact and a recommended next step; `/ws.1-requirements` grows it into the full structure.

A seed has a **path out** — a recommended next step, a trigger condition, or a concrete spike question. An idea does not. The path-out is the symptom of engagement; the engagement is what graduates an idea to a seed.

Template: see [`seed-template.md`](seed-template.md) in this skill bundle. Template is suggested structure, not enforced fields — adapt to the seed's actual substance, drop sections that don't apply.

### Closed-spec index

`specs/_completed/INDEX.md` lists closed specs newest-first. Each entry: spec link, completion date, 2-4 line deliverable summary lifted from retro Summary section. Created on first close if absent.

Live specs do not get an index — `ls specs/` is sufficient when active count is small. Indexing earns its place at the historical-archive scale, not the active-work scale.
