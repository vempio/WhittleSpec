---
name: ws.review
description: Review specs for gaps, ambiguity, over-specification. Covers value, architecture, and testability perspectives.
---
# ws.review

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/executing.md`, `ws._meta/lifecycle.md`, `ws._meta/issue-tracking.md`, `ws._meta/review-lenses.md` (steps 2-4), and `ws.tdd._meta/debt-protocol.md` (the cross-cutting debt audit).

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

### 2. Review Lenses, Cross-Cutting Checks, Adversarial Challenge

Steps 2 through 4 live in `ws._meta/review-lenses.md`: the value, feasibility and
testability perspectives with their challenges, the cross-cutting checks, the
adversarial challenge to run before reporting, and the red flags that stop a review.
`ws.fix` loads the same file as its spec-review stream.

If test code exists, extend with `/ws.tdd.review`.

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

## Output

End with:
- Summary: "Found N issues: X must-fix, Y should-fix, Z could-fix"
- Recommendation: "Address must-fix before proceeding" or "Looks good"
