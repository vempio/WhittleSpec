---
name: ws-tdd-red
description: Phase 3 -- implement failing tests, validating assertion quality and depth.
---
# ws.tdd.red

Load shared context: `ws.tdd._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also read `ws.tdd._meta/visibility-patterns.md` and `ws.tdd._meta/traceability.md`.

## Purpose

Turn outlines into executable test code. Not "does test run" but "does test assert right thing at right depth?" **Cognitive mode: Validation of validations.** Scrutinize every assertion -- checking what matters? deeply enough? subtly wrong impl still pass?

**Prerequisites**: Test outlines from `/ws.tdd.outline` (Phase 2), reviewed and approved by human.

## Process

### 1. Select Outlines
Ask: "Which outlines to implement?" (or confirm if human specified). **Max 3 per turn.**
**BDD awareness**: `.feature` files have `@todo` scenarios for this feature -> "Note: N BDD scenarios still `@todo` -- should route through `/ws.bdd.outline` -> `/ws.bdd.red`." Not blocker, surfaces gap.

### 2. Implement
Remove `todo` marker and skip, replace with real assertions. **Outline comments must survive** -- "why/what" above "how." Comments follow AAA structure, explain intent not mechanics. Comment redundant with code -> outline at wrong abstraction -- raise with human, don't silently drop.

```python
# Goal: Verify fail-fast behavior when input file doesn't exist --
#       missing files must be caught at construction time, not at first use
# Boundaries: Only tests missing file; malformed content is separate.
#             Does not test the error message content.
def test_output_mapper_throws_on_missing_file():
    # Arrange: use a path that cannot exist
    bad_path = "/nonexistent/path/data.xml"

    # Act + Assert: construction itself must fail, not a later method call
    with pytest.raises(FileNotFoundError, match=bad_path):
        OutputMapper(bad_path)
```

```cpp
// Goal: Verify fail-fast behavior when input file doesn't exist --
//       missing files must be caught at construction time, not at first use
// Boundaries: Only tests missing file; malformed content is separate.
//             Does not test the error message content.
TEST_CASE("OutputMapper throws on missing file", "[error]") {
    // Arrange: use a path that cannot exist
    auto bad_path = "/nonexistent/path/data.xml";

    // Act + Assert: construction itself must fail, not a later method call
    REQUIRE_THROWS_AS(OutputMapper(bad_path), std::runtime_error);
    REQUIRE_THROWS_WITH(OutputMapper(bad_path), Catch::Contains(bad_path));
}
```

### 3. Run Test Suite
Run **entire** suite. New tests **should fail** -- passing immediately -> investigate: vacuously passing (success theater)? existing code handles case (acceptable but steps too large)? Existing tests must still pass.

### 4. Review Failures
Each: **right reason** (missing impl, not test bug)? / informative message? / assertion depth matches outline intent?

### 5. Coverage Report (when SDD context available)
"X of Y acceptance criteria have executable tests. Outline only: [list]. Uncovered: [list]."

## Output
Executable, failing test code. Suite has been run.

## Behaviors
- Every assertion = design decision: "`assert len(result) == 3` enough, or also check `result[0].name == 'expected'`?"
- **Exact values, not defensive ranges.** `== 1` not `>= 1`. `== "success"` not `is not None`. Weak assertions worse than no test. See "Assertion Precision" in `ws.tdd._meta`.
- "Verify content" = verify content, not presence/count. Under-specified outline: note it, don't silently decide.
- Test independence: no test depends on another's execution/state. **Extract shared setup**: fixtures/helpers for common setup, vary only what differs.

## Anti-Patterns
**Success theater** (`assert True` / unfailable assertions) / **writing production code** (Phase 4) / **skipping new tests** (wrote it = runs) / **weakening assertions** ("check content" -> "check not empty") / **exceeding 3 per turn** / **catching exceptions** to prevent failure.

### Assertion Precision Checkpoint
After each batch, before gate: **"Would subtly wrong impl still pass?"** `> 0`/`is not None` where exact value known -> `== exact_value` / presence not content -> add content / type not value -> add value / one field ignoring related -> add missing. Fix before gate.

## Gate
Present tests + failure output. Wait for confirmation: (1) fail for right reasons (2) assertion depth correct (3) ready for `/ws.tdd.green`.

## After Green
Return for next batch (max 3/turn). All outlines done -> back to `/ws.tdd.outline`. See "Batch Processing Flow" in `ws.tdd._meta`.
