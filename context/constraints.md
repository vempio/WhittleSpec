# Project Constraints and Invariants

Invariants are statements that must hold at all times, across every spec in this
project. They are not goals or preferences: no requirement, AC, plan, or
implementation may contradict one. When an invariant and a convenience conflict,
the invariant wins and the convenience is redesigned.

They sit *above* requirements: an invariant steers what gets elicited and how it
is structured, rather than being produced by elicitation. It may be discovered or
sharpened while writing requirements, but its scope is the project.

**Discriminator**: if a statement constrains only one spec, it is an acceptance
criterion for that spec, not an invariant. Spanning more than one spec is what
makes it an invariant — concreteness is not the test ("never writes more than one
file at a time" is a perfectly good invariant).

**Why they exist**: insurance against model drift. An LLM re-deriving a local
decision picks the locally plausible option and moves on; an invariant is a
standing veto that does not depend on the model happening to remember the context
that made the option wrong.

Each invariant carries a **violation test** — the concrete question that decides
whether a given change breaks it. An invariant with no test is a slogan.

## How invariants arise

The common path is a rejected suggestion whose rejection generalises. A proposal
is made; it is not merely wrong here — the whole *class* of proposal is unwanted
and should not be raised again. That is the trigger, and the test at the moment
of rejection is "would I want this class of suggestion brought up in future?" If
no, an invariant is owed.

Stating it once replaces correcting the same class repeatedly, which is what
makes invariants drift insurance rather than documentation.

INV-1 arose exactly this way (2026-07-27): shipping WhittleSpec as a Claude Code
plugin was proposed as a namespace fix; the objection was not to the plugin
mechanism but to the entire class of harness-confined dependencies.

## What an invariant obliges

Three duties, not one:

1. **Steer** — requirements, plans, tasks and ACs are generated against the
   invariant set, not merely checked after.
2. **Review forward** — every newly-generated artefact is weighed against the set
   before it is accepted. Violations get in by accident, not by intent.
3. **Sweep backward** — adding an invariant creates a debt: the existing corpus
   predates the rule and was written without it. Each invariant therefore carries
   an **audit status**, so the debt stays visible instead of being assumed
   discharged.

## INV-1: Harness-agnostic

WhittleSpec must not depend on technologies confined to a particular agent
harness. Doctrine, artefacts, and mechanisms must work wherever a POSIX shell
and an agent that reads instruction files exist.

**Violation test**: would this stop working, or lose its meaning, if the adopter
ran WhittleSpec under an agent other than Claude Code? If yes it violates INV-1,
unless the harness-specific part is enclosed in a `WS:EXAMPLE` marker whose CORE
text states the harness-neutral requirement. (An illustration does not create a
dependency; a mechanism does.)

**Applies to**: skill prose, the binding record and its accessor, the installer,
the distribution channel, and the discoverability/invocation surface.

**Known-compliant precedent**: `ws._meta` §Tool use in autonomous skills — CORE
says "their harness's native, non-interactive file operations"; the Claude Code
tool-name mapping sits inside `WS:EXAMPLE claude-code-tools`.

**Known open exposure**: skill *invocation* is slash-command-shaped, a Claude
Code extension over the Agent Skills standard. See `specs/_ideas.md`; the seed
that raised it closed 2026-07-29 (`specs/_completed/whittlespec-namespace/`).

<!-- WS:EXAMPLE inv1-audit-citations -->
**Audit status**: SWEPT 2026-07-27, findings open. Prose CLEAN (only backticked
Claude Code tool names sit at `ws._meta:547` inside `WS:EXAMPLE
claude-code-tools`; manual grep and `ws-layer-check` agree). FIXED:
`skills/README.md` documented the pre-Slice-1 `~/.claude/skills/...` resolution.
FIXED (2026-07-27): both installer findings, in one edit.
`WS_SKILLS_DIR` is now the global interface and `WS_PROJECT_SKILLS_DIR` the
per-project one, so neither path is hardcoded; the Claude Code layout survives
only as a marked `WS:DEFAULT claude-code-skills-dir` default, which is the
known-compliant shape (CORE states the neutral requirement, one harness's
convention sits inside a marker). Verified by hermetic install and verify into
temporary directories under both variables. OPEN: the `user-invocable` frontmatter field
(invocation control is a Claude Code extension over the Agent Skills standard)
and the slash-command invocation surface. BLOCKED: `ws-layer-check`'s denylist
catches `Grep|Glob|Bash` but not `Read|Write|Edit|Agent|Task` — those are common
English words and the denylist matches word-sense, so extending it waits on the
tracked denylist word-sense refinement.
<!-- /WS -->

## INV-2: WhittleSpec owns only its own artefacts

WhittleSpec must not create, modify, or claim authority over files, names, or
namespaces belonging to the adopter. Its own structures (`WHITTLESPEC.md`, the
spec tree, its skills) hold everything it needs. The single sanctioned outbound
write is a *pointer* to `WHITTLESPEC.md`.

**Violation test**: does this cause WhittleSpec to write into, define content
inside, or occupy a name in a file or namespace the adopter owns — beyond that
one pointer? If yes, it violates INV-2.

**Applies to**: agent-instruction files (`CLAUDE.md`, `AGENTS.md`), the skill
namespace, generated project scaffolding, and any file the framework creates in
an adopter's repository.

**Derivation** (2026-07-27): `ws.9-retro` read its destination set from the
adopter's own `CLAUDE.md`; the objection generalised beyond that sentence to the
whole class — "maybe the user wants to use CLAUDE.md / AGENTS.md in their own
way, and we shouldn't pollute it, other than e.g. referencing WHITTLESPEC.md".

**Consequence (ratified 2026-07-27)**: this largely settles
`specs/_completed/whittlespec-namespace/` (closed 2026-07-29). Claiming 22 unprefixed top-level skill
names is occupying a namespace the adopter owns, so the prefix route follows and
"status quo plus installer guard" does not survive. It also moves
`ws.init` generating `CLAUDE.md` (Slice 6) from undesirable to
in violation.

**Audit status**: SWEPT 2026-07-27 on ratification. VIOLATIONS:
`ws.init` generates `CLAUDE.md` (all tiers) and a `Makefile`
(Operational+Strategic) — both adopter-owned; the 22 unprefixed top-level skill
names, symlinked into the adopter's skills root by the installer. RESOLVED
(operator, 2026-07-27): when neither `CLAUDE.md` nor `AGENTS.md` exists, create
both carrying the pointer line only — the second file is what lets the adopter
switch harnesses. When either exists, stay hands-off beyond the pointer. **No
symlinking**: the reason people symlink these files is substantial duplicated
*content*, and we write none — the source of truth is `WHITTLESPEC.md`, so there
is nothing to drift. Symlinks are also platform-conditional (Windows without
developer mode materialises them as plain files holding the target path), which
INV-1 rejects, and deciding one adopter file *is* another is a structural claim
INV-2 forbids. An adopter who wants the symlink makes it themselves, and anchor
respects it — verified both directions, regression-covered by
`test_anchor_respects_operator_symlink`. RESOLVED (2026-07-29): `ws.init` no longer
generates build tooling at any tier — its output section names the refusal and whose
artefact it is. RESOLVED (2026-07-29): the namespace occupation is closed both ways —
all 22 shipped skills carry the `ws.` prefix, and the installer refuses to place a
shipped directory outside that namespace instead of trusting the download, while a
prefixed name already held by something foreign is left alone and the install exits
non-zero rather than reporting success over a name it did not claim. Regression-covered
by `test_unprefixed_shipped_skill_is_not_installed` and
`test_conflict_on_a_shipped_name_exits_nonzero`. CLEAN: Makefile references in `ws.4-run` / `ws.sweep` /
`ws._meta` are reads and work-product, not framework writes; `ws.9-retro` writes
`process-backlog.md` only where the adopter declared it (Slice 5 binding).

Boundary used by this sweep: WhittleSpec's own structures (`WHITTLESPEC.md`,
`specs/`, `PROJECT_INTENT.md`) may be created freely; the adopter's
(`CLAUDE.md`, `AGENTS.md`, `Makefile`, `README`, source tree) may not, beyond the
single pointer.
## INV-3: Implementation-agnostic

