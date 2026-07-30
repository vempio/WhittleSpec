---
name: ws.9-retro
description: Post-completion — sync specs to reality, capture learnings, seed future work. Interactive, not a document dump.
---
# ws.9-retro

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/executing.md`, `ws._meta/lifecycle.md`, `ws._meta/issue-tracking.md`.

## Purpose

After feature completion (or natural "done" point), look back at full SDD cycle. Sync artifacts to reality, capture process learnings, seed future iterations.

**Conversation, not document dump.** Retro value = combining LLM observations with user perspective. `retro.md` / `umbrella-retro.md` / `retro-<slice>.md` records that conversation, not substitutes for it.

## When to Use

Feature merged / natural stopping point / before next major feature / after slice or all slices / improving SDD process.

## Modes

**Single-cycle** (default): Full feature. Output: `retro.md`.
**Slice retro**: Scoped to one slice (`tasks-<slice>.md` complete). Output: `retro-<slice>.md`. Asks: "Does this slice's outcome affect upcoming slices?"
**Project retro**: All slices complete. Output: `umbrella-retro.md`. Cross-slice learnings + full drift.

Detect from context: task file = `tasks-<slice>.md` -> slice retro. All slices complete -> project retro.

## Process

Alternates LLM analysis and user interaction. Each phase ends with question requiring input. **Do not chain phases. Wait at each gate.**

### Phase 1: Gather and Present (then STOP)

**Gather** (silently): `requirements.md` / `umbrella-requirements.md`, `plan.md` / `umbrella-plan.md`, task file, the durable-change history — git log by default (key commits, timeline), or the project's bound durability surface (`ws-binding get durability`; see `ws._meta/executing.md` § Durability) — `/ws.refine` notes. Project retro: all `retro-<slice>.md`.

**Drift analysis** -- spec vs reality:

| Category | Description |
|----------|-------------|
| **Intentional pivot** | Consciously changed direction |
| **Discovered necessity** | Had to change for technical reasons |
| **Scope creep** | Added things we shouldn't have |
| **Scope cut** | Removed intentionally |
| **Drift** | Changed without noticing (biggest concern) |

**Present**: Brief summary of what shipped / drift findings (categorized) / narrative challenge: "What story flatters our process? What would someone seeing only the durable record — the git log, or this project's bound durability surface — say went wrong?"

**Ask**: "That's what I observed. Your perspective? Surprises? / More painful than expected? / Where we got lucky not skillful? / Anything I missed in drift analysis?"

**STOP.**

### Phase 2: Process Learnings (then STOP)

Incorporate user's Phase 1 input. Present LLM observations: spec gaps causing friction? / over-specified? / questions we should have asked earlier? / what worked? / integration honesty: any milestone declared "met" based on easier-than-real test?

**Narrative challenge revisited:** Both perspectives on table -- "What story flatters our process? Has user's input changed picture?"

**Ask**: "Anything to add? Then I'll move to open items."

**STOP.**

### Phase 3: Open Items Resolution (EACH item gets destination)

Most important phase. Every open item leaves retro with concrete destination.

**Step 1: Inventory.** Collect from: task backlog / tech debt from implementation / deferred issues / implementation ideas / debt markers (`FIXME: [DEBT]`, `@debt`) / trivial code debt (dead imports, stale config, hardcoded values) / process observations (things the SDD framework itself should change).

**Step 2: Triage trivial.** Items <10 min, no risk: fix now. "Clean up later" = where small debt accumulates.

**Step 3: Propose destination per remaining item.**

Resolve `ws-binding get discovery-capture` and offer the defaults below plus whatever the project bound (see `ws._meta/lifecycle.md` § Discovery-capture binding). Unbound → the defaults alone. Never offer a destination the project has not declared, and never leave a retained item without one; do not turn retro into project setup.

**Defaults (always available):**

| Destination | When |
|-------------|------|
| **Tracked issue** | Small, well-understood, going to happen — execution-track work that doesn't need spec rigor |
| **Spec seed** (`specs/<feature>/seed.md`) | Actively pondering, worth engaged thinking, has a recommended next step |
| **Idea** (`specs/_ideas.md`) | Brain itch — captured so it's not forgotten, but no engagement yet |
| **Drop** | Not worth tracking; explain why |
| **Stay as historical observation** | Useful context inside this retro; no live action implied |

**Bound destinations** (from `ws-binding get discovery-capture`, if any): offer each by the name and routing rule the project recorded — e.g. a process backlog for workflow/framework observations, a knowledge base for research notes. Unbound means these do not exist here; do not invent them.

**See `ws._meta/lifecycle.md` § Capture Surfaces** for the commitment-gradient framing that determines which destination fits.

**Present full list with destinations:**

```
1. [Item A] -> tracked issue under epic X: [draft summary]
2. [Item B] -> Drop: [reason]
3. [Item C] -> Already tracked: [PROJ-123]
4. [Item D] -> Fix now (trivial): [what]
5. [Item E] -> Idea in specs/_ideas.md: [one-line entry]
6. [Item F] -> <bound destination> in <path>: [one-line entry]
```

Also ask: "Specs -- update to reflect what was built (default for slice retro / in-flight), or keep original (default for final retro: spec is a run document, closing it)?"

**STOP.**

### Phase 4: Execute, Write, Verify (STOP if impact found)

**Execute agreed destinations:** Open issues in the tracker (linked to the parent epic) / write spec seeds / append idea entries / append entries to the project's bound destinations / fix trivial debt / update/close the tracked issue *if a tracker is bound* (`local` → the task/spec files are the record, nothing external to close; see work-ledger binding) / sync artifacts per user's choice (see closure ceremony below for final-retro defaults). **Exclusive ownership**: if an item being routed to the tracker / seed / a bound destination originated in `specs/_ideas.md`, remove the source line as part of the same edit — items live in one capture surface at a time. See `ws._meta/lifecycle.md` § Capture Surfaces and Commitment Gradient.

**Write `retro.md` / `umbrella-retro.md` / `retro-<slice>.md`** (whichever applies for the mode): what shipped / drift analysis (refined by user) / process learnings (with user additions) / open items with resolved destinations (ticket numbers / paths / "dropped") / user's observations (attributed, not paraphrased).

**Current-behaviour source check:** Interface docs match implementation? / README or API docs need updating? / Code comments reflect behavior? / Tests prove the documented behavior? Identify the project's authoritative surface for this area (`ws-binding get current-behaviour-authority`; default: operator-guide / README+API-docs / tests / code, precedence by surface). Stale -> fix or create ticket. For final retros, this source carries fidelity forward after the spec closes.

**Project impact check:** Feature reveal actual problem is different? / Tier change? / New capability not captured?

**Slice retros also**: Outcome affect upcoming slices? / Umbrella specs need update before next `/ws.3-tasks`?

Significant project impact (tier change, pivot): **STOP, discuss with user.** Minor (new seed, status change): edit directly, note it.

#### Closure Ceremony (final-retro / project-retro modes only)

When this retro covers the whole feature (single-cycle final retro, or umbrella project retro after all slices), execute closure after confirmation:

<!-- WS:DEFAULT closure-mechanism -->
1. **Propose move to `_completed/`:** Run the persistence-state check this project's durability binding declares — `git status --short` on the spec directory under the git default, or the check recorded with a non-git binding (`ws-binding get durability`; see `ws._meta/executing.md` § Durability) — and **classify** what it shows. Files this retro just produced — `retro.md`, any seeds, the INDEX entry — are expected and belong *inside* the closure unit; do not stop on them. Anything else — foreign WIP, an unrelated untracked file, or a target that already exists — STOP and discuss. Gating on the retro's own output makes the gate trip every time, which is what it did before this was fixed.

   Then execute closure as **one durable unit**, showing the operator the commands and confirming before executing:

   a. Move `specs/<feature>` to `specs/_completed/<feature>` by the mechanism the durability binding implies — `git mv` under the git default, a plain directory move under a non-git binding, whose persist step in (c) then captures it. The move preserves the full tree (requirements, plan, tasks, retro, context) — a directory rename carries the retro's own still-untracked output along with it, so nothing needs staging first. Directory location becomes the CLOSED state marker; no metadata required.
   b. **Rewrite inbound references**: grep the corpus for the old path and update every hit — sibling specs, seeds, plans, and any bound destination citing a file inside the moved tree. Closure that breaks its own inbound links has traded a stale pointer for a dangling one. Observed: closing this project's own slices left an umbrella plan and a seed pointing at `tasks-slice1.md` and `tasks-slice3.md` paths that no longer resolved.
   c. Persist **once**, per the durability binding, covering the move, the retro, the INDEX entry and the link rewrites together. Verified on a fixture: this yields a single commit in which the renames are recorded as renames and every rewritten link resolves. A closure split across commits can leave the tree half-moved with links pointing at neither location.

The archive move is WhittleSpec's recommended default, not a law — a project may close specs by a stable marker instead, preserving the same invariant (a closed spec stops binding live behaviour, and inbound references still resolve). The configurable form is deferred; this block is the default made explicit, not that adapter's design.
<!-- /WS -->
2. **Insert into closed-spec index:** `specs/_completed/INDEX.md` (create if absent). Insert newest entries at the top. Entry format:
   ```markdown
   ## YYYY-MM-DD — [feature-name](feature-name/)

   <2-4 line deliverable summary lifted from this retro's Summary
   section. What shipped, what entry points expose it, key scope cuts.>
   ```
3. **Backlog migration:** items in this spec's `tasks.md` "Backlog (Deferred)" section whose revisit conditions are met (or imminent) migrate to `_ideas.md`, the tracker, or a bound destination per Phase 3 triage. The historical backlog stays in tasks.md as record; live capture happens in the current surface.
4. **Current-behaviour source check:** confirm the project's authoritative surface for this area is current (`ws-binding get current-behaviour-authority`; default: operator-guide / README+API-docs / tests / code). If none exists and one should, create a ticket or seed rather than smuggling doc-writing into retro.

Slice retros do NOT execute closure — they only sync forward to upcoming slices. Closure is the final-retro's defining act.

**Verify closure**: Every backlog item has destination (ticket number / path / "dropped" / "fixed") / no items remain as prose without tracking / the tracker reflects reality / current-behaviour source checked. Final-retro adds: spec moved to `_completed/`, INDEX entry inserted, **every inbound reference to the old path resolves**, closure landed as one durable unit, current-behaviour source confirmed or follow-up tracked. Anything dangling -> resolve before finishing.

## Output Template

Write to `retro.md` (single-cycle), `umbrella-retro.md` (project retro), or `retro-<slice>.md` (slice retro):

```markdown
# Retrospective: [Feature Name]

