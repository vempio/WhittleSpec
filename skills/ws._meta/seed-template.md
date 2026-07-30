# Seed Template

Suggested structure for `specs/<feature>/seed.md`. Sections marked
**floor** are present in every seed; the rest are included when they
earn their place. Drop sections that don't apply rather than padding
them.

A seed is a captured proto-spec — discovery context, open questions,
impact, and a recommended next step. It differs from an idea
(`specs/_ideas.md`) by **active engagement**: the operator is
pondering it, not just parking it. The seed's *Recommended Next Step*
makes that engagement operational.

---

```markdown
# Seed: <feature name>

**Status**: seed (not yet activated for SDD)
**Created**: YYYY-MM-DD
**Source**: <what surfaced this — e.g., "discount-workflow retro 2026-02-20",
            "conversation with X on date", "LooseEnd review", and why
            it's worth pondering now>
**Related** (optional): <tracked issue, parent spec, prior research path>

## Discovery   <!-- floor -->

<One paragraph. What surfaced this, in what context, why it's worth
engaging with now. Describe the gap or observation, not the solution.
If real options exist, sketch them here rather than as a separate
section.>

## Present Understanding   <!-- often -->

<One or two paragraphs sketching what shape this might take — what
value it would deliver, what the rough approach looks like, what
alternatives are on the table. Descriptive, not prescriptive.>

## Open Questions   <!-- floor -->

<Bulleted. Distinguish where useful:>

**For spike / investigation:**

- <question answerable by trying / measuring / reading docs>

**For requirements / decision:**

- <question requiring a decision the operator must make>

## Impact If Ignored   <!-- often -->

<1-3 sentences. What gets worse, stays broken, gets missed. The
prioritisation hint — distinguishes "blocking X" from "would-be-nice".>

## Related Artifacts   <!-- often -->

<Paths to specs, docs, code, tracked issues, prior research.>

## Recommended Next Step   <!-- floor -->

<Concrete. "Run /ws.spike on Y" / "Activate /ws.1-requirements when Z
threshold is met" / "Wait until trigger condition W". This is what
marks the seed as active engagement, not passive capture. If you
can't name a next step, the item is an idea, not a seed — move it to
`_ideas.md` instead.>

---

## Optional sections (include when they earn their place)

### Out of Scope (here)

<When scope creep risk is real — adjacent areas that might get
confused with this one. Skip if the boundary is obvious.>
```

---

## Notes on use

- **Length:** seeds are typically 30-100 lines. Longer is fine when
  the seed is genuinely scoping a complex area (see
  `examples/example-offline-sync/seed.md` for an example of a long seed
  that earns its length). Shorter is fine when the scope is small
  (see `examples/example-csv-export/seed.md` for a ~36-line seed that
  covers everything needed).
- **Headings:** the exact header text is suggestion, not contract.
  Existing seeds use "Discovery" / "Discovery Context" / "Problem"
  interchangeably. Pick what fits.
- **Graduation to spec:** when the seed is ready, `/ws.1-requirements`
  reads `seed.md` as input. The seed's *Discovery* becomes the
  user-story / value framing; *Open Questions* become the Decisions
  block; *Impact If Ignored* informs prioritisation.
- **Graduation to a tracked issue:** if pondering reveals the work is
  small / clear enough to skip spec rigor, create a tracked issue and
  delete `seed.md`. The issue is now source of truth; no pointer
  entry stays behind (see `ws._meta/lifecycle.md` § Capture Surfaces).
- **Graduation back to idea:** rare but valid. If engagement drops
  and the seed loses its Recommended Next Step, demote it: append
  to `_ideas.md` and delete the seed directory.