WhittleSpec must not prefer, assume, or depend on a particular programming
language, test framework, or library. Concrete technologies appear only as
clearly marked examples, or as an adapter choice the project selects.

**Violation test**: would this doctrine, workflow, or acceptance condition still
hold if the concrete language, framework, or library were replaced? If not, is
the dependency explicitly selected through an adapter, or confined to a marked
example? The test is semantic, not lexical — naming a framework is not itself a
violation, and a hidden dependency described without naming its product still
is. A grep for proper nouns is a useful aid *after* passages are classified, not
the invariant itself.

**Applies to**: CORE doctrine, phase skills, acceptance criteria, evidence
requirements, and the validator's own denylist.

**Derivation** (ratified 2026-07-27, as R29 of the review reconciliation): the
BDD phase skills called pytest-bdd "preferred for new projects". The objection
generalised past that sentence — the whole class of framework preference in
doctrine is unwanted, and the framework must remain implementation-agnostic
except where an example says so.

**Audit status**: RATIFIED 2026-07-27, sweep OWED. The corpus predates the
invariant. Known exposure: `ws-layer-check` reports 65 findings over the skill
corpus, of which 21 name a concrete test framework. Those 21 need semantic
classification into (a) normative preference — remove or generalise, (b) valid
example or adapter material — mark or relocate, (c) denylist word-sense false
positive — fix the validator. The classification pass *is* this invariant's
retroactive sweep; the two run together rather than twice.

