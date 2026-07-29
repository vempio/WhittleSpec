# The workflow

One cycle: work out how much process the work earns, write down what and why,
decide how, cut it into tasks, run them one at a time, then close the loop. Every
level ends where you approve the artefact, redirect it, or stop the work.

Most of that can be skipped. Which parts, and when, is what the first step decides.

## Setup, once per project

The first skill that needs to know something about your environment will ask, and
write the answer into `WHITTLESPEC.md` at your project root. Three questions carry
weight.

**What proves this project's work is done?** A test command, a make target, a
script. Projects usually have several runners, so the one that answers "is this
finished" goes on the binding line and the others get described underneath. A
project with nothing automatable records `none`, and completion evidence comes
from a demonstration instead.

**Where does committed work live?** An external tracker, the task files themselves,
or a split — official, outcome-bearing work to the tracker while small technical or
personal items stay local, with the routing rule recorded alongside the binding.
What there is no answer for is nowhere: work without a durable identity is work that
gets lost.

**How does finished work get persisted?** A commit per task is the default.
Anything that saves the change and keeps it reviewable qualifies — name something
other than git and you will be asked how to check, persist and undo it, because
the execution skills drive that mechanism directly rather than guessing at it.

Two further questions — where current behaviour is authoritative, and where stray
discoveries land — have defaults that need nothing from you.

Setup runs lazily. Work that never reaches execution never gets asked, and a skill
that needs one answer asks for that one answer instead of routing you through the
whole of it.

## Assess before specifying

`/ws.0-start` asks what you are about to do and answers how much ceremony it earns.
Under half an hour is a legitimate "just do it". A couple of hours usually earns
acceptance criteria written down before you start. Half a day upwards earns
requirements and a plan; a couple of days earns sequenced tasks as well.

The assessment moves in both directions later. Work that turns out larger than it
looked escalates; work that shrinks stops paying for structure it no longer needs.

If the answer is that you cannot specify yet — you do not understand how it should
behave, or several approaches look equally plausible — `/ws.spike` runs a timeboxed
experiment first and feeds what it learned into the requirements.

## What and why

`/ws.1-requirements` separates two things that get fused and shouldn't be. The
**Decisions** block holds what you need to react to, capped at five items, each
answerable in about a minute and each carrying a default plus at least one
alternative you might really choose. If an item has no credible alternative it is
not a decision, and it moves out. The **Context** block holds the record —
acceptance criteria, what is out of scope, assumptions — and is written on the
understanding that you will skim it.

Anything genuinely unknown gets marked `[NEEDS CLARIFICATION]` rather than filled
in with something plausible. More than about three of those at one level is a sign
the scope is too big.

## How

`/ws.2-plan` decides the technical approach and, more importantly, cuts the work
into slices that each go all the way through. A slice has to be defensible in terms
of what a user or an operator can now do; if the only justification available is a
layer or a component or a phase, it is not a slice. The first one is a walking
skeleton — the thinnest path through everything — and it carries explicit markers
for what it is meant to prove.

## Steps

`/ws.3-tasks` turns the plan into a sequence. Each task states what it touches,
what it depends on, how involved you want to be, and what would demonstrate it —
not "the tests pass", but something a person who is not reading test output could
look at. Tasks that produce anything user-facing also get three concrete scenarios
of what shipping only that task might make you regret.

Before any of it reaches you, the cut is reviewed by a context that did not author
it, given only the task titles and surfaces — because the reasoning that sliced the
work badly will also write a convincing defence of it. Then one gate: the slice
ledger first, so a bad cut is visible in one line, then the detail.

## Execution

`/ws.4-run N` executes one task. How much you see depends on the task's involvement
setting: **pair** for full interaction at every step, **checkpoint** for autonomy
except where you flagged, **autonomous** for plumbing. Anything that hits a decision
outside its brief comes back to you rather than picking an answer quietly.

A task is not finished when the code works. It is finished when the bound
verification command has run, when each acceptance criterion has its demonstration,
and when the change is durably persisted. A tick in a task file against an
uncommitted tree is a claim that isn't true yet.

Inside a task that writes code, an inner loop runs: `/ws.tdd.idea` maps the case
space, `/ws.tdd.outline` designs each case, `/ws.tdd.red` implements them failing,
and `/ws.tdd.green` writes the least code that passes. Where a task has a
user-facing boundary worth stating in domain language, `/ws.bdd.outline` and
`/ws.bdd.red` wrap that loop from the outside. Every task records which it chose,
in one line, with a reason.

## Closing

`/ws.9-retro` reconciles what the spec said against what actually shipped, and
sorts the difference into intentional change, discovery, creep, cut scope, and
drift nobody noticed. Every leftover gets a destination — a tracked item, an idea,
a seed, or an explicit decision to drop it. Nothing survives as a sentence in a
conversation.

Then the spec closes: it moves to `specs/_completed/`, gets an index entry, and
stops describing current behaviour. From that point the docs, tests and code are
what is true, and the spec is a record of how one change was reasoned through.

## When things move

`/ws.status` answers where you are and what is next. `/ws.review` asks whether one
artefact is sound. `/ws.sweep` asks what else a change touched or left inconsistent,
and repairs the trivial residue as it goes. `/ws.fix` is the autonomous pass:
it finds problems, fixes what is unambiguous, and surfaces the judgement calls.
`/ws.refine` handles a mid-flight discovery — incorporate it now, or defer it
deliberately and get back to what you were doing.

## What ends up on disk

```
specs/
├── <feature>/
│   ├── requirements.md    what and why
│   ├── plan.md            how, and how it is sliced
│   ├── tasks.md           the sequence, and the ledger of what is done
│   ├── retro.md           what the work taught
│   └── context/           research and decisions worth keeping
├── _ideas.md              parked, not yet worth thinking about
└── _completed/
    ├── INDEX.md           what closed, and when
    └── <feature>/         closed specs, kept for archaeology
```

Below Level 3 most of that never appears. Level 2 stops after the plan; Level 1
writes acceptance criteria and nothing else, holding the rest in the session; Level
0 writes nothing at all. Execution at those levels runs directly with the agent
rather than through `/ws.4-run`, which works from a task file — what does not change
is the standard for done: the verification still runs, each criterion still gets its
demonstration, and the change is still persisted before it counts. Carrying that
contract without a task file to hold it is the thinnest part of the framework today.
