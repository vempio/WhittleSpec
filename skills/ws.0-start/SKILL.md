---
name: ws.0-start
description: Entry point to SDD work — calibrate how much ceremony fits this task, from none through full stack.
---
# ws.0-start

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/shaping.md`.

## Purpose

Assess task scope and choose the lightest useful ceremony. Level 0 (no spec, just do it) is a valid outcome; this skill starts work and calibrates rigor, it does not gate idea capture.

## When to Use

- Starting work on a feature or task / unsure whether to "just do it" or spec first / scoping before estimation

## Process

### 1. Gather Context

Ask user to describe task. If unclear: "User-visible outcome?" / "How many files/components touched?" / "Unknowns or decisions to make?"

Check existing context: project intent (`PROJECT_INTENT.md`) / spec seed (`specs/<feature>/seed.md` -- captures prior research, open questions, next steps) / project principles (`PROJECT_PRINCIPLES.md`, `CLAUDE.md`/`AGENTS.md`, `context/`) / existing specs for related features / glossary or architectural docs.

### 2. Assess Scale

| Level | Effort | Signals |
|-------|--------|---------|
| 0 | < 30 min | Trivial fix, single location, obvious solution |
| 1 | 30 min - 2h | Small task, few files, benefits from acceptance criteria |
| 2 | 2h - 1 day | Multiple files, decisions to make, moderate complexity |
| 3 | 1-3 days | Multiple components, architectural choices, unknowns |
| 4 | > 3 days | Genuinely too large for one cycle -- last-resort tier |

### 3. Recommend Approach

**Level 0**: Trivial -- proceed directly to implementation.

**Level 1**: Write acceptance criteria before starting, no formal specs.

**Level 2**: requirements.md for what/why, then plan.md for approach. Skip tasks.md.

**Level 3**: Full stack: requirements.md -> plan.md -> tasks.md. Suggest per-feature directory if appropriate.

**Before Level 2+**: Check if uncertainty blocks specifying. Signs you need `/ws.spike` first: can't write requirements (don't understand how it should work) / multiple valid approaches with unclear trade-offs / technical feasibility uncertain / UX needs experiencing, not describing. High uncertainty -> `/ws.spike` before `/ws.1-requirements`.

**Level 4 (last resort)**: Single-cycle is the default at *every* level (see `ws._meta/shaping.md` §Process-Shape Hard Rules > Default is single-cycle). Reaching Level 4 does not mean "go umbrella". The default response to a > 3-day estimate is **N single-cycle Level 3 projects in adjacent directories**, not one umbrella spec covering all of them. Two related projects are two projects, not an umbrella. Umbrella shape is reserved for the rare case where the user genuinely cannot hold the whole thing in working memory (see meta §Umbrella is a user-owned mental-load device). The LLM **may not** propose umbrella shape unprompted; if load signals appear it may raise the question **once**, and the user decides.

Recommend in this order:
1. **Split into N single-cycle Level 3 projects** (default). Name them; suggest directory layout (`projects/<a>/`, `projects/<b>/`).
2. **Defer slices to "later" via backlog** if some pieces aren't urgent.
3. **Umbrella only when** the user explicitly says they cannot hold the whole thing at once, or when ≥ 2 of meta's qualitative signals fire. Even then, ask first; don't unilaterally adopt.

### 4. Adapter Binding (WhittleSpec setup)

WhittleSpec reads project-specific bindings from `WHITTLESPEC.md` via the `ws-binding` accessor. Consuming skills never hardcode these (see `ws._meta/SKILL.md` § Layer Model and `ws._meta/executing.md` § Verification Binding).

**Report binding state** (as part of assessment, always): run `ws-binding get verification` in the project root. Exit 0 → a verification binding exists; report it. Exit 3 (no `WHITTLESPEC.md`) → report "unconfigured".

**Guided setup**: load `ws._meta/binding-setup.md` and run its per-concept blocks in order. That file is the single home for the procedure — accessor resolution, when setup runs, which bindings a consumer may default past, and one block per concept. It is the same file a consumer loads when it hits a missing binding mid-flight, which is why the procedure lives there and not here: a skill needing one binding must never be routed through a scale assessment to get it.

## Output

```
Scale assessment: Level [X]
Recommended approach: [description]
Next step: [specific action]
```

If Level 2+: "Want me to start with `/ws.1-requirements`?"

## Quality Checks

- Asked enough questions for accurate assessment?
- Level justified by concrete signals, not gut feel?
- Level 4: proposed N single-cycle projects as the default split, not umbrella by reflex? Umbrella raised only if user signalled they cannot hold the whole thing at once?
