# WhittleSpec Reference: Narrow Binding Setup

The single home for binding a project's adapters. `ws.0-start` loads this for guided setup; any
consumer that hits a missing binding loads it and performs **only the concept it needs**.

## The narrow rule

A consumer needing one binding must never trigger a full scale assessment or `/ws.init` -- intent,
tier, portfolio, governance and seed work as the price of a missing verification command is
precisely the coupling this file exists to remove.

- **Required binding missing** -> perform that concept's block below inline, or name the exact
  command to run. Do not proceed on a guess.
- **Optional binding missing** -> use the documented default and **say which default was applied**,
  so an unbound value is visible rather than silent.
- Never re-derive a value a binding already answers.

## The accessor

`ws-binding.sh` sits in `ws._meta` -- `../ws._meta/ws-binding.sh` relative to the loading skill's own
directory, the same sibling rule that resolves `ws._meta/SKILL.md`, so it survives a copied install
as well as a symlinked one. POSIX sh, run from the project root, which is the directory holding
`WHITTLESPEC.md`. Invoke it as `sh .../ws-binding.sh`: a copied install may arrive without its
executable bit, and running it by path alone then fails into the cannot-run case below for no reason
other than a file mode.

Exit codes: `0` resolved, value on stdout -- **empty output means the concept is unbound**, and the
accessor does not distinguish that from a deliberately empty binding; `3` no record at all; `4`
bound command not runnable.

Those codes presuppose the accessor ran. When it *cannot* run -- no shell to run it, the script not
found, the skill's own location not resolvable -- the loop degrades instead of stopping: read
`WHITTLESPEC.md` directly, find the section whose heading names the concept, and take the single
`Binding:` line beneath it. The prose under that line carries the nuance exactly as it does on the
accessor path, because it is the same record either way.

Say that the fallback was used and why. What is lost is the accessor's discrimination, not the data,
so make the distinction its exit codes made for you: `WHITTLESPEC.md` absent is the `3` case -- not
configured, route to the setup block rather than guessing. The record present but holding no section
for the concept, or a section with no `Binding:` line, is the unbound case -- apply the documented
default and name it, exactly as on the accessor path. Degrading must not become stopping: the
fallback proceeds wherever the accessor would have.

What no longer holds is the guarantee against guessing, and that is the one place to be stricter than
usual. A section that is ambiguous, or two that could each answer, is a stop and a question -- never a
judgement call. This is a resilience path, not an alternative default: where the accessor runs, the
accessor decides.

The writes degrade the same way. `set` and `anchor` run throughout the blocks below, and where the
accessor cannot run they are performed by hand rather than skipped -- setup is usually the first thing
a project does, so a path that only reads would strand it at the start. `set` means: create
`WHITTLESPEC.md` if it is absent, give the concept the section heading listed under § Concepts at a
glance, and put a single `Binding: <value>` line directly beneath it -- replacing that line in place if
the section already holds one, so a reconfigure leaves no stale duplicate for a later read to find.
`anchor` means appending the pointer line to `CLAUDE.md` and `AGENTS.md`, and only where it is not
already there. Use the headings exactly as listed: the record has to be readable by the accessor on the
next machine, and a heading it does not recognise reads as unbound rather than as an error.

## The Binding line is a handle; prose carries the nuance

Each `WHITTLESPEC.md` section holds a `Binding:` line that `ws-binding get` returns, and may hold
prose beneath it. The line is what a consumer branches on. The prose is where the environment's
nuances live -- several test runners and which one is the completion gate, a suite too slow to run
per task, how an external tracker is actually reached.

Consumers read the line for the simple case and the prose when the simple case does not fit. This is
already how a non-git durability binding works, and it generalises: do not invent structured fields
for plurality that a sentence handles better.

## When setup runs

Lazily. Level 0/1 work is not forced through configuration for bindings it will not consume. Setup
is mandatory before the first skill that needs a binding, and at the latest before `/ws.4-run`.

## Concepts at a glance

The heading column is what the accessor matches on, and what a hand-written record must use.

| Concept | Section heading | Missing means | Consumer behaviour when unbound |
|---|---|---|---|
| `verification` | `## Verification` | no safe default exists | stop; run its block |
| `evidence-profile` | `## Evidence profile` | a floor; the AC's `Demo` carries the instance | derive the floor from `verification`, say so |
| `work-ledger` | `## Work ledger` | `local` is the floor | apply `local`, say so |
| `durability` | `## Durability` | git-per-task is the default | apply it, say so |
| `current-behaviour-authority` | `## Current-behaviour authority` | documented default | apply it silently |
| `discovery-capture` | `## Discovery capture` | documented defaults | apply them silently |

## Per-concept blocks

Each block is self-contained: run one, or run them in order for a full guided setup.

### Anchor (once per project, after the first `set`)

`ws-binding anchor` adds a *pointer* to `WHITTLESPEC.md` from `CLAUDE.md` and `AGENTS.md` -- never
the value. This is the only outbound write WhittleSpec makes into files the adopter owns.

