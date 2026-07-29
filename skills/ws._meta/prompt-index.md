# WhittleSpec Reference: Prompt Index

## Spine (numbered, traversed in order)

| Prompt | Purpose |
|--------|---------|
| `/ws.0-start` | Scale calibration: is SDD right for this task, and at what level? |
| `/ws.1-requirements` | Elicit requirements; Mode 3 = prioritize (MVP, WSJF) |
| `/ws.2-plan` | Technical plan; vertical slicing |
| `/ws.3-tasks` | Sequenced tasks |
| `/ws.4-run` | Execute a single task with constraints |
| `/ws.9-retro` | Post-completion retrospective (per-slice or project) |

5-8 are deliberately free, so a step can be inserted without renumbering.

## Inner loops (run inside `/ws.4-run`, repeatedly)

| Prompt | Purpose |
|--------|---------|
| `/ws.tdd.idea` | Phase 1: forest-level test case discovery (shared entry, unit + BDD) |
| `/ws.bdd.outline` | Phase 2: scenario step design (Given/When/Then) |
| `/ws.bdd.red` | Phase 3: implement step definitions (pending/failing) |
| `/ws.tdd.outline` | Phase 2: tree-level test design (unit tests, AAA) |
| `/ws.tdd.red` | Phase 3: implement failing unit tests |
| `/ws.tdd.green` | Phase 4: write minimal passing code + BDD verification |
| `/ws.tdd.review` | Audit existing test code for quality (unit + BDD) |

BDD and TDD relate as outer and inner loops (see "The Double-Loop Model" in `ws.tdd._meta`). BDD scenarios define acceptance from the user's perspective; TDD drives the internals that make them pass.

## Utilities (whenever they apply)

| Prompt | Purpose | Mutates? |
|--------|---------|----------|
| `/ws.status` | Where are we? What's next? | no |
| `/ws.review` | Is this selected artefact sound? (value, feasibility, testability) | no |
| `/ws.sweep` | What else did this work affect or leave inconsistent? | no |
| `/ws.fix` | Repair the safe findings, surface the judgement calls | yes |
| `/ws.refine` | Mid-flight adjustment (incorporate or defer) | yes |
| `/ws.spike` | Timeboxed experiment when uncertainty blocks specifying | no |
| `/ws.init` | Optional pre-entry: project intent, tier, governance, seeds | yes |

Spine and utility skills reference `ws._meta` for shared context; both loops reference `ws.tdd._meta`.
