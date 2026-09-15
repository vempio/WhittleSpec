---
name: ws-refine
description: Mid-flight adjustment — incorporate learning, restructure tasks, or defer. Orchestrates review on affected artifacts.
---
# ws.refine

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/shaping.md`, `ws._meta/lifecycle.md`, `ws._meta/parallel-work.md`, `ws._meta/issue-tracking.md`.

## Purpose

Handle discoveries during specification or implementation. Two paths: (1) **Protect focus** -- capture distractions, continue current work. (2) **Incorporate learning** -- update specs when new info matters now. Both end same way: back to what you were doing.

## When to Use

Discovery that might change specs / implementation revealed gap or contradiction / new requirement emerged mid-flight / assumption proved wrong. Also invoked passively: if AI detects drift during work, suggest `/ws.refine`.

## Process

### 1. Articulate Discovery

State: "What did we learn?" / "Where from?" (implementation, conversation, external input)

### 2. Assess Relevance

"Does this change what we're currently doing?" Check task file(s) for `[~]` markers. If affected tasks are in-flight (another session), warn: "Task N is in-flight -- this change may cause conflicts with parallel work."

```
Discovery -> CURRENT work or FUTURE?
  CURRENT -> Incorporate (Step 3a)
  FUTURE  -> Capture for later (Step 3b)
```

### 3a. Incorporate (Current Work)

1. **Identify affected levels** -- Requirements / plan / tasks change? Does it ripple?
2. **Assess scope impact** -- Minor tweak? Restructure? Scope reduction (good!) / expansion (be wary)?
3. **Propose specific changes** -- Quote current, show proposed, explain why.
4. **Update artifacts** with user approval.
5. **Review affected artifacts** -- Run `/ws.review` (composable mode) on changed artifacts. Catches second-order problems: fix for one gap may open another.
6. **Restructure task list** if discovery affects tasks:
   - **Stable task numbering (HARD RULE)**: Never renumber existing tasks. Completed `[x]` and in-flight `[~]` keep their numbers. New tasks use letter suffixes: between 19 and 20, insert 19a (then 19b, 19c).
   - **Task identity preservation**: If scope movement changes task's goal beyond recognition, mark obsolete (`[OBSOLETE -- replaced by 19a]`) and create new task. Task number is stable reference (commit messages, the tracker, parallel sessions).
   - **Scope movement within reason**: Subtasks/ACs may move between tasks, but each must remain closed, verifiable, valuable increment. Walking skeleton and vertical slice compliance from `/ws.3-tasks` still apply.
   - **Review restructured list**: Verify vertical slice compliance. Each task must leave project testable, wire into production, advance BDD/docs where applicable.
   - **Warn about in-flight interference**: If restructuring affects `[~]` task, warn explicitly about parallel session conflicts.
7. **Check work-ledger alignment** (resolve `ws-binding get work-ledger`; see `ws._meta/SKILL.md` § Work-ledger binding) -- tracker bound: scope change affect the linked issue? (Summary mismatch, new slice, ACs shifted.) Update the issue or create a new one? If no reference yet, does this tip work into "committed" territory? `local`: the task/spec files are the record — keep them current, no external issue.

### 3b. Defer (Future Work)

**MANDATORY: Every deferral persisted to durable artifact.** Conversation-only deferral = failed refinement.

1. **Persist** -- choose destination:
   - **a)** Active SDD workstream (task file present): Append to Backlog section.
   - **b)** No task file, relates to existing spec/workflow: Append "Future Work"/"Backlog" section.
   - **c)** No task file, no related spec: record it in the work ledger immediately — a tracked issue if a tracker is bound, else a `local` task/spec entry.
   - **d)** Large enough for own workstream (spec kernel): Create `specs/<workflow-name>/seed.md` with full context. If the item came from `specs/_ideas.md`, remove it there; the seed becomes source of truth. Do NOT create a tracker epic yet.
   - **e)** Belongs to a domain the project captures elsewhere (process/workflow observation, research note): resolve `ws-binding get discovery-capture` and route by the recorded rule. Unbound → no such destination exists here; use (a)-(d). See `ws._meta/lifecycle.md` § Discovery-capture binding.
   - For all paths: **check tracker implications** (comment on current issue? own issue needed?).
   - Write enough context for self-explanatory reading weeks later.

```markdown
## Backlog (Deferred)
- [Discovery]: [Description -- enough to act on cold]
  - Source: [task, conversation, implementation detail]
  - Context: [What were we doing? Connection?]
  - Why deferred: [Not blocking because...]
  - Impact if forgotten: [What breaks/degrades?]
  - Revisit when: [Concrete condition, not "later"]
  - Persisted to: [File path, tracker ID, or both]
```

2. **Verify persistence**: Confirm "Persisted to [location]." Can't point to file or ticket = not finished.
3. **Don't chase** -- return to current work.
4. **Note**: "Captured [X] in [location]. Returning to [current task]."

> **Lifecycle**: Deferred items revisited during `/ws.9-retro` (step 5: Future Seeding). Between retros, `/ws.status` surfaces backlog health.

### 4. Resume

"Discovery handled. Back to [what we were doing]." / "Returning to Task N..."

## Output

**If incorporated**:
```markdown
## Refinement Applied
**Discovery**: [What we learned]
**Affected**: [requirements.md / umbrella-requirements.md / plan.md / umbrella-plan.md / task file]
**Changes made**: [File]: [Summary]
**Review findings**: [Summary or "no new issues"]
**Task restructuring**: [Changes or "none needed"]
**Resuming**: [Current task/activity]
```

**If deferred**:
```markdown
## Refinement Deferred
**Discovery**: [What we learned]
**Persisted to**: [Location]
**Context**: [What we were doing, why this came up]
**Reason**: [Not blocking because...]
**Impact if forgotten**: [What breaks/degrades]
**Revisit when**: [Concrete condition]
**Resuming**: [Current task/activity]
```

## Anti-Patterns

- **Discussing without persisting** -- most common failure. Not in durable artifact = didn't happen.
- Chasing every discovery immediately (scope creep)
- Ignoring discoveries that should change plan (drift)
- Changes without noting them (invisible drift)
- Deferring everything (never learning)
- Large rewrites without user approval
