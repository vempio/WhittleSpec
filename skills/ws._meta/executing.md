# WhittleSpec Reference: Executing and Closing Work

What makes work done -- the evidence it owes, the bindings that resolve it, and the
gates that refuse a completion claim. Which skills load this chapter is recorded once,
in `ws._meta/SKILL.md` § Chapter routing.

## Verification

### Verification Binding

<!-- WS:IF-CONFIGURED verification-binding -->
The "full verification check" is a **project binding**, not a fixed command. WhittleSpec's doctrine is that completion is backed by a real, repeatable check run through its actual entry point; *which* command that is (`pytest -q`, a `make` target, a shell script, …) is environment-specific and therefore an adapter. It is resolved once at setup into `WHITTLESPEC.md` and read back with `ws-binding get verification` / checked with `ws-binding validate verification` — skills never hardcode a command and never silently re-derive one. A binding of `none` is a valid state (this project has no automated check) and shifts completion evidence to a demonstration. A missing or unresolvable binding fails loudly and offers reconfiguration rather than guessing.
<!-- /WS -->

### Invariant and Verification Enforcement

Correctness invariant ("output must be functionally identical," "API must remain backward-compatible") creates obligation spanning **all tasks**, not just task mentioning verification.

**First task producing covered output must produce exhaustive automated comparison.** "Exhaustive" = every output surface compared, not sample. Adversarial check: "What real difference would this comparison miss?"

**If exhaustive comparison impractical** (thousands of pages, combinatorial input space), document what is NOT compared and get explicit user sign-off. LLM must not unilaterally decide "enough." Present: "Comparison covers X. Does not cover Y because Z. Acceptable?"

**Comparison runs every subsequent task's completion gate.** STOP gate in `/ws.4-run` includes "Invariant verification: [command, result]." Task cannot be `[x]` if: comparison not run, never built, or not updated for new increment.

Hard gate, not aspiration. Known failure mode: LLM reads invariant, acknowledges, then implements without building/running comparison because ACs don't mention it. **Invariant applies to every task whether AC says so or not.**

### Exercise-Verified Before `[x]`

`[pair]` and `[checkpoint]` tasks are not `[x]` until the capability has been exercised against real state — not just inspected as prose / code / spec. "I read the implementation and it looks right" is implementation-verified, not behaviour-verified. Only live exercise closes the gap.

**Natural trigger unavailable?** Create a synthetic trigger, or keep the task `[~]`. Do not mark `[x]` on prose inspection alone with "will be exercised when a natural trigger arrives" as justification — that defers verification indefinitely and creates a pool of "shipped but unproven" capabilities.

Known failure mode: prose-heavy deliverables (SKILL.md prompts, config frameworks) have no compiler or test suite forcing the exercise. The LLM + user can mutually convince themselves a capability is done by reading the spec. Exercise is the discipline that replaces the missing forcing function.

This stacks with the **Demonstrability** rule under `ws._meta/SKILL.md` §Vertical Over Horizontal: demonstrability says _the task must produce something showable_; this rule says _that showing must happen before `[x]`, not as a promise_.

**No preemptive deferral.** When a task or integration milestone asks for a live exercise, attempt it. "The fixture might be unavailable", "the mount might be down", "this might cost money", "the operator can run it later" — all of these are unverified obstacles, not reasons to skip. The rule: **verify the obstacle first; defer only on a provably blocking condition, and state the verification** ("ran `<check>`, got `<result>`, therefore blocked"). Substituting a unit test for the live exercise is a category error — the milestone's whole point is to catch integration surprises the unit layer misses.

Known failure mode: LLM skipped a post-slice integration milestone with "requires mounted fixture; proxied by unit test". The fixture was in fact available and the milestone took three commands. User caught the dodge: "you ran it for the last slice... why get all anxious now?" The obstacle was imagined, not verified.