## Summary
- **Started**: [Date] / **Completed**: [Date]
- **Outcome**: [What shipped]

## Drift Analysis
### Intentional Changes
- [Change]: [Why pivoted]
### Discovered Necessities
- [Change]: [What learned]
### Unplanned Drift
- [Change]: [Why, how to prevent]

## User Observations
[Attributed, user's voice, not rewritten as LLM analysis]

## Process Learnings
### What Worked
- [Learning]
### What to Improve
- [Learning]: [Suggested change]
### Questions We Should Have Asked Earlier
- [Question]: [Would have prevented...]

## Open Items (Resolved)
| Item | Destination | Reference |
|------|-------------|-----------|
| [Desc] | Tracker | [PROJ-123] |
| [Desc] | Dropped | [Reason] |
| [Desc] | Fixed in retro | [Commit] |
| [Desc] | Spec seed | [path] |

## Artifact Status

**Slice retro / in-flight single-cycle retro** — forward-sync applies:
- requirements.md / umbrella-requirements.md: [Synced / Needs update before next slice]
- plan.md / umbrella-plan.md: [Synced / Needs update before next slice]
- Task file: [progress %, blockers, in-flight items]

**Final retro / project retro** — closure applies (spec becomes historical):
- Spec moved to `specs/_completed/<feature>/`: [yes / pending]
- `specs/_completed/INDEX.md` entry inserted newest-first: [yes / pending]
- Current-behaviour source for this area is identified/current: [yes / no / N/A — explain]
- Backlog items migrated to live capture surfaces: [yes / list pending]

(Do NOT use "Artifact Status: Synced" in final-retro mode — the spec is closed, not forward-syncing. "Synced to what?" has no referent post-closure.)

## Tracker Status
- **Ticket**: [PROJ-123] -- [Updated / Closed]
- **Created**: [PROJ-456], [PROJ-789]

## Impact on Upcoming Slices (slice retro only)
- [ ] Umbrella specs accurate, no updates
- [ ] umbrella-requirements.md needs: [describe]
- [ ] umbrella-plan.md needs: [describe]
- [ ] Next slice affected: [describe]

## Project Impact
- [ ] PROJECT_INTENT.md still accurate
- OR: [What changed]

## Process Suggestions
[SDD workflow improvements]
```

## Anti-Patterns

**Document dump** (writing retro without asking user -- LLM observations = half picture) / **Listing without actioning** ("we should do X" nobody reads = not writing it; every item gets ticket, seed, or "drop") / **Severity minimization** (user-facing bugs as "low priority" or "pre-existing") / **Skipping retro** ("we're done" is not retro) / **Celebration without critique** (what went wrong matters more) / **Paraphrasing user** (preserve their voice, don't rewrite as LLM analysis)
