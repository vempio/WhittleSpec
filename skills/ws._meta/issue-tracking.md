# WhittleSpec Reference: Issue Tracker Integration & Idea Lifecycle

## Issue Tracker Integration

An issue tracker and SDD serve different purposes:

- **Issue tracker**: Work intake, backlog, prioritization, assignment, visibility
- **SDD**: Execution detail, shared understanding, precise specs

"Issue tracker" here means whatever you use to track committed work -- a hosted
tool, a kanban board, or a flat backlog file. The integration is about *when*
work crosses from exploratory to tracked, not about any specific product.

### Two Entry Paths

Work can start from either direction:

```
TOP-DOWN (planned work)              BOTTOM-UP (emergent work)

Tracked issue exists                 Discovery during SDD / review / conversation
       |                                    |
/ws.0-start                        /ws.1-requirements through /ws.3-tasks
       |                                    |
Level 0-1: just do it, close        Tasks ready = work is committed
Level 2+:  create specs/                    |
       |                             /ws.3-tasks creates the tracker epic + issues
       |                                    |
       +----------> Implementation <--------+
                         |
                  Close the tracked issue(s)
```

**Top-down**: A tracked issue drives the work. SDD adds structure if needed. The issue already exists; link specs to it.

**Bottom-up**: Discovery produces specs and tasks. The tracker enters when planning is done and work is committed -- at the end of `/ws.3-tasks`. Before that, the work is exploratory and doesn't belong in the tracker.

Both paths converge: by the time `/ws.4-run` starts, the tracker should reflect the committed work.

### Guidelines

- **Consume the work-ledger binding first.** Before any tracker action below (create / reference / transition / close), resolve `ws-binding get work-ledger` (per `ws._meta/SKILL.md` § Work-ledger binding). `local` → the SDD task/spec files ARE the durable ledger: no external issues, no nag, the files are authoritative. A bound tracker → the guidance below applies. A split → route each item by the recorded rule (official/outcome-bearing → tracker; small/technical/personal → `local`).
- **Link, don't duplicate**: Tracked issue(s) link to `specs/<feature>/`. Don't copy tasks.md into tracker subtasks. Large features may span multiple issues; small features may share one.
- **Transition issues actively**: When starting work (`/ws.4-run`), move the relevant issues to "In Progress". Don't leave the tracker stale while work is happening.
- **Keep tracker and specs in sync**: When `/ws.refine` changes scope, check whether tracked issues need updating (scope changed, slice added/removed, reprioritized). When issues are updated externally, check whether specs need updating.
- **Backlog items**: Discoveries during SDD that are out of scope -- create tracker issues if worth tracking beyond this feature, or comment on the existing issue about what was deferred and why.
- **Traceability**: Include tracked issue reference(s) in `requirements.md` / `umbrella-requirements.md` header (filled in when issues exist -- may be deferred for bottom-up work until `/ws.3-tasks`).
- **Close the loop**: After implementation, update or close the tracked issue (latest in `/ws.9-retro`).

## Idea Lifecycle: From Discovery to Committed Work

Not every discovery is ready for implementation. Ideas go through a maturation pipeline before becoming committed work:

```
Discovery (conversation, review, implementation)
       |
specs/_ideas.md            Passive parking for things not yet being worked
       |                   (removed when promoted; not mirrored)
       |
specs/<name>/seed.md       Active engagement: context, open questions, path out
       |
/ws.1-requirements        Seed becomes input to requirements elicitation
       |
requirements.md -> plan.md -> tasks.md    Standard SDD stack
       |
Tracker epic/issue         Created when work is committed, not before
```

**Key rule**: The tracker holds *committed* work. Ideas, seeds, specs, and tracked issues are exclusive source-of-truth surfaces. Don't mirror the same item across `_ideas.md` and a seed/spec/tracked issue; move it when it graduates. Don't create tracker issues for seeds -- that bloats the backlog with undecided items.

The surfaces above are the defaults. A project may bind extra or replacement destinations for discoveries this pipeline doesn't cover -- resolve `ws-binding get discovery-capture` and route by the recorded rule rather than forcing every discovery into the ideas/seed/tracker path. See `ws._meta/lifecycle.md` § Discovery-capture binding.

**Creating a seed** (via `/ws.refine` path d):

1. Write `specs/<workflow-name>/seed.md` with discovery context, open questions, related artifacts
2. If the substance came from `_ideas.md`, remove it from `_ideas.md`; the seed is now source of truth
3. The tracked issue is created later, when the seed is activated for implementation

**Activating a seed**: When a natural trigger arrives or the operator decides to act, run `/ws.1-requirements` with the seed file as input. The seed's open questions become the starting point for requirements elicitation.
