---
name: ws.spike
description: Timeboxed experiment to reduce uncertainty before specifying.
---
# ws.spike

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/lifecycle.md`.

## Purpose
Can't specify because understanding too shallow? Run spike. Timeboxed experiment to gain knowledge -- not deliverable code.

## When to Use
"Don't know how this should feel until I try it" / "Not sure if X feasible" / "Requirements depend on what's technically possible" / "Need to play with this before describing it." **Signs**: guessing at requirements / unclear trade-offs between approaches / UX needs experiencing not describing / feasibility uncertain.

## Process

### 1. Define Question
Be specific. **Bad**: "Explore CLI options." **Good**: "Which CLI style (positional vs. flags) feels natural for `sync`?" / "Can we parse legacy format without full rewrite?"
### 2. Set Constraints

| Constraint | Purpose |
|------------|---------|
| **Timebox** | Prevents rabbit holes. 1-4 hours typical. |
| **Scope** | In/out of experiment |
| **Success criteria** | How to know you've learned enough |
| **Throwaway mindset** | Code quality irrelevant -- gets deleted |
| **Questions to answer** | Explicit list -- "acceptance criteria" for spike |

**Third-party API spikes**: Apply `/ws.2-plan` "Third-Party API Selection" checks. Call API from deployment server not localhost (network/rate limits/firewalls differ). Competitors exist -> spike both.
### 3. Run Experiment
Build minimum to answer question. Multiple approaches if time allows. Note learnings, surprises, unexpected constraints.

**API-doc discipline**: if the experiment involves an external API, *reading* the docs is not the same as *fetching* them. Before running the first experiment, extract concrete answers to concrete questions from the fetched content: "The docs say endpoint X, parameter Y, format Z." If an experiment fails, go back to the fetched docs and keyword-search for the relevant endpoint/parameter/field — do not just try variations blindly. When recording a quirk, state what the docs say alongside what you observed; investigate any discrepancy rather than labelling it a platform limitation.
### 4. Synthesize
Document: answer (what learned) / confidence (how sure) / implications (effects on requirements/plan) / residual uncertainty (still unknown).

## Output
Write to `specs/<feature>/context/spike-[topic].md` (or `spike-[topic].md` if no feature structure).

```markdown
# Spike: [Question]

## Context
**Date**: [Date] | **Timebox**: [Duration]
**Question**: [What we're trying to learn]

## Approach
[What we tried, briefly]

## Findings
- [Key insight 1]
- [Key insight 2]
- **Surprises**: [Unexpected findings]
- **Constraints discovered**: [Unanticipated limitations]

## Recommendation
[How to proceed based on learnings]

## Impact on Specs
- **Requirements**: [What to add/change/clarify]
- **Plan**: [Technical decisions now possible]

## Residual Uncertainty
- [What we still don't know]
- [Whether another spike needed]
```

## After Spike
1. **Delete spike code** -- served its purpose.
2. **Proceed to `/ws.1-requirements`** -- spike results as context.
3. Mid-spec spike: update existing requirements/plan with learnings.
More questions than answers? Another focused spike, or accept uncertainty and mark in specs.

## Anti-Patterns
Spikes becoming features (scope creep) / unbounded exploration without question / keeping spike code "just in case" / skipping synthesis / using spikes to avoid specifying.

## Relationship to SDD Levels
Before Level 1 (can't articulate requirements) / during Level 2 (approach unclear) / rarely Level 3 (unexpected complexity). NOT substitute for SDD -- makes SDD possible when uncertainty too high.
