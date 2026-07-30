---
name: ws.review
description: Review specs for gaps, ambiguity, over-specification. Covers value, architecture, and testability perspectives.
---
# ws.review

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/executing.md`, `ws._meta/lifecycle.md`, `ws._meta/issue-tracking.md`.

## Purpose

Review spec artifacts through three lenses in single pass: user value (analyst), technical feasibility (architect), testability (QA). User can weight perspective via context (e.g., "/ws.review focus on testability").

Both **user-invocable** and **composable** -- `ws.fix` and `ws.refine` invoke it as a composable review (a subagent by default; see Modes for the no-subagent fallback). Name only the skills that actually do: a claimed caller that does not call is a promise the corpus cannot keep, and whether more skills *should* compose this way is a separate design question.

## Stance

Skeptical but constructive. Assume author knows domain; surface what they overlooked or left implicit.

## Closed-spec handling

If the spec lives in `specs/_completed/<feature>/`, it is **CLOSED** — a historical run document. Review of a closed spec is rarely useful because it no longer binds current behaviour. Default behaviour: decline review of the closed spec with a brief note that it is referenceable archaeology, not an active contract. If the user wants a fidelity check on current behaviour, redirect to the project's authoritative surface (`ws-binding get current-behaviour-authority`; default: operator-guide / README+API-docs / tests / code — see `ws._meta/lifecycle.md` § Current-behaviour authority binding). Override only if the user explicitly asks to review the historical spec (e.g., for archaeology or to inform a successor spec).

See `ws._meta/lifecycle.md` § Capture Surfaces and Commitment Gradient.

## Modes

- **Manual** (user calls /ws.review): Full review, interactive. Ask clarifying questions. Present by severity.
<!-- WS:DEFAULT independent-review-agent -->
- **Composable** (subagent by default): Abbreviated, structured output. No clarifying questions -- work with what's available. Return findings as structured list (severity + category + description) for caller to merge and deduplicate. Where the runtime offers no subagent, the caller runs this review as a clean-context second pass (fed only the artefact under review), escalating to a human checkpoint when the stakes are high -- the independent perspective is the requirement, the subagent is the default means.
<!-- /WS -->

## Process

### 1. Identify Artifact

Ask "What would you like me to review?" or infer from context. Load relevant files. If user requests specific focus, weight that perspective but still check others.

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
4. **Tech debt** -- run debt audit (see `ws.tdd._meta`). Flag unpaired markers, orphaned `@debt` tests, met re-enable conditions.

### 4. Adversarial Challenge (before reporting, don't show this step)

- **Inversion test**: Pick three most important assumptions. Invert each. No defense = must-fix gap.
- **Underwhelm test**: For each task demo, imagine presenting to senior stakeholder. "You called me into a meeting for *this*?" = task too thin or demo hides real payoff. Flag it.
- **Malicious user**: How would someone abuse/game this feature?
- **Blind spot**: What would author not think to ask?
- **Self-critique**: Am I over-emphasizing pet concerns?

### 5. Report

```markdown
## Ambiguities
- **[Location]**: [Quote/description]
  - Risk: [What could go wrong]
  - Suggestion: [How to clarify]

## Gaps
- **[What's missing]**: [Why it matters]
  - Questions to answer: [Specific questions]

## Over-Specification
- **[Location]**: [What's over-specified]
  - Risk: [Wasted effort if requirements change]
  - Suggestion: [Appropriate detail level]
```

### 6. Prioritize

- **Must fix**: Blocks implementation or high misinterpretation risk
- **Should fix**: Significant clarity improvement
- **Could fix**: Minor polish

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

## Output

End with:
- Summary: "Found N issues: X must-fix, Y should-fix, Z could-fix"
- Recommendation: "Address must-fix before proceeding" or "Looks good"
