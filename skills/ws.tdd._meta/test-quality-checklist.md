# WhittleSpec Reference: Test Quality Checklist

The criteria a test review evaluates against, and the adversarial pass that closes it.
Loaded by `ws.tdd.review` (its Evaluate step) and by `ws.fix` (Phase 1's test-quality
stream), so the standalone review and the autonomous pass apply one bar instead of two
paraphrases of it. Which skills load this is recorded in
`ws._meta/SKILL.md` § Procedure routing.

Check each test against `ws.tdd._meta/SKILL.md` § Quality Standards:

**Technical Debt (`@debt`) Scan** -- Before evaluating individual tests, run the debt audit from `ws.tdd._meta/debt-protocol.md` § Technical Debt Protocol. For each marker/test: verify structured comment block complete / bidirectional link intact / re-enable condition hasn't been met. Process violations (Critical): `@debt` test missing structured comment / `@debt` test with no `Code reference` back-reference / `FIXME: [DEBT]` in code with no corresponding `@debt` test.

**Success Theater** -- Trivial assertions (asserting a literal truth, a no-op check, anything that cannot fail whatever the code does)? / Tests that cannot possibly fail? / Skipped tests that shouldn't be? (Skip acceptable for TODO outlines and deselected categories, never for convenience.) **Fixture fail semantics**: Credential/infrastructure fixtures that *skip* when the resource is absent, where they should error? A missing API key or DB URL is a configuration error, not an optional category -- and a skipped test reports neither pass nor fail, so the run still exits successfully and the gap is invisible. Required infrastructure must fail loudly, raising rather than skipping. **Error severity audit**: For each test asserting warning/skip/default-value/silent-return on error path -- is that actually correct? Project principle: *fail fast, fail clearly, fail completely*. For each lenient assertion: "If production handles this silently, what's worst?" Data integrity loss / financial impact / security exposure / invisible compounding -> test should assert loud failure, not graceful degradation.

**Assertion Precision** -- Exact expected values, not defensive ranges (`== 1` not `>= 1`)? / Collections checked for content, not just presence/count? / Error messages validated, not just exception types? Error messages helpful and actionable? / Return values checked specifically, not just truthiness? / Would subtly wrong implementation still pass?

**State Lifecycle Coverage** -- For each mutable state production code manages: test exercising **full lifecycle** (set -> effect -> clear -> verify cleared -> operate again)? **Audit method**: Read production code, for every field assigned/mutated, grep test file for assertions verifying field *reset*. No test clears and verifies post-clear = finding. Classic failure: boolean flag set but never cleared; each test starts fresh so stuck flag invisible. **Cross-reference "set" sites**: State X set in Arrange but no test ever clears X and asserts afterward = clearing path untested.

**Structure** -- AAA pattern? / One behavior per test, or lumped? / Descriptive names? / Logical grouping?

**Documentation** -- Goals stated where non-obvious? / Boundaries (what's NOT tested) explicit? / JTBD in docstrings where applicable?

**Fragility** -- Coupled to implementation details? / Would refactor break these without changing behavior? / Hardcoded values that should be computed or parameterized?

**Data Strategy** -- Real data or excessive mocking? / Appropriate fixtures? / **Duplication**: Same setup repeated? Extract shared fixtures. / **Consolidation**: Similar tests combinable via parameterization? / **Fixture sizing**: For filtering/selection/partitioning tests -- fixture large enough that "correct subset" distinguishable from structural bugs? 3-item fixture where filters return 1 is suspect; 5-6 items with distinct subset sizes is minimum.

**Dead Code & Usage** -- Functions defined but never called from production? / Code tested but not used in application flow? / If test exercises method, does that method get called from real program flow? Unit test passing for code never executed = false signal.

**Test Level** -- Integration tests where unit suffice (or vice versa)? / Features affecting program flow verified with integration tests? / New method/function has test proving it's called from actual flow?

**BDD-Specific** (when `.feature` files and step definitions exist)

*Domain Language*: Steps use domain or implementation language? / Non-developer would understand? / Right abstraction level?

*Step Structure*: Given/When/Then used correctly? / "And" masking multiple actions in When? / Scenarios self-contained? / Background used for genuinely shared context?

*Step Reuse*: Definitions duplicated across files? / Similar steps consolidatable? / Vocabulary consistent?

*Scenario Quality*: One behavior per scenario? / Outlines used where data varies but behavior identical? / Scenarios test behavior, not implementation? / User messages checked for correctness/helpfulness/clarity/actionable guidance -- not just presence?

*Anti-Pattern -- Gherkin-Wrapped Unit Tests*: Scenarios testing internal logic with Given/When/Then sugar but not describing user-observable behavior. Step definitions bypassing application boundary.

*BDD-Documentation Correspondence* (when operator docs exist): **Forward (doc -> BDD)**: Each workflow step in operator guide has covering BDD scenario? / **Backward (BDD -> doc)**: Scenarios exercising undocumented workflows? / **CLI usability**: `@cli` scenarios for `--help` (top-level and per-subcommand) and unknown subcommand handling?

*Task Completion Audit* (when task file exists)

Cross-reference every BDD scenario against task file. **Bottom-up** -- start from scenarios.

For each scenario: 1) Which task does it belong to? 2) Task marked `[x]`? Scenario must NOT be `@todo` -- Critical if so. 3) `@todo` but task `[x]`? Report: "Task N claims done but scenario 'X' still `@todo`." 4) Active but no task claims it? Orphan. 5) `@todo` and task `[ ]`/`[~]`? Expected -- count them.

Also scan for scenarios that **should exist but don't**: read each task's ACs and BDD-green line, check for corresponding scenario.

**Traceability (when SDD context available)** -- Tests reference ACs via `AC:` tags? / Which criteria have coverage, which don't? / Tests without AC reference? Normal for edge cases/boundary/invariant tests -- flag only if scope creep.

**Adversarial Pass**

After checklist, pick 2-3 solid-looking tests and try to defeat them: **Wrong-implementation test**: Subtly incorrect implementation that still passes? Assertions too weak. / **Test seam bypass**: If tests use seam (env var, mock injection), does bypassed production code have independent coverage? / **Coincidental pass**: Could test pass for wrong reason? (Filter returning 1 from 1-item fixture.)

Report defeats with concrete example of wrong implementation that passes.
