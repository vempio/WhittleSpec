# WhittleSpec Reference: Completeness Sweep Procedure

How a sweep establishes that nothing was missed: what changed, what could ripple, the
exhaustive residual search, and the structural checks text alone does not cover. The
report format and the hand-off stay with `ws.sweep`; this is the part `ws.fix` runs as
its own completeness stream. Which skills load this is recorded in
`ws._meta/SKILL.md` § Procedure routing.

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