**Mocks prove structure, not reality.** The exercise must go through the REAL entry point — the shipped command / API a user actually invokes — not a test harness that calls an internal function, and not a unit test whose injected fake you authored. A fake encodes your *assumption* about the external seam (a CLI's argument grammar, a device's limits, an API's shape), so a green test built on it can only confirm that assumption — it cannot catch a wrong one. When a capability's correctness depends on a system you do not control (a subprocess CLI, hardware, an external API), completion evidence must cite ONE real invocation; the injected-fake test is then a regression guard whose fake is calibrated FROM that real run, never the first proof. If the real exercise is destructive or costly, flag it and get authorization — do not substitute a safe proxy and mark `[x]`.

Known failure mode: a task ships `[x]` on a green unit test whose injected fake returns success, while the real command rejects the very flag the fake accepted — the failure surfaces only when someone asks "did you actually run it?", after the broken path has already shipped. A harness that calls an internal function directly instead of the real entry point is the same dodge in milder form.

### Walking-Skeleton Adversarial Pass

Before declaring a walking-skeleton task `[x]`, run a small adversarial pass against the *walking skeleton itself*, not the full feature. Question: **"What customer or operator outcome would shipping ONLY this walking skeleton produce that we'd regret?"** Force at least three concrete scenarios, written as real-world headlines, not test cases. **At least one must concern the existing installed base** — an already-configured project or user hitting the *changed* behaviour — not only a new adopter exercising the new path. A change safe for newcomers can still break those already set up: an empty durability binding on a project configured before durability existed was a no-ship that the new-adopter regrets missed entirely.

Class surface example: "Buyer pays for a seat in a class that already met." / "Buyer pays for a seat in a class that's sold out and will never open." / "Buyer sees four class dates, every one already in the past."

If you cannot produce three plausible "we'd regret it" scenarios, you have not understood the surface well enough to ship the skeleton. If you can produce them and they are not addressed by tests, **the skeleton is not done** — either ACs are missing (back to `/ws.refine`) or tests are missing (extend before `[x]`).

The walking skeleton's `[VERIFY IN WALKING SKELETON]` markers in `plan.md` / `umbrella-plan.md` typically cover template/integration mechanics: does the framework express what we need, do downstream systems accept our output, does the responsive transition work. They do **not** typically cover domain validity: are the artefacts the walking skeleton produces safe to ship to a real customer? Negative ACs (see `ws.1-requirements` § AC negative-case discipline) close one half of this gap at requirements time. The adversarial pass closes the other half at completion time.

Known failure mode: walking skeleton ships with three `[VERIFY]` items met (template renders, the cart accepts the item, table stacks on mobile). Same walking skeleton sells seats to a class that's already over, because the eligibility filter was never on anyone's checklist. The `[VERIFY]` list was about mechanics; nobody asked "what could go wrong if a real buyer hits this page today?". Adversarial pass at `[x]` time forces that question.

### Pre-Existing Issues Are Not Excuses

Pre-existing bug discovered during implementation: **context, not dismissal.** Still broken. Users still experience it.

**Required:** (1) Surface immediately -- not footnote, not "low priority." (2) Assess severity honestly -- "pre-existing" != "low priority." (3) Create tracking artifact (tracker issue, appropriate priority). Deployment blockers flagged. (4) Trivial fix (< 10 min, no risk) -> fix now.

Known failure mode: LLM notes "pre-existing, not our fault" and moves on, untracked.

## Durability

A task marked `[x]` is a claim that the work is really done — and that claim is a lie in two distinct ways. It is **un-persisted** if its changes exist only as local edits the durable record never captured (this section). It is **un-exercised** if it was never run through its real entry point — passing tests are not the same as having tried it (see § Exercise-Verified Before `[x]` below). Completion requires both: durably recorded *and* observed working.

This section owns the first. Completed work is persisted and reviewable; the checkmark and the durable record must not diverge. HOW work is persisted (a commit, or another mechanism) and WHEN (per task, per slice, or at an explicit boundary) are adapter choices; THAT it is durably recorded before it counts as done is not.

### Durability binding

<!-- WS:IF-CONFIGURED durability -->
Completed work needs a durable, reviewable record, and HOW + WHEN is an adapter. The recommended DEFAULT is a git commit per task — done means committed, so a task marked `[x]` on an uncommitted tree is a "done-in-checkbox, pending-in-git" drift. Git-per-task is also the assumed fallback: when durability is unbound, skills default to it, so projects configured before durability existed keep working unchanged. A project may bind a non-git equivalent (any mechanism that persists the change and keeps it reviewable) and may bind the commit **timing** (per-task by default; per-slice or an explicit boundary otherwise); a non-git mechanism's concrete how-to (state-check, persist, revert) is recorded with the binding at setup, not inferred at run time. No "none" — durable completion is non-optional; the recommended git-per-task is replaceable, the invariant is not. Skills read the mechanism and timing with `ws-binding get durability`; the completion gate persists via them and never silently substitutes git for a declared non-git mechanism.
<!-- /WS -->

## Fail Fast, Loudly, and Helpfully

Errors surface immediately, never silently swallowed. Prefer crashing with clear message over limping in broken state. Reject invalid input at boundaries. Unexpected -> stop and report.

Error messages must: describe what happened (not "Error occurred") / include context (operation, input) / provide resolution hints / include relevant values ("Expected positive number, got -5").

## Tool use in autonomous skills

Skills designed to run autonomously (e.g. `ws.fix`) MUST use their harness's native, non-interactive file operations for searching, reading, and writing — never shell commands that trigger an approval prompt, which would break the autonomy guarantee. Shell execution is reserved for what genuinely needs it: running the verification suite, build targets, version-control operations.

<!-- WS:EXAMPLE claude-code-tools -->
On the Claude Code harness that maps to: **Search** `Grep` / `Glob` (not `grep` / `rg` / `find` via Bash); **Read** `Read` (not `cat` / `head` / `tail`); **Write** `Edit` / `Write` (not `cat >` / `echo >` / `sed -i`); Bash only for test suites, `make` targets, and git.
<!-- /WS -->
