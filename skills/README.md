# SDD Skills Index

Skills for the Specification-Driven Development workflow. See [INSTALL.md](../INSTALL.md) for the install routes -- have an agent do it, clone and build, or copy the directories in.

## The command set

Three groups, readable off the names: a **numbered spine** you traverse in order, **inner loops**
that run inside execution, and **utilities** reachable at any point.

### Spine

- `/ws.0-start` -- Scale calibration: is SDD right for this task, and at what level?
- `/ws.1-requirements` -- WHAT and WHY (includes MVP prioritization mode)
- `/ws.2-plan` -- HOW: vertical slicing, walking skeleton
- `/ws.3-tasks` -- STEPS: sequenced, atomic work units
- `/ws.4-run` -- Execute a single task with constraints enforced
- `/ws.9-retro` -- Close: sync specs to reality, capture learnings, seed future work

Numbers 5-8 are deliberately free, so a step can be inserted without renumbering the rest.

### Inner loops

Run *inside* `/ws.4-run`, repeatedly -- which is why they carry no spine number.

- `/ws.tdd.idea` -- Phase 1: forest-level test case discovery (shared entry for both loops)
- `/ws.bdd.outline` -- Phase 2: Given/When/Then step design (domain language)
- `/ws.bdd.red` -- Phase 3: implement step definitions (pending/failing)
- `/ws.tdd.outline` -- Phase 2: tree-level test design (AAA structure)
- `/ws.tdd.red` -- Phase 3: implement failing unit tests
- `/ws.tdd.green` -- Phase 4: write minimal passing code + BDD verification
- `/ws.tdd.review` -- Audit existing test code for quality (unit + BDD)

BDD and TDD form a double loop: BDD scenarios define acceptance (outer), TDD drives the internals
(inner). `/ws.tdd.idea` is the shared entry point; `/ws.tdd.green` verifies BDD status after each
inner cycle. Not every feature needs BDD -- the decision is recorded per task.

### Utilities

Reachable whenever they apply, ordered by the moment you reach for them.

- `/ws.status` -- Where are we? What's next?
- `/ws.review` -- Read-only: is this selected artefact sound? (value, feasibility, testability)
- `/ws.sweep` -- Read-only: what else did this work affect or leave inconsistent?
- `/ws.fix` -- Applies: repair the safe findings, surface the judgement calls
- `/ws.refine` -- Mid-flight adjustment: incorporate learning, restructure tasks, or defer
- `/ws.spike` -- Timeboxed experiment when uncertainty blocks specifying
- `/ws.init` -- Optional pre-entry: project intent, tier, governance, first spec seeds

Shared context: `ws._meta` (spine + utilities) and `ws.tdd._meta` (both loops). Neither is invocable.

## Usage

All SDD skills load shared context from `ws._meta/SKILL.md` — the sibling skill in the same skills directory the skill itself was loaded from, so it resolves under any clone name, install location, or skills-root override. Meta skills are marked `user-invocable: false` and loaded automatically when relevant.

Typical flow:

```
/ws.0-start           ->  "Level 3, needs full stack"
/ws.spike             ->  (if uncertainty too high to spec)
/ws.1-requirements    ->  Draft requirements.md
/ws.1-requirements    ->  Prioritize mode: carve MVP, must-have vs. nice-to-have
/ws.review            ->  Check specs (value, feasibility, testability)
/ws.2-plan            ->  Draft plan.md, identify walking skeleton
/ws.3-tasks           ->  Draft task file (tasks.md or tasks-<slice>.md)
/ws.4-run 1           ->  Execute first task
/ws.4-run 2...        ->  Continue through tasks
/ws.refine            ->  (as discoveries happen -- updates specs + restructures tasks)
/ws.sweep             ->  (what else did this affect?)
/ws.fix               ->  (end of slice, or on quality drift: analyze, fix, report)
/ws.9-retro           ->  Close the loop (per-slice or project)
```
