# Contributing

WhittleSpec is a set of skills: prose instructions an AI coding agent loads and
follows. Contributions are therefore mostly edits to prose, and the bar is that
the prose survives contact with a real project.

## Before you open a pull request

Run the full check:

    make ws-test

It runs the test suites, the reference validator and the layer validator. CI runs
the same target, so a green local run should mean a green pipeline.

## What the checks enforce

**References resolve.** Every slash-command and file reference in a skill points
at something that exists. A renamed skill with a stale pointer strands whoever
follows it.

**Environment mechanisms are marked.** A skill may not name a concrete tool,
runner or path in unmarked prose. Either the surrounding text resolves the value
from the project's binding record, or the mechanism sits inside a `WS:DEFAULT` /
`WS:IF-CONFIGURED` / `WS:EXAMPLE` marker with a matching entry in
`build/mechanism-inventory.md`. The check is scoped to code-formatted spans, so
ordinary English use of the same words is fine.

<!-- WS:EXAMPLE runner-counterexample -->
The names that trip it are concrete runners and harness paths: `make test`,
`pytest`, a hard-coded config directory. This paragraph carries a marker for
exactly that reason, which is the shortest available demonstration of the rule.
<!-- /WS -->

## The three invariants

`context/constraints.md` holds them in full, each with a violation test. In short:

- **INV-1, harness-agnostic.** Nothing depends on a mechanism only one agent
  harness provides. Where a harness-specific default is convenient, it is marked
  as that harness's convention and an override exists.
- **INV-2, WhittleSpec owns only its own artefacts.** The framework does not write
  into, or claim names in, files the adopter owns. The single sanctioned outbound
  write is a pointer to `WHITTLESPEC.md`.
- **INV-3, implementation-agnostic.** Concrete languages, test frameworks and
  libraries appear as marked examples or adapter selections, never as preferences.

A change that trips one of these needs the invariant revisited first.

## Style

Skills are read by an agent under a limited attention budget, so length carries a
cost here that ordinary documentation prose does not. Prefer cutting a sentence to
adding a qualifier. If a rule needs three paragraphs of caveats, the rule is
probably wrong.

## Governance

There is no code of conduct or security policy yet. Both may be added if the
project attracts enough contributors to need them.
