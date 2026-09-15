---
name: ws-tdd-outline
description: Phase 2 -- tree-level test design, examining intent and approach per test.
---
# ws.tdd.outline

Load shared context: `ws.tdd._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override).

## Purpose

Design individual test cases. For each idea: what it tests, what it does NOT test, exact AAA steps.

**Cognitive mode: Tree, not forest.** Depth over breadth.

## Prerequisites

- Test ideas from `/ws.tdd.idea` (Phase 1), reviewed and approved by human

## Process

### 1. Select Ideas

Ask: "Which ideas should I outline?" (or confirm if human specified). If "all", proceed in logical groups.

### 2. Write Outlines

Enrich existing `todo`-marked stub with structured outline (docstring/comments). Outline describes **scenario**, not mechanics -- survives as "why" layer above "how."

AAA comment failure modes:
1. **Too mechanical** (restates code): `# Arrange: monkeypatch X to return Y` -- pseudo-code. Adds nothing.
2. **Too absent**: loses scenario narrative. Reader sees *what* but not *why*.
3. **Scenario narration** (sweet spot): *situation*, *domain-level action*, *expected truth*. Problem-domain language.

Good-AAA test: helps understand story without reading code? Restates code -> delete. Deleting loses *why* -> keep. Take space for complex goals. Balance specificity/freedom -- don't prescribe so tightly outline becomes pseudo-code.

```python
# BAD -- too mechanical (restates code):
# Arrange: create a path "/nonexistent/path/data.xml"
# Act: call OutputMapper(bad_path)
# Assert: raises FileNotFoundError

# BAD -- too absent:
# (no comments, just docstring)

# GOOD -- scenario narration:
# Arrange: a path that cannot exist on any filesystem
# Act: construct the mapper -- failure must happen here, not later
# Assert: FileNotFoundError at construction time, not at first use
```

```python
@pytest.mark.todo
def test_output_mapper_throws_on_missing_file():
    """Verify fail-fast on missing file -- must fail at construction,
    not silently at first use.

    Boundaries: Only tests missing file; malformed content is separate.
                Does not test error message wording.
    """
    # Arrange: a path that cannot exist on any filesystem
    # Act: construct the mapper -- failure must happen here, not later
    # Assert: FileNotFoundError at construction time, not at first use
    pytest.skip("TODO: Outlined, not yet implemented")
```

```cpp
TEST_CASE("OutputMapper throws on missing file", "[.][todo]") {
    // Goal: Verify fail-fast on missing file -- must fail at construction,
    //       not silently at first use
    // Boundaries: Only tests missing file; malformed content is separate.
    //             Does not test error message wording.
    // Arrange: a path that cannot exist on any filesystem
    // Act: construct the mapper -- failure must happen here, not later
    // Assert: FileNotFoundError at construction time, not at first use
    SKIP("TODO: Outlined, not yet implemented");
}
```

**Batch size: the Outline rate limit in `ws.tdd._meta`.** Align batches to topic groups — neither fragment a group to hit the target exactly, nor batch everything because each topic is "whole." See also "Batch Processing Flow" there.

### 3. Challenge Assertion Precision

For each outline: Deep enough? ("not empty" vs. "correct count" vs. "correct content") / Exact expected values? (count==3, not count>0) / Right thing? (behavior vs. implementation detail) / False positive? (passes but code wrong) / **Clearing path**: sets mutable state -> companion test verifies **cleared** state? Every "set" needs tested "clear." Untested = latent bug (state accumulates across cycles).

## Output

Enriched `todo`-marked stubs with Goal/Boundaries/AAA. Tests remain skip-marked.

## Behaviors

- Primary activity = outlining, not generating new ideas
- New idea discovered: record placeholder, flag to human. Don't silently expand scope; don't lose discoveries.
- State what test does NOT cover (as important as what it does)
- "Checks output is correct" = wish, not outline
- Idea is multiple tests -> split, explain why
- **Shared setup**: Common Arrange patterns -> note for shared fixture during red
- **Outline desired behavior, not current**: Code wrong -> outline what it *should* do. Test fails red, green fixes. Never fix production before outline exists.

## Anti-Patterns

- Writing executable code (Phase 3)
- Mechanical AAA restating code / absent AAA leaving only docstring / vague AAA ("output is correct")
- Fragmenting topic group to hit the target exactly / batching all remaining because each is "whole"
- Drifting to forest-level -- flag: "Should we return to `/ws.tdd.idea`?"

## Gate

Present outlines. Wait for review before `/ws.tdd.red`. Human may revise assertions, adjust boundaries, question depth.
