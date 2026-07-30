---
name: ws.sweep
description: Completeness sweep -- exhaustively verify nothing was missed after a change.
---
# ws.sweep

Load shared context: `ws._meta/SKILL.md` — the sibling skill in the same skills directory this skill loaded from (resolves under any clone name, install location, or skills-root override). Also load: `ws._meta/executing.md`.

## Purpose

After any non-trivial change, exhaustively verify nothing missed. Goes beyond search-and-replace: covers stale references, orphaned content, broken cross-references, inconsistent docs. Shallow verification is proven, recurring failure mode. Checking only files you touched is not verification -- value is in finding what you DIDN'T touch but should have.

## When to Use

After renaming files/functions/variables/commands / after migrating patterns / after moving content between files / after changing doc structure/workflows / after any change applying consistently across multiple files / paranoia check before committing cross-cutting changes.

## Process

### 1. Define What Changed

State explicitly: **What happened** (rename? content move? structural change?) / **Old state** (removed/replaced/relocated?) / **New state** (replacement, new location?) / **Scope** (which dirs/files to check? Default: entire repo).

### 2. Identify Ripple Effects

Before searching, think through what ELSE could be affected: Who references this? (files / docs / READMEs / Makefiles / configs / scripts / prompts / indexes) / Who depends on it? (downstream consumers / build systems / CI / symlinks / imports) / What documents describe it? / What assumes old state? (hardcoded paths / examples / tutorials / templates) / Index or TOC still matches reality? / Numbered sequences still flow after insertion/removal? / Cross-references between docs still correct? / Tracker consistency? (issue summaries matching scope / issues mapping to slices / issues in wrong status?)

### 3. Exhaustive Residual Search

For EACH old pattern/name, grep entire repo. Success criterion: **zero matches**. Any match is finding.

**Be adversarial generating search patterns.** Systematically generate variants: with/without prefix (`/old.name`, `old.name`) / different contexts (backticks, headings, prose, comments, frontmatter) / partial matches as substring / case variants / hyphen/underscore/dot permutations / singular/plural, abbreviated forms / surrounding context ("the X module" not just "X") / related terms (error messages / help text / log strings / comments mentioning by description).

### 3b. Rendered Output Verification

For changes affecting URLs/routes/content transformed before delivery (Hugo templates, build systems), source-level grep not sufficient -- old pattern may appear in rendered output even when source clean. **When to apply**: Any URL migration / route change / content restructuring where source transformed before user sees it. **Process**: Build/serve locally. Grep rendered output for old patterns. Success: zero matches in rendered output, not just source.

### 4. Structural Consistency Check

Beyond text patterns -- verify structural integrity: **Cross-references**: "see document B, section X" -- does that section still exist? / **Indexes/listings**: README lists commands/files/modules -- matches what actually exists? / **Sequences**: Still flow after change? / **Transitions**: "proceed to B" -- B still right next step? / **Scope claims**: "covers X, Y, Z" -- still accurate? / **Internal consistency**: Heading, frontmatter, body all agree? / **Parallel structures**: Several files follow same pattern -- change maintained it? / **Work ledger** (per `ws._meta/SKILL.md` § Work-ledger binding): tracker bound — linked issues still match spec reality? `local` — the task/spec files are internally consistent with what shipped?

### 4b. CLI Usability and Documentation Smoke Test

