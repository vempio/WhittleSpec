---
name: ws-init
description: Bootstrap or re-scope a project -- capture intent, seed first specs, bridge to strategy.
---
# ws.init

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/shaping.md`, `ws._meta/lifecycle.md`.

## Purpose

Capture project-level intent, set up governance proportional to weight, create spec seeds for first features. Sits *before* SDD feature pipeline (`/ws.0-start` -> `/ws.1-requirements` -> ...). Also handles re-scoping when direction changes significantly.

**Stratum**: Operates at **project level**. SDD strata: **Project** (`/ws.init`) -- why project exists, scope, tier, governance, which features. **Feature** (`/ws.0-start` through `/ws.9-retro`) -- what feature does, how built.

ws.init bridges: PROJECT_INTENT.md (project context) + spec seeds (feature starting points) -> hands off to `/ws.0-start`.

## When to Use

New project / significant scope change / graduating experiment to operational / formalizing organic project.

## Process

### 1. Detect Context

Check working directory: `.git/`, `CLAUDE.md`/`AGENTS.md` (read-only -- existence and content, never written here), `PROJECT_PRINCIPLES.md`, `PROJECT_INTENT.md`, `specs/` (+ `seed.md`), `Makefile`, `pyproject.toml`, `package.json`.

**New project**: No intent doc, minimal governance. **Re-scope**: Intent doc exists or significant structure present (see Re-Scope Mode). State which.

### 2. Elicit Intent

For new projects, ask: **Problem** ("What problem, for whom?") / **Approach** ("How solve it?") / **Success** ("Observable outcomes?") / **Boundaries** ("Explicitly NOT?")

**Challenge intent** before accepting -- cheapest place to kill bad ideas.

#### Value Challenge

- **"Who has this problem today, and how?"** Nobody / adequate solution -> maybe not worth starting.
- **"What if we don't build this?"** Probe: must-have vs nice-to-have / time criticality / risk reduction / learning value (changes decision, or just curiosity?) / maintenance burden (existing tool handles 80%?)
- **"Could existing tool handle this?"** Build-vs-buy. Spreadsheet/script/existing CLI might suffice.
- **"Problem you have, or solution you want to build?"** Engineers gravitate toward interesting tech. "Build clip pipeline" might need reframing as "produce clips with less friction."

Push back if answers vague / problem hypothetical / approach over-engineered.

#### Capacity Competition Check

Starting new work always costs attention on work already in flight -- weigh that trade-off consciously before committing. Whether you scan a portfolio or just ask "what else is on your plate right now?", the question is the same, and it holds even when there is nothing to scan.

<!-- WS:EXAMPLE portfolio-scan -->
Where a portfolio surface exists, make the competition concrete by scanning it: the tracker's active epics/issues, sibling project dirs with a `PROJECT_INTENT.md` (status != complete), your planning/roadmap doc for commitments. Absent that infrastructure, ask the operator directly instead -- the trade-off still stands, unscanned.
<!-- /WS -->

1. **Present**: "N active projects: [list]. Starting [new] means one gets less attention. Which absorbs hit, or replaces one?"
2. **Reaction**: "Genuinely urgent" -> proceed. "You're right" -> shiny-thing caught, capture as seed, return to current work. "Just small experiment" -> exploratory tier, minimal governance, set timebox. "Replaces Y" -> re-scope, archive Y.

Not a gate. User may have good reasons despite full plate. Overloaded + low time-criticality -> say so.

For re-scope: "What triggered change?" / "What stays vs differs?" / "Specs need revisiting?" / **"Genuine scope change, or scope creep wearing hat?"**

### 3. Assess Tier

Default to the lowest defensible amount of ceremony; more weight earns more structure, never the reverse. Manufacturing governance a project's weight doesn't warrant is the failure, not the safeguard.

<!-- WS:DEFAULT tiers -->
A recommended weight scheme -- replace the bands if your context wants different ones:

| Tier | Signals | Examples |
|------|---------|----------|
| **Exploratory** | Experiment, PoC, learning, time-limited | LLM comparison, tooling spike, prototype |
| **Operational** | Ongoing tool/service with real users | Internal CLI, training material, client project |
| **Strategic** | Tied to a strategy/planning initiative or business priority | Product launch, revenue stream, partnership |

Not permanent. State graduation criteria: "Graduates to operational if [condition]."

**Challenge tier.** "Strategic" without an initiative doc or revenue link -> push back. Re-scope: check if tier changed.
<!-- /WS -->

### 4. Strategy Linkage

Strategic-weight work should trace to a higher purpose; most work should not be forced to. Not every project needs an initiative -- pushing one onto exploratory work is inflation, not rigor.

<!-- WS:EXAMPLE strategy-linkage -->
Where a strategy/planning area exists: **Exploratory**: No link needed. **Operational**: check your strategy/planning docs; note the connection if one exists. **Strategic**: an initiative doc (in that area) is required -- exists -> cross-reference; missing -> "Needs initiative doc before tracker epics."
<!-- /WS -->

### 5. Work-ledger Posture

Resolve the work ledger (`ws-binding get work-ledger`; see `ws._meta/SKILL.md` § Work-ledger binding). `local` → track in the SDD spec/task files (or PROJECT_INTENT.md while exploratory); no external issues. When a tracker is bound, at the org's granularity:

**Exploratory**: No tracker issue. Track in PROJECT_INTENT.md. Create if/when graduating. **Operational**: Epic when first feature concrete enough for `/ws.1-requirements`. Until then, an issue under an existing epic if anchor needed. **Strategic**: Epic linked to initiative. Create after `/ws.0-start` or now if scope clear.

### 6. Set Up Governance

Proportional to tier. **All tiers**: PROJECT_INTENT.md (core output) -- WhittleSpec's own structure, never the adopter's `CLAUDE.md`/`AGENTS.md` (INV-2: the only sanctioned write into those is `ws-binding anchor`'s pointer line, added later during `/ws.0-start` setup, never here). **Operational+Strategic**: `specs/` directory / PROJECT_PRINCIPLES.md (only if non-obvious constraints). **Strategic only**: Cross-reference to/from initiative doc. Don't generate empty boilerplate -- skip and note why. Don't generate a `Makefile` either -- that's the adopter's build tooling, not a WhittleSpec artefact.

### 7. Create Spec Seeds

**Challenge before seeding**: "Serves stated problem or adjacent?" / "If only one feature, this one?" / "Feature user needs or capability builder finds interesting?" / "Cheapest way to test if it matters?"

Survivors get seed at `specs/<feature>/seed.md`. Seeds bridge intent and pipeline -- enough to resume without context loss. NOT requirements (no Given/When/Then), NOT plans (no architecture).

#### Seed Content

Sections appear when applicable -- don't force empty: **Problem/Discovery** (why needed, what gap) / **Present Understanding** (known approach, prior research, spike results) / **Open Questions** (what we don't know; often determines spike vs `/ws.0-start`) / **Dependencies** (relates to, builds on, blocks) / **Recommended Next Step** (spike / `/ws.0-start` / more research).

Optional for mature seeds: Spike Definition / Scale Considerations / Related Research / Resolved Questions / Deferred ideas.

```markdown
# Spec Seed: [Feature Name]

