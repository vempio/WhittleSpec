---
name: ws.fix
description: Autonomous quality pass -- analyze, fix, and report. Usable mid-slice or end-of-slice.
---
# ws.fix

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/executing.md`, `ws._meta/binding-setup.md` (this skill resolves verification, evidence and durability bindings), and the four files whose procedures Phase 1 runs: `ws.tdd.review/SKILL.md`, `ws.tdd._meta/SKILL.md` (the quality standards that review checks against), `ws.sweep/SKILL.md`, `ws.review/SKILL.md`.

## Purpose

Find problems, fix what you can, report what you can't. Replaces manual ws.tdd.review + ws.sweep + ws.review + test suite + fix-all + re-sweep. Mid-slice (quick pass) or end-of-slice (thorough).

## When to Use / Tooling Rules

After completing tasks / end of slice before `/ws.9-retro` / quality drift during long session / picking up after break / after parallel sessions on interacting work.

**Native tools (Grep, Glob, Read, Edit, Write) for all analysis and fixes.** Bash is for running the bound verification command and for the bound durability mechanism's persist and undo — the two places this skill must reach outside the file tree.

## Process

### Phase 1: Parallel Analysis

Run simultaneously (subagents where possible), pool results:

1. **Verification baseline**: resolve the project's check — `ws-binding get verification`, validated before use (branches as in `ws.4-run` §1a, including the runners not to assume). Run it and record the baseline: N pass, M fail, K skip. Binding is `none` → there is no baseline to take; record that instead, and Phase 4 compares evidence rather than counts. No record at all → load `ws._meta/binding-setup.md`, run its `verification` block or name that action; do not guess a runner.
2. **Test quality review**: run `ws.tdd.review/SKILL.md`'s Evaluate step against the loaded `ws.tdd._meta/SKILL.md` standards, at maximum depth, via native Read. **"Maximum depth" = hard requirement.** If shallower than standalone `/ws.tdd.review`, skill failed. **Adversarial pass mandatory**: select 20% of tests (min 3), describe subtly wrong impl that would still pass. Weak assertion = finding. Highest-value part, must not skip.
3. **Completeness sweep**: run `ws.sweep/SKILL.md`'s Process via Grep/Glob. Stale refs, broken cross-refs, orphaned content.
4. **Spec review**: run `ws.review/SKILL.md`'s Process in composable mode. Read specs, compare against implementation.
5. **BDD status**: Read `.feature` files. `@todo` scenarios blocked by tasks now `[x]`?
6. **Tracker alignment** (if applicable): Issues reflect actual scope/status?

### Phase 2: Dual Adversarial Filter

**Filter 1 -- inward**: "Confident enough to fix without asking?" Bar: **my understanding provably matches user's.** Boilerplate/obvious choice -> act. User would have opinion -> surface. Spec silent/ambiguous -> silence = gap, not permission, surface.

**Why**: Manual programming forces resolving spec ambiguities. LLMs skip this -- silently filling gaps. LLM speed advantage = where details don't matter. Risk = where they do but LLM treats them as if they don't.

**Filter 2 -- outward** (items passing filter 1 only): "Does user need to hear about this fix?" Renamed import, fixed typo = DONE. Filter 2 may ONLY suppress items passing filter 1.

Four buckets: **BLOCKING** (failed filter 1, blocks progress) / **ASSUMPTIONS** (passed filter 1 with caveats -- fixed, user verifies) / **REVIEW** (failed filter 1, non-blocking, needs judgment) / **DONE** (passed both, trivial, high-confidence).

### Phase 3: Act

Fix ASSUMPTIONS and DONE via Edit/Write. ASSUMPTIONS: fix AND flag. Safety net = reversibility: git revert by default, or the bound durability mechanism's undo (`ws-binding get durability`; see `ws._meta/executing.md` § Durability). Don't touch BLOCKING or REVIEW.

### Phase 4: Verify

Re-run the bound verification against the Phase 1 baseline. Regressions: revert the fix, move to REVIEW. Where verification is `none` there is no count to compare — apply the evidence floor instead (`ws-binding get evidence-profile`; unbound derives from verification, see `ws.4-run` §1b) and show the artefact exercised through its real surface. Persist survivors by the bound durability mechanism (`ws-binding get durability`; see `ws._meta/executing.md` § Durability and `ws.4-run` §1c, which is where the git default is stated once), labelling the unit as a quality pass with a one-line summary.

### Phase 5: Summary

```markdown
## Fix Summary
**Test suite**: N pass, M fail, K skip (was: N0 pass, M0 fail, K0 skip)

### BLOCKING (must resolve)
- [Full context. Why blocks. What to do.]

### ASSUMPTIONS (applied -- verify or revert)
- [Assumption. Action. How to revert — via the durability mechanism.]
  Under git: `git diff <commit>~1 <commit> -- <file>`

### REVIEW (needs your judgment)
- [1-2 sentences with enough context to decide.]

### DONE (N items, collapsed)
<details>
- [One-line per fix]
</details>
```

**Discipline**: BLOCKING 0-3 (>3 = deeper problems) / ASSUMPTIONS each genuinely non-trivial / REVIEW 0-5 (batch similar) / DONE collapsed, one line each.

## Scope Detection

**End-of-slice** (all tasks `[x]`): Full ceremony -- all six streams, BDD completion, tracker sync, spec drift. **Mid-slice** (some `[ ]`/`[~]`): Skip tracker sync and BDD completion. Focus test quality, sweep, spec drift for completed tasks.

## Anti-Patterns

**Speed over fidelity** (value = finding problems, not finishing quickly) / **success theater** (uncertain fixes as DONE -- when in doubt -> ASSUMPTIONS) / **noise flooding** (trivial in ASSUMPTIONS trains user to ignore bucket) / **skipping re-verification** (every fix = potential regression) / **reverting parallel work** (unexpected file states may be parallel sessions -- never revert without asking) / **"pre-existing" as dismissal** (review's job = find and fix, not assign blame; every issue: severity assessment -> fix if <15 min -> or tracking artifact).