**When feature has CLI interface**, exercise it (don't just grep):
1. Run `<cli> --help` (top-level AND each subcommand) -- produces usage info, not error?
2. Run `<cli> <unknown-subcommand>` -- helpful error (names unknown, lists alternatives)?
3. **Doc file check**: Task names doc file path? Verify exists. No doc file but BDD scenarios exist = gap (BDD implies documentation).
4. **Doc completeness**: Check against `ws._meta/workflow-doc.md` template: Overview / Typical Operator Workflow / Quick Reference / Subcommands / Error Catalog / Configuration / Exit Codes.
5. **Smoke-run documented workflows**: Try documented commands with `--dry-run` or `--help`. Commands that fail = findings.

**BDD-Documentation cross-reference** (bidirectional): Forward -- each workflow step in operator guide has BDD scenario? / Backward -- BDD scenarios hinting at undocumented workflows?

### 4c. BDD Scenario-Task Correspondence (when `.feature` and task files exist)

**Bottom-up audit.** Start from scenarios, not task claims.

**Step 1: Map every scenario to task.** Examine: scenario's behavior (which ACs?) / task's "BDD green" lines and ACs / tags hinting at scope.

```
Scenario                              | Task | Task Status | @todo?
--------------------------------------|------|-------------|-------
Generate pending certificates         | 2b   | [x]         | no
Field validation -- language           | 2a   | [x]         | YES  <-- FINDING
Send with attachment                  | 3a   | [~]         | no
Full pipeline                         | --   | --          | yes  <-- ORPHAN
```

**Step 2: Flag discrepancies.** CRITICAL: `@todo` under `[x]` task = task marked done but scenario never activated. Orphan scenarios not tracing to any task -- surface them. Missing scenarios: task's ACs/BDD-green claim behavior but no corresponding scenario exists = gap.

**Step 3: Candidate scenarios for current task.** If sweep running during `/ws.4-run`: read task's ACs and BDD-green commitments, search feature file for matching scenarios including `@todo` that should have been activated. `@todo` fitting current task's scope is unfinished work for this task.

### 5. Report

```markdown
## Sweep Results

**Change**: [Brief description]
**Scope**: [What was searched]

### Residual Matches (old patterns)

| Pattern | Matches | Files |
|---------|---------|-------|
| `old_name` | 0 | -- |
| `/old_name` | 2 | file_a.md:31, file_b.md:72 |

### Structural Issues

| Issue | Location | Detail |
|-------|----------|--------|
| Stale cross-ref | workflow.md:68 | Points to old command name |
| Index mismatch | README.md | Lists 5 items, 6 exist on disk |

### BDD Scenario Audit (when .feature and task files exist)

| Scenario | Task | Task Status | Scenario Status | Finding |
|----------|------|-------------|-----------------|---------|
| ... | ... | ... | ... | OK / CRITICAL / ORPHAN / MISSING |

- **Critical**: N scenarios @todo under completed tasks
- **Orphans**: N scenarios not traced to any task
- **Missing**: N task commitments with no corresponding scenario

### Verdict

[CLEAN / N issues found -- list them]
```

### 6. Technical Debt Spot Check

After residual/structural checks: dead imports/config from removing/renaming? / orphaned files from migration? / stale comments referencing old names? / debt marker consistency (run audit from `ws.tdd._meta` > Technical Debt Protocol -- each `FIXME: [DEBT]` must have paired `@debt` test and vice versa; has any marker's re-enable condition been met?).

**Threshold**: Trivial debt (< 5 min, no risk) -- fix as part of sweep. Substantial -- flag for dedicated task. Sweep's job: leave codebase cleaner than found.

### 7. Fix

Issues found: fix immediately, then re-run sweep to confirm zero residuals.

## Anti-Patterns

- Declaring "done" after fixing known matches without re-sweeping
- Searching only files you touched
- Searching one variant but not others (`/foo` but not `foo` in backticks)
- Asserting "nothing references X" without grep proof
- Checking only text patterns when change was structural
- Skipping docs and workflow files because "they're not code"
- Trusting task `[x]` status without verifying BDD scenario state -- `@todo` invisible to runner (skipped), "all tests pass" is not evidence
- Checking only top-down from task claims -- always also scan bottom-up from scenarios
- Grepping for `--help` handling instead of actually running CLI
- Assuming documentation exists because no one complained
- Trusting BDD scenarios cover documented workflows without bidirectional check
