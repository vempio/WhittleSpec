---
name: ws.1-requirements
description: Elicit and document WHAT and WHY from user perspective. Includes MVP prioritization.
---
# ws.1-requirements

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override).

## Purpose

Transform feature idea into structured requirements. WHAT and WHY -- resist HOW (that's `plan.md` / `umbrella-plan.md`). Level 2+ (Level 1 = acceptance criteria only, no formal spec).

## Before Starting

Check prior context: **Spec seed** (`specs/<feature>/seed.md`) / **Spike results** (`specs/<feature>/context/spike-*.md`) / **Project intent** (`PROJECT_INTENT.md`) / **Project principles** (`PROJECT_PRINCIPLES.md`, `CLAUDE.md`, or `AGENTS.md`) / **Existing patterns** (related features).

## Modes

### Mode 1: Create from Scratch

**Input**: Feature idea, user request, or problem statement. **Process**: (1) Identify job-to-be-done (2) Clarifying questions before writing (3) Challenge vague language -- demand concrete examples (4) Surface unstated assumptions (5) Draft, validate: "Does this capture your intent?"

### Mode 2: Refine Existing

**Input**: Existing `requirements.md` / `umbrella-requirements.md` + feedback. **Process**: (1) Acknowledge feedback (2) Revise (3) Highlight changes (4) Ask if revision addresses concern.

### Mode 3: Prioritize

**Input**: `requirements.md` / `umbrella-requirements.md` needing MVP carving or sequencing. Activate when: scope too large / unsure what first / need something working quickly / multi-slice sequencing.

1. **Story map**: User activities (horizontal), steps (vertical), walking skeleton of user value.
2. **Draw MVP line**: "Value without this?" / "What do we learn?" / "Blocked if deferred?"

   | Category | Criteria |
   |----------|----------|
   | **Must-have** | Cannot achieve core goal without it |
   | **Should-have** | Significant value, core works without it |
   | **Nice-to-have** | Polish, optimization, edge cases |
   | **Out of scope** | Explicitly not this iteration |

3. **Validate cut**: MVP must deliver observable value, be deployable/demonstrable, teach something. "Ship only must-haves -- what can users do?"
4. **Sequence beyond MVP** (WSJF): Value / effort / unblocking potential / time sensitivity. Quick wins often beat heavy high-value items.
5. **Scope split detection**: Must-have > 5-7 ACs / natural boundaries / different journeys / mixed complexity -> propose specific split.

**Multi-slice sequencing**: Same WSJF factors between slices. Foundational first. Split must-have/nice-to-have into sub-slices (1a/1b), interleave by priority.

**Where priority lives in the artefact**: MVP cuts and slice sequencing are *Decisions* items, not a separate Priority section. Each cut becomes one line in the Decisions block: "Decision: scope X this cycle; defer Y. Default: <recommendation>. Alternatives: ship both / defer X instead." Story-map and WSJF are techniques that feed those Decisions — they do not survive in the artefact.

## Output

Write to `requirements.md` (single-cycle, default) or `umbrella-requirements.md` (when the user has explicitly adopted umbrella shape -- see `ws._meta` §Umbrella is a user-owned mental-load device). Path: `specs/<feature>/<filename>`. The mandated shape is the Decisions/Context split defined in `ws._meta` — Decisions = what the user must react to, Context = the record. See meta §Artefact size ceilings and §Decisions/Context split for caps, rationale, and hard-cap response.

```markdown
# Feature: [Name]

**Tracker**: [PROJ-123](link) <!-- if applicable -->

## Decisions
<!-- Read top-to-bottom. This is what the user must react to.
     Cap: 5 items. If more, split scope before writing.
     Each item: one-sentence Decision, Default (recommendation), ≥ 1 credible Alternative. -->
- [ ] Decision 1: <one sentence>. Default: <recommendation>. Alternatives: <one phrase each>.
- [ ] Decision 2: ...

---

## Context
<!-- Skim or skip. The record, not a decision surface.
     Hold only what cannot be reconstructed from Decisions + existing project files.
     If you would not read it on review, do not write it. -->

### User story
As a [user type] I want [goal] So that [benefit]

### Acceptance criteria
<!-- Each AC directly becomes a test case. Can't write the test = can't build it. -->
- Given [context], When [action], Then [outcome]

### Out of scope
<!-- Routine exclusions only. Scope cuts that would surprise the user belong in Decisions. -->
- [Explicitly NOT building]

### Open questions
<!-- ASSUMPTIONS that affect implementation but did not rise to a decision.
     [NEEDS CLARIFICATION] that blocks planning is a decision-in-disguise — promote to Decisions. -->
- [NEEDS CLARIFICATION: specific question]
- [ASSUMPTION: what we're assuming]

### Interface contract (optional)
<!-- Include when CLI, API, or other interfaces are central. -->
- Commands/Endpoints / Inputs / Outputs / Examples
```

**What goes where — mapping for content that used to live in flat sections:**

| Content | Location | Notes |
|---|---|---|
| MVP cuts, scope cuts the user could plausibly contest | Decisions | One Decision per cut. Default + Alternative. |
| Slice sequencing (multi-slice) | Decisions | "Decision: slice A before B. Default: A first. Alternative: B first / parallel." |
| User story, ACs, routine out-of-scope, assumptions, prior context | Context | The record. |
| Surprising out-of-scope items | Decisions | Cross-block test: would the user push back? Then it's a decision. |
| `[NEEDS CLARIFICATION]` that blocks planning | Decisions | Promote — the user must react before plan starts. |
| `[ASSUMPTION]` that constrains the solution but not blocking | Context | Record only. |
| Interface contract details (commands, inputs, outputs) | Context | Unless the contract shape itself is contested → then specific points become Decisions. |

## Behaviors

**Structured questioning**: Present recommended answer with 1-2 sentence reasoning, offer alternatives, state impact, accept "yes"/"recommended" as shortcuts. Do NOT ask about cosmetic/easily-reversible decisions.

**Challenge**: Vague goals ("make it better" -> "better how?") / assumed users ("users want..." -> "which users?") / missing boundaries (no out-of-scope) / untestable criteria ("should be fast" -> "under X ms?") / unclear value (toys? gold plating?) / missing job context (unanswerable = ungrounded requirements).

**Surface**: Error states (fail-fast over silent fallbacks) / edge cases (empty? huge?) / boundaries (max? min?) / existing behavior ("How today?") / pragmatic alternatives ("Why not Excel?") / failure visibility (loud/silent?) / **integration field authority** ("Which fields used directly vs. recalculated?" -- mandatory for webhook/API integration).

**Loaded vocabulary**: Words like "available", "current", "bookable", "valid", "live", "active", "ready" *sound* obvious but operationalise differently in code. For every loaded word in an AC, force a definition. "Currently available" = "in the source-of-truth list" or "in that list AND in the future AND not sold-out"? Different code, different production behaviour. If the spec doesn't pin it, the implementation gets to choose silently — and the choice surfaces as a bug after ship.

**AC negative-case discipline (mandatory on money-taking / commitment surfaces)**: Every positive AC on a surface that takes money, sends a message, commits the company, or makes a contractual statement MUST be paired with explicit negative ACs naming the failure modes. "Renders all available classes" -> also "Does not render past classes" + "Does not render sold-out classes" + "Does not render incomplete schedules". Negative ACs catch the deliverability bugs the positive ACs are blind to. Without them, the walking skeleton tests the *shape* and not the *contract* — looks green, ships poison.

Known failure mode: positive AC reads "renders all currently-available classes". Walking-skeleton test asserts dates ascend, row count is positive, structure matches contract. Declared done. Page sells a seat in a class whose session was last week. Caught only by adversarial review at end of feature. Negative ACs at requirements time would have made this impossible to ship.

## Transition

### Before the STOP gate (mandatory)

Two passes, in order. Both come from `ws._meta` and are not optional.

1. **Adversarial pass** — run all four tests on the draft:
   - Decisions: each item has a credible Default + ≥ 1 Alternative the user could plausibly choose. If the Alternative is straw, move to Context or cut.
   - Decisions: a knowledgeable reviewer could plausibly push back on each item. If not, the item is settled → Context or cut.
   - Context: removing each paragraph would change a downstream choice. If not, cut. "For completeness" / "to be thorough" is the failure mode, not the answer.
   - Cross-block: scan Context for assumptions that constrain the solution, scope cuts that would surprise the user, definitions that change an AC's meaning. Promote to Decisions.

2. **Compaction pass** — re-read and cut. Target ≥ 20% reduction on first compaction. If 20% will not come out, either the draft was already tight (rare on first pass) or the compaction was not actually attempted.

### Readiness checklist

- [ ] Decisions block has ≤ 5 items, each with credible Default + Alternative
- [ ] Adversarial pass run (all four tests, both directions + cross-block)
- [ ] Compaction pass run (≥ 20% target on first draft)
- [ ] 60-second decideability test passes for the Decisions block
- [ ] Each AC in Context can literally become a test case
- [ ] No unresolved `[NEEDS CLARIFICATION]` blocking planning (promoted or resolved)
- [ ] Artefact still shorter than user's attention span for one sitting (attention-budget rule)

Ask: "Ready to move to `/ws.2-plan`? (Or prioritize/carve MVP first?)" Do NOT proceed without explicit approval.
