# BDD + TDD: The Double-Loop Workflow

Reference material for the BDD/TDD interaction model. Loaded by skills that need the full procedure (`/ws.tdd.idea`, `/ws.bdd.outline`, `/ws.bdd.red`, `/ws.tdd.green`). The core summary lives in `SKILL.md`.

## The Double-Loop Model

When a feature has both BDD scenarios and unit tests, they relate as outer and inner loops:

```
OUTER LOOP (BDD):  scenario outlined -> steps implemented -> steps RED
                                                               |
                                      [BDD stays red while TDD builds internals]
                                                               |
INNER LOOP (TDD):                    unit idea -> outline -> red -> green
                                                                      |
                                      [repeat TDD until enough production code exists]
                                                                      |
OUTER LOOP:                                       BDD scenarios go GREEN
```

BDD scenarios establish WHAT the system should do from the user's perspective. They go red (step definitions written but no production code). Then TDD drives HOW to build the internals. When enough TDD cycles complete, BDD scenarios go green as a consequence.

**Key implications:**

- There is no separate "ws.bdd.green" skill. Production code is written via `/ws.tdd.green` (or directly for trivial cases). BDD going green is a **verification checkpoint**, not a separate implementation phase.
- `/ws.tdd.green` checks BDD scenario status after making unit tests pass: "BDD outer loop: X of Y scenarios green."
- The human may skip the TDD inner loop for trivial scenarios and implement production code directly.
- The double loop is the recommended workflow but not mandatory. The human decides.
- **Close the outer loop incrementally.** When a task builds multiple components, wire each into the entry point as it lands -- don't wait until all components exist. A BDD scenario that fails at "write the confirmation row" is vastly more informative than one that fails at "unknown subcommand." Run the BDD suite after each component and wire enough plumbing to advance scenarios to their next real failure point. (See "Early wiring rule" in `ws.4-run`.)

**Workflow sequence:**

1. `/ws.tdd.idea` -- generate BDD scenario titles + unit test ideas
2. `/ws.bdd.outline` -- write Given/When/Then steps (BDD Phase 2)
3. `/ws.bdd.red` -- implement step definitions, scenarios go red (BDD Phase 3)
4. `/ws.tdd.idea` (or derive from BDD steps) -- generate unit test ideas for internals
5. `/ws.tdd.outline` -> `/ws.tdd.red` -> `/ws.tdd.green` -- TDD inner loop builds production code
6. `/ws.tdd.green` verifies BDD scenario status after each green cycle
7. When BDD scenarios pass, the feature's outer loop is complete

## Test Level: BDD vs. Unit

Not every feature needs BDD. Decided during `/ws.tdd.idea`.

**Use BDD when:** user-facing behaviour describable in domain language; ACs naturally express as Given/When/Then; behaviour crosses multiple components; executable specs that non-developers can read.

**Use unit tests only when:** internal logic / algorithms / transformations; error handling, edge cases, boundaries; functions or classes in isolation; technical not user-observable; plumbing.

**Mixed projects (common case):** BDD for feature-level acceptance (outside-in); unit for internal correctness (inside-out). Both seeded from the same `/ws.tdd.idea` session. Default: **outside-in** — BDD sets the acceptance target, TDD drives the internals.

During `/ws.tdd.idea`, state the test-level decision explicitly: "user-observable → BDD + unit" or "internal plumbing → unit only."

## Python BDD Framework Choice

An adapter selection, not a framework preference — detect from the project (dependencies, existing tests) or ask; never assume. See the framework-detection note in `SKILL.md` for the detection signals and each option's operational differences (runner integration, config, fixtures vs. context object).