### verification

Ask: "What is the full, repeatable check that proves this project's work is done?" (e.g. `pytest
-q`, a `make` target, a shell script). If the project has no automatable check, record `none` --
completion evidence then comes from a demonstration, not a test pass.

Record: `ws-binding set verification "<their command>"` (creates or updates `WHITTLESPEC.md`).
Confirm: `ws-binding validate verification`. If it reports the command missing, fix the tool or
re-run this block; do not proceed with an unresolvable binding.

Projects commonly have more than one runner -- unit and BDD, frontend and backend, a linter. Put the
command that answers "is this project's work done" on the `Binding:` line, an aggregate target if one
exists, and describe the rest in prose beneath: which runner covers what, which are slow enough to
skip mid-task, what the completion gate must include. Do not force an aggregate that does not make
sense. A `Binding:` line naming the main check plus prose naming the others is a truthful record; an
invented `cd a && x && cd b && y` is not.

### evidence-profile (a floor, not an instruction)

What a finished task must show varies per task and often per acceptance criterion -- the task
template already carries a `**Demo**:` on each AC, and that is where the instance lives. This binding
does not repeat it. It records only the project-level floor: what can *never* count as evidence here.

The one durable fact is whether a test pass can ever suffice. For an executable project it can, in
combination with a demo. For prose, config or a document project it cannot, ever: a green suite says
nothing about whether the artefact is right, so evidence is the artefact exercised through its real
surface.

Record a short expectation rather than a value -- `ws-binding set evidence-profile "automated check
plus a demo; a check alone is never sufficient"`, or `"no automated check exists; evidence is the
artefact exercised through its real surface"`. Unbound is fine and common: `ws.4-run` §1b then
derives the floor from `verification`.

### work-ledger

The durable home for this project's committed work. Ask: "Where does committed work live -- an
external tracker (name it), `local` (the SDD task files themselves), or a **split** (e.g.
official/outcome-bearing work -> the tracker, while small/technical/personal items that would be out
of place there stay `local`)?"

Record the default/floor: `ws-binding set work-ledger "<tracker-or-local>"`. If they chose a split,
note the routing rule in the `WHITTLESPEC.md` work-ledger section as a short prose rule. There is no
"none": `local` is always the floor (stable numbers = identity, `[x]`/`[~]` = state; see
`ws._meta` § Operating Level and Scope).

If the ledger is external, the `Binding:` line names it and the prose beneath says **how it is
reached** -- which MCP server, CLI or credential, and what to do when it is absent. A consumer that
cannot reach a bound tracker must say so and fall back to `local` visibly, never skip silently. If
the tracker is not configured yet, record that in the prose and nudge the operator to set it up: a
bound name with no way to reach it is worse than `local`, because it reads as covered.

### durability

How completed work is persisted, so `[x]` means saved, not just checked. Check whether the project
uses git:

<!-- WS:IF-CONFIGURED durability -->
Detect with `git rev-parse --is-inside-work-tree`. Git is the default this framework recommends, not
the only mechanism it supports — the branches below cover both cases.
<!-- /WS -->

- **git repo** -> default to git-per-task; ask only the timing. Record `ws-binding set durability
  "git commit; timing: <per-task|per-slice|boundary>"` (per-task is the default).
- **no git, or the operator names a non-git mechanism** -> ask what persists the change and keeps it
  reviewable, then **generate its concrete how-to** -- the persistence-state check (how to see
  un-persisted work), the persist action, and the revert step -- and record them with the binding in
  the `## Durability` section (`ws-binding set durability` writes the `Binding:` line; write the
  how-to prose beneath it). Do not leave a bare mechanism name: `ws.4-run` / `ws.9-retro` / `ws.fix`
  drive it from this recorded how-to, so it must be concrete here, not inferred later.

There is no "none": durable completion is the floor; git-per-task is the recommended default (see
`ws._meta` § Durability).

### current-behaviour-authority

Where this project's *current* behaviour is authoritative, so audits check the live surface, not a
closed spec. The default is assumed and needs no input: operator guide, README/API docs, tests,
code, in precedence by surface. Only if the project's authority differs, record it: `ws-binding set
current-behaviour-authority "<hierarchy>"` (e.g. `OpenAPI spec for the API surface; tests for
behaviour`). Unbound = the default (see `ws._meta` § Spec Lifecycle -> current-behaviour authority).

### discovery-capture

Where retained discoveries land. The default is assumed and needs no input: `specs/_ideas.md` for
parking, `specs/<feature>/seed.md` for pondering, the work ledger for committed work. Ask only
whether the project keeps discoveries anywhere else -- a process/workflow observation surface, a
team knowledge base, a domain-specific capture file. If so, record the destinations and their
routing rule: `ws-binding set discovery-capture "<destinations>"` (e.g. `process observations ->
docs/process-backlog.md; research notes -> team wiki`). Unbound = the defaults (see
`ws._meta` § Capture Surfaces -> Discovery-capture binding). `none` means no destination beyond
the local surfaces -- never "nowhere".
