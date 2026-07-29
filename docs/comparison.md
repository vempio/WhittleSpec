# How WhittleSpec differs

Four other approaches come up when people ask what this is like. The summaries
below are drawn from reading those projects rather than from running them in
anger, and all of them move; check the current versions before relying on a
distinction stated here.

## At a glance

|                  | WhittleSpec                              | GitHub spec-kit         | BMAD                      | mattpocock/skills               | obra/superpowers     |
| ---------------- | ---------------------------------------- | ----------------------- | ------------------------- | ------------------------------- | -------------------- |
| Skills           | 22, dotted namespace                     | commands + templates    | 21 agents, 50+ workflows  | ~14, three buckets              | ~14 core, flat       |
| Primary artefact | thinking tool, closed at retro           | executable blueprint    | versioned source of truth | none; atomic skills             | methodology chain    |
| Ceremony         | assessed per task, zero is valid         | full workflow always    | track-based               | pick what you want              | full chain           |
| Detail timing    | what is immediate                        | everything upfront      | plan everything upfront   | n/a                             | as the chain demands |
| Existing systems | no upfront description needed; little positive support yet | awkward | greenfield-optimised | fine, skills are local | fine |
| Stance           | scale-calibrated, failure-mode catalogue | spec as source of truth | agents as a team          | partnership, trust the engineer | rules of engagement  |

## spec-kit

Spec-kit treats the specification as the thing code is derived from, and detail
is gathered before implementation starts. The bet is that enough thinking up
front makes the derivation sound.

Surprises arrive anyway, and they arrive on new work as readily as on old: a
library behaves differently from its documentation, a user job turns out to be
two jobs, a constraint nobody stated appears in the second week. So the useful
question is what each approach does once the specification turns out to be
wrong. Spec-kit revises the source of truth and
re-derives. WhittleSpec assumes the revision is coming and keeps the
specification small enough that revising it costs little.

There is a second cost on existing systems. Treating the spec as source of truth
means describing enough of the current system for the derivation to be valid,
which is a large bill for a change to one corner. WhittleSpec's specs clarify
intent and then stop, which is cheaper there and gives up the ability to
regenerate.

Spec-kit's clarification taxonomy and its `[NEEDS CLARIFICATION]` marker are
good, and WhittleSpec uses the same marker.

## BMAD

BMAD models a team of agents with distinct roles and carries heavy planning
documents between them. Its real problem is context loss across sessions, and
its answer is to write enough down that any agent can pick up.

WhittleSpec addresses the same problem with a smaller surface: the requirements,
plan and task files are the handover, and the task file doubles as the ledger of
what is done. If you want role-played agents and a formal PRD, BMAD offers more
of that than this does.

## mattpocock/skills

Small, terse, composable skills you adopt individually — closer to a good
toolbox than a methodology. Where WhittleSpec prescribes a sequence, these
prescribe almost nothing, which is the right trade if you already have a process
and want targeted help.

WhittleSpec is heavier. The `_meta` files alone are longer than several of these
skills combined, and that weight buys the failure-mode catalogue and the scale
assessment. If neither is a problem you have, the toolbox is a better fit.

They should also compose. Each skill is self-contained, so adopting one costs
nothing structural, and a project running this cycle can still reach for one
where it is sharper. The other three approaches here all want the whole chain,
which makes them alternatives to each other in a way these are not.

## obra/superpowers

The nearest neighbour: a full methodology with a chain of skills that hand off
to each other, strong TDD discipline, and an explicit concern with agents
rationalising their way out of rules. The two projects share the evidence-over-
claims stance almost exactly.

They differ on ceremony. Superpowers runs its chain; WhittleSpec assesses first
and will tell you to skip the process entirely. They also differ on the
environment: WhittleSpec binds the test runner, tracker and persistence
mechanism per project rather than assuming them, which is machinery superpowers
does not carry and does not need for a single-developer setup.

## When WhittleSpec is the wrong choice

If you want the derivation to run unattended — change the specification, get
regenerated code, no person in the loop — spec-kit is aimed at that and this is
not. WhittleSpec's specs are very much a build input; what it declines to claim
is that an agent will get there unaided. If you want an agent team with named
roles, BMAD has it. If you already have a working
process and want a few sharp tools, the smaller skill collections cost far less
to adopt, and can sit alongside this one rather than replacing it. And if a task
takes half an hour, WhittleSpec's own answer is to skip all of this and do the
work.

Greenfield is not on that list. The walking skeleton, the escalating scale
assessment and the per-task demo are all machinery for building something new.
What WhittleSpec declines is the assumption that a specification will come out
correct and useful on the first attempt, however hard you try, and that
assumption fails on new work too.
