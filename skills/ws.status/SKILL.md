---
name: ws.status
description: Where are we? Assess current state and suggest next action.
---
# ws.status

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/lifecycle.md`, `ws._meta/parallel-work.md`, `ws._meta/prompt-index.md`.

## Purpose

Quick orientation: assess spec artifacts and state, recommend next action. Use when starting session / lost track / unsure what's next / returning after break.

## Process

### 1. Scan for Artifacts and Context

```
specs/                              specs/<feature>/
├── <feature>/         →  OPEN      ├── requirements.md           →  single-cycle
├── _ideas.md          →  parking   ├── plan.md                   →  single-cycle
├── _completed/        →  CLOSED    ├── tasks.md                  →  single-cycle
│   ├── INDEX.md       →  log       ├── retro.md                  →  single-cycle
│   └── <feature>/     →  closed    ├── umbrella-requirements.md  →  umbrella
└── (live specs)                    ├── umbrella-plan.md          →  umbrella
                                    ├── tasks-*.md                →  umbrella, per-slice
                                    ├── retro-*.md                →  umbrella, per-slice
                                    ├── umbrella-retro.md         →  umbrella, project-level
                                    └── context/                  →  research, decisions
```

Shape detection: `umbrella-requirements.md` (or `umbrella-plan.md` / `umbrella-retro.md`) present = umbrella project. Otherwise single-cycle. Read Slice Status from `umbrella-plan.md` for umbrella projects. Also check `specs/<feature>/context/` (spike-*.md / research.md / decisions.md), `context/` (principles.md / glossary.md), or `PROJECT_PRINCIPLES.md` / `CLAUDE.md` / `AGENTS.md` in root.

**Closed specs**: if the feature is located in `specs/_completed/<feature>/`, it is CLOSED — historical run document. Do not propose implementation work on it. If status was invoked on a closed spec, report briefly that it's closed (with completion date from INDEX.md or retro), summarize what it shipped, and point to the project's authoritative current-behaviour surface (`ws-binding get current-behaviour-authority`; default docs+tests+code) if one is known. See `ws._meta/lifecycle.md` § Spec Lifecycle → current-behaviour authority.

### 2. Assess State

| State | Signals |
|-------|---------|
| **Draft** | Has `[NEEDS CLARIFICATION]` or obvious gaps |
| **Ready** | Complete, no blockers, awaiting approval |
| **Approved** | User confirmed, ready to proceed |
| **Stale** | Exists but may not match reality |

### 3. Identify Current Phase

```
No artifacts        →  Pre-SDD (need /ws.0-start)
requirements only   →  Level 1 (working on requirements)
req + plan          →  Level 2 (working on plan)
req + plan + tasks  →  Level 3 (ready for / doing implementation)
All + retro         →  Complete
```

### 4. Check for Issues

Unresolved `[NEEDS CLARIFICATION]` / `[ASSUMPTION]` markers. Incomplete sections / inconsistencies between levels. Stale `[~]` markers (in-flight but no active session). **Deferred items**: Scan for `## Backlog (Deferred)` -- count entries, note missing required fields (Context / Impact if forgotten / Revisit when), flag items whose "Revisit when" condition may already be true.

### 5. Recommend Next Action

| State | Recommendation |
|-------|----------------|
| No artifacts | "Run `/ws.0-start` to assess if SDD needed" |
| Spike exists, no reqs | "Spike completed. Run `/ws.1-requirements` incorporating spike learnings" |
| Draft requirements | "Continue `/ws.1-requirements` or `/ws.review` (focus on value)" |
| Ready requirements | "Get approval, then `/ws.2-plan`" |
| Draft plan | "Continue `/ws.2-plan` or `/ws.review` (focus on feasibility)" |
| Ready plan | "Get approval, then `/ws.3-tasks`" |
| Draft tasks | "Continue `/ws.3-tasks`" |
| Ready tasks | "Get approval, then `/ws.4-run 1` for first task" |
| Implementing | "Continue `/ws.4-run [N]`. Use `/ws.refine` for discoveries" |
| Done | "Run `/ws.9-retro` to close loop" |

**Multi-slice:** Slice in progress -> "Continue `/ws.4-run [N]`" / Slice complete, others pending -> "Run `/ws.9-retro` for slice, then `/ws.3-tasks` for next" / Parallel tasks completed -> "Run `/ws.sweep`" / All slices complete -> "Run `/ws.9-retro` for project-level retrospective"

## Output

```markdown
## SDD Status

**Feature**: [Name or "unknown"]
**Phase**: [Level 0-3 or Complete]

### Artifacts

| Artifact | Exists | State | Issues |
|----------|--------|-------|--------|
| requirements.md / umbrella-requirements.md | yes/no | [State] | [Count] |
| plan.md / umbrella-plan.md | yes/no | [State] | [Count] |
| Task file(s) | yes/no | [State] | [Count] |

### Context Available

- Project principles: [yes/no, location]
- Spike results: [yes/no, what topics]
- Feature context: [yes/no, what's there]

### Slice Status (if multi-slice)

| Slice | Status | Tasks |
|-------|--------|-------|
| [id]  | [status] | [file] |

### In-Flight Tasks

- Task N: [Name] -- [~:hint if present] (in [task file])

*(None)* if no tasks in-flight.

### Backlog Health

- Deferred items: [N] ([M] with incomplete context)
- Revisit conditions possibly met: [list or "none"]
- Action: [No action needed / Review during next retro / Items may need attention now]

### Open Issues

- [Issue 1]

### Recommended Next Action

[Specific recommendation with command]
```

## Output Modes

**Full (session start)**: First invocation or returning after break -- full template above.

**Lightweight (mid-session)**: Skills already invoked, user actively working. Skip full inventory:

```markdown
## Status

**Current task**: Task N -- [name] [~]
**Next**: [specific recommendation]
**Warnings**: [parallel interference / stale markers / backlog needing attention, or "none"]
```

**Quick**: One-liner: "**Status**: Level 2, plan drafted, 2 open questions. **Next**: resolve questions then `/ws.3-tasks`"