Status: seed (not yet activated for SDD)
Created: [date]
Source: [where idea came from]

## Problem
[Why needed]

## Present Understanding
[What we know]

## Open Questions
- [What we don't know]

## Dependencies
- [Relations]

## Recommended Next Step
[Spike / `/ws.0-start` / needs research]
```

#### Seed Discipline

Don't over-specify (reading like a `requirements.md` / `umbrella-requirements.md` = crossed into `/ws.1-requirements`). Don't under-specify ("Build feature X" = no value). Vary depth by knowledge. Seeds are cheap -- minutes to create, prevent context loss.

### 8. Hand Off

**New project** -> "Run `/ws.0-start` on first seed. Seeds at: [paths]." / **Re-scope** -> "Run `/ws.refine` on [affected features]." / **Graduation** -> "Tier upgraded. [governance additions]. Run `/ws.0-start`."

## Output Structure

Write `PROJECT_INTENT.md` in project root:

```markdown
# Project: [Name]

## Problem
[1-3 sentences: what problem, for whom]

## Approach
[1-3 sentences: how addresses it]

## Success Looks Like
- [Observable outcome]

## Boundaries
- NOT: [exclusion]

## Tier
[Exploratory / Operational / Strategic]
[Exploratory: "Graduates if: [condition]"]
[Strategic: "Initiative: <strategy/planning area>/[name]/"]

## Issue Tracker
[Not yet / Epic: PROJ-xxx]

## Related Projects
- [Project] -- [feeds into / depends on / overlaps / replaces]

## Spec Seeds
| Feature | Seed | Status |
|---------|------|--------|
| [Name] | specs/[name]/seed.md | seed |

## Phases (operational/strategic only)
1. [Phase]: [goal]

## History
- [YYYY-MM-DD]: Created. [context]
```

History for major direction changes only. Spec Seeds table = living index -- update as seeds graduate.

## Re-Scope Mode

1. Read existing PROJECT_INTENT.md (or infer from the project's principles file and existing specs)
2. Present: "Current intent: [summary]. What's changing?"
3. Check existing seeds, note which affected
4. Update PROJECT_INTENT.md -- append History, update sections
5. Tier changed -> add governance proportionally (don't remove when downgrading)
6. Create/update seeds as needed
7. Scan affected specs/tasks: "These may need revisiting: [list]"
8. Recommend: `/ws.refine` for in-flight, `/ws.0-start` for new seeds

## Retro Feedback Loop

Feature retros (`/ws.9-retro`) may surface project-level impact. Minor -> edit directly. Significant (tier graduation, pivot) -> run `/ws.init` re-scope. Relies on ws.9-retro to escalate.

## Anti-Patterns

**Over-governing** (strategic governance for experiment) / **Premature tracking** (epics before first feature concrete) / **Intent as requirements** (ACs in PROJECT_INTENT.md) / **Seeds as requirements** (Given/When/Then in seeds) / **Strategy inflation** (every project must link to initiative) / **Skipping intent** (3-line doc prevents scope drift) / **Scope creep into design** (architecture/ACs = crossed into `/ws.1-requirements` / `/ws.2-plan`) / **Skipping capacity check** (overcommit should be conscious) / **Shiny-thing accommodation** ("small experiment" without timebox = permanent side project)
