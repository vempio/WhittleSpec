---
name: ws.2-plan
description: Level 2 — Define HOW at structural level, including vertical slicing.
---
# ws.2-plan

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/parallel-work.md`.

## Purpose

Translate requirements into technical approach. Define architecture, components, interfaces -- not implementation details. Identify walking skeleton for early integration feedback.

**Prerequisites**: `requirements.md` / `umbrella-requirements.md` approved. User confirmed readiness.

## Process

### 1. Review Requirements
Summarize: "Working on: [feature]" / "Key requirements: [summary]" / "Must-have for MVP: [list]"

### 2. Propose Approaches
Meaningful alternatives: 2-3 options with trade-offs, risks, recommendation + reasoning. One sensible approach: state directly with rationale.

### 3. Check Brownfield Context
"Where does this integrate?" / "Codebase patterns?" / "Architecture constraints?" / "Already exists?" (rewriting helpers = common LLM failure) / "Prior analysis match actual code?" (docs stale; code = ground truth).

### 4. Identify Walking Skeleton

Lead with user/operator framing, not layered framing (see `ws._meta` §Slicing must never be justified by architecture — slice must be statable in one sentence using no technical nouns).

Ask in this order:
1. **"What's the thinnest user-or-operator-observable end-to-end path?"** — name the smallest concrete thing someone outside the codebase could watch happen.
2. **"What integration feedback does building only this give us?"** — what real-world surprise does it surface that a unit test wouldn't?
3. **"Is this still a complete product slice?"** (completeness test in `ws._meta`).

The walking skeleton legitimately crosses layers — that is what makes it vertical — but layers are a *consequence* of the slice, not its *justification*. Mark explicitly in plan.

### 5. Adversarial Challenge
Before presenting, try to break plan:
- **Single point of failure**: One assumption invalidates entire approach? (Can't identify one = haven't understood risks.)
- **Cheaper alternative**: Simpler approach work? What lost?
- **Integration surprise**: What differs in production? (Data shapes, timing, auth, error codes)

Reveals weakness -> revise. Holds up -> note why in Risks.

## Output

Write to `plan.md` (single-cycle, default) or `umbrella-plan.md` (when the user has explicitly adopted umbrella shape). Path: `specs/<feature>/<filename>`.

```markdown
# Plan: [Feature Name]

## Approach
[1-2 paragraphs: technical solution]

## Walking Skeleton
[State in user/operator terms: the thinnest end-to-end thing someone outside the codebase could observe happen. Layered description follows from this, not the other way round.]
**Build first to validate:**
- [Integration point 1]
- [Integration point 2]

## Components
| Component | Purpose | Integrates With |
|-----------|---------|-----------------|
| [Name] | [What it does] | [Existing code/systems] |

## Data Structures
[Key types, schemas, models -- only if non-obvious]

## Interfaces
[API signatures, function contracts, integration points]

## Dependencies
- **Requires**: [What this depends on]
- **Affects**: [What depends on this]

## Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| [What could go wrong] | [Consequence] | [How to address] |

## Parallel Workstreams (optional)
| Workstream | Components | Can Start After |
|------------|------------|-----------------|
| [Name] | [What it covers] | [Dependencies, or "immediately"] |
**Coordination points**: [Where streams must sync]

## Open Questions
- [NEEDS CLARIFICATION: technical question]
- [ASSUMPTION: technical assumption]
- [VERIFY IN WALKING SKELETON: assumption only validatable via live testing]
```

**`[VERIFY IN WALKING SKELETON]`**: Assumptions only validatable via live integration testing. Distinguishes "decided" from "assumed pending verification." Walking skeleton ACs must verify these.

## Behaviors

**Integration focus**: Reference where new code hooks into existing via parenthetical refs ("integrates with AuthService.validate()"). Ask about existing patterns before proposing new.

**Parallel workstreams**: Multiple independent components -> identify workstreams not sharing files/state, note coordination points, include "Parallel Workstreams" section. See `ws._meta/parallel-work.md`.

**Third-party API selection**: Don't commit based on docs alone. Docs = *intended* behavior; experience reports = *actual*.
1. **Experience research**: Forums/issue trackers/StackOverflow for reliability complaints. 30-min search prevents days of rework.
2. **Spike from real environment**: Call API from deployment server -- localhost differs (IP ranges, rate limits, firewalls).
3. **Field authority**: Which fields caller uses authoritatively vs. recalculates? Wrong answer = scenario-specific bugs.
4. **Mark assumptions**: Unverified third-party behavior -> `[VERIFY IN WALKING SKELETON]`.

## Transition

### Before the STOP gate (mandatory)

Both passes come from `ws._meta` and are not optional.

1. **Compaction pass** — re-read `plan.md` / `umbrella-plan.md` and cut. Target ≥ 20% reduction on first compaction. If 20% will not come out, either the draft was already tight (rare on first pass) or compaction was not attempted. See meta §Condensation is a deliverable.
2. **Attention-budget check** — ask explicitly: *"Is this still shorter than your attention span for one sitting?"* If no, split or cut before adding more (see meta §Attention Budget). Length is not rigor; attended length is.

Also check against meta §Artefact size ceilings for `plan.md` / `umbrella-plan.md`. Past the hard cap, re-run `/ws.0-start` — the level was wrong.

### Readiness checklist

- [ ] Approach clear and justified
- [ ] Walking skeleton stated in user/operator terms (layered description follows, not leads)
- [ ] Components, purposes, integration points explicit
- [ ] Risks acknowledged
- [ ] No blocking `[NEEDS CLARIFICATION]`
- [ ] Compaction pass run
- [ ] Attention-budget check passed

Ask: "Ready to move to `/ws.3-tasks`?" Do NOT proceed without explicit approval.
