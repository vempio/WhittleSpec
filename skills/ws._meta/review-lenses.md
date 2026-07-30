# WhittleSpec Reference: Spec Review Lenses

The three perspectives a spec review passes through, the cross-cutting checks, the
adversarial challenge, and the red flags that stop a review. Loaded by `ws.review` and
by `ws.fix` (Phase 1's spec-review stream). Artefact selection, the report format and
prioritisation stay with `ws.review`, which is the interactive surface. Which skills
load this is recorded in `ws._meta/SKILL.md` § Procedure routing.

### 2. Three-Perspective Scan

#### Value (analyst) -- primary: `requirements.md` / `umbrella-requirements.md`

- **User value**: JTBD articulated? Each requirement traces to observable value? Simpler solution possible?
- **Completeness**: Error paths? Explicit out-of-scope? Implicit "obvious" behaviors?
- **Scenarios**: Success conditions observable and verifiable? Uncovered edge cases?
- **Clarity**: Any AC interpretable multiple ways?

Challenge: "If we build only half, which half matters?" / "What existing behavior changes, who relies on it?" / "Cost of NOT building this?"

#### Feasibility (architect) -- primary: `plan.md` / `umbrella-plan.md` + `requirements.md` / `umbrella-requirements.md`

- **Feasibility**: Works with existing codebase? Technical risks acknowledged?
- **Integration**: Connects where? Affects what existing behavior?
- **Alternatives**: Meaningful alternatives considered? Over/under-engineered?
- **Contracts**: Interfaces precise enough?

Challenge: "What breaks if assumptions wrong?" / "Simplest version that works?" / "What do we lose doing the dumb simple thing?"

#### Testability (QA) -- primary: all spec levels

- **Testability**: Each AC becomes test case? Success conditions observable?
- **Boundaries**: Empty, max, min, just-over?
- **Failure modes**: Dependency failure? Load? Malformed data?
- **Verification**: Each task testable independently? First demonstrable milestone?

Challenge: "Weirdest input someone might provide?" / "Fail loudly or silently -- why?" / "Error message says what -- enough to debug?"

If test code exists, extend with `/ws.tdd.review`.

### 3. Cross-Cutting Checks

1. **Terminology** -- consistent across artifacts
2. **Parallelization** -- marker consistency, shared files/state
3. **Issue tracking** -- bidirectional: specs reference issues, issues reflect scope. Flag untracked/stale work.
4. **Tech debt** -- run the debt audit from `ws.tdd._meta/debt-protocol.md` § Technical Debt Protocol. Flag unpaired markers, orphaned `@debt` tests, met re-enable conditions.

### 4. Adversarial Challenge (before reporting, don't show this step)

- **Inversion test**: Pick three most important assumptions. Invert each. No defense = must-fix gap.
- **Underwhelm test**: For each task demo, imagine presenting to senior stakeholder. "You called me into a meeting for *this*?" = task too thin or demo hides real payoff. Flag it.
- **Malicious user**: How would someone abuse/game this feature?
- **Blind spot**: What would author not think to ask?
- **Self-critique**: Am I over-emphasizing pet concerns?


## Red Flags

Stop and highlight:

- Circular definitions (term defined using itself)
- Unbounded lists ("handle all cases" -- which?)
- Assumed knowledge ("standard approach" -- whose?)
- Missing actors (actions without ownership)
- Vague quantities ("large files" -- how large?)
- Implicit sequences (assumed order without stating)
- Parallel conflicts (tasks marked parallel, sharing files/state)
- Debt markers without tests (`FIXME: [DEBT]` with no `@debt` scenario)
- Orphaned debt tests (`@debt` with no code back-reference)
- Stale debt (re-enable condition appears met)

