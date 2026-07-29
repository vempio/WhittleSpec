# Why WhittleSpec exists

## The gap an agent fills

When a person writes code, the writing drags decisions into the open. Suppose
the task is "validate the uploaded file". You cannot write that function without
choosing a maximum size, and choosing one means working out what the largest
legitimate upload actually is. You have to settle what happens to a file that
exceeds it: rejected at the boundary with a message, truncated, or accepted and
flagged for review. You have to decide whether validation covers the file type,
and what counts as a type — the extension, the declared MIME type, or the bytes
themselves.

None of those three questions appeared in the task. The work surfaced them, and
whoever answers them either knows the domain or goes and asks someone who does.

When an agent writes the same code, none of that happens. It picks a plausible
answer and continues. "Validate the input" becomes a maximum length of 255 that
nobody chose. "Retry on failure" becomes three attempts a second apart that
nobody discussed. The code compiles, the tests pass, and the decision surfaces
months later as a defect whose origin nobody can reconstruct (true story).

WhittleSpec exists to make those decisions visible while they are still cheap to
change. The rest of the framework follows from that.

## Specifications are thinking tools

A specification here clarifies intent, and its scope ends when the work does. It
is not a blueprint that code gets regenerated from, and it does not track
behaviour forward. Once a change ships, current behaviour lives in the docs,
tests and code; the spec becomes a point-in-time record of how that change was reasoned
through, and moves to `_completed/`.

That distinction matters for work on existing systems, where most software
lives. A framework treating the spec as its source of truth has to describe
enough of the existing system for the derivation to hold, before it can help
with a change to one corner. WhittleSpec asks for no such description.

The framework offers little positive help beyond that relief. `/ws.2-plan` asks
where the change integrates, what the codebase patterns are, and whether earlier
analysis still matches the code — five questions on one line, and that is the
extent of it. Anyone working in a large existing system is further on their own
than the rest of this page implies.

## The loop is not a line

The stack is written in one order and does not run in it. Tasks expose gaps in
the plan, implementation exposes requirements nobody thought of, and a discovery
at any level sends work backwards. Two or three passes per level is the ordinary
case rather than a sign that something went wrong.

Frameworks in this space tend to describe a line — specify, then plan, then
build — which matches nobody's experience of building software. WhittleSpec
expects the backward flow and gives it routes: `/ws.refine` for a mid-flight
change, `/ws.9-retro` for what the finished work taught, and a standing
instruction to reconcile specs against reality instead of letting the two drift
apart quietly.

## Control before the fact

The common way to work with an agent is to give a loose prompt, let it run, and
read what comes back. That leaves you racing after it: reconstructing decisions
from the output, at whatever size the agent chose to produce, and reading less of
it the larger it gets.

WhittleSpec moves the control earlier. Before an increment starts, its guardrails
and its width are set — what this task covers, what it must not touch, what counts
as done, how it will be demonstrated. You know what is about to be built on your
behalf, which matters because it is also built on your responsibility. Review
then means checking the work against constraints you already set, instead of
reconstructing what an agent decided and working out after the fact whether you
agree with it.

## You stay in the loop

This is pair programming, and the pairing is unequal in useful ways. An agent has
read all of the literature and produces text far faster
than a person can; what it lacks is your depth of foresight, domain knowledge, and taste. You hold context it cannot — larger, more persistent, more vaguely defined,
accumulated across a project rather than a session, and you can steer over a
distance it has no way to see the end of.

The gates exist to make that steering possible at the points where it matters.
Every level ends where a person approves the artefact, redirects it, or stops the
work, and each task carries an involvement setting: pair for full interaction at
every step, checkpoint for autonomy except on the parts you flagged, autonomous
for plumbing. An agent that hits a decision outside its brief escalates rather
than injecting hidden choices with surprising outcomes.

Delegation then runs as far as the asymmetry allows, which is further than most
people expect. Holding a whole corpus in view, generating the eleventh edge case,
sweeping a repository for stale references — all of that goes to the agent. What
stays with you is which trade-off actually matters and whether the requirement
was right in the first place. A wrong requirement still produces working code and
passing tests, so nothing further down the line will flag it.

## Ceremony proportional to the work

Not every task needs a specification, and `/ws.0-start` can legitimately answer
"just do it". In practice most work earns something — a few acceptance criteria
written down before starting is often the whole of it, and the point of the
assessment is that the amount gets chosen rather than assumed. A thirty-minute
fix does not earn a requirements document, and forcing one through the full
stack teaches people to route around the process.

The levels run from nothing through acceptance criteria, requirements, a plan
and sequenced tasks. The assessment moves in both directions: work that turns
out larger than it looked escalates, and work that shrinks stops paying for
structure it no longer needs.

Also, and this is really important to me: ceremony and process should facilitate
iteration, learning and changes of direction. I've tried hard to make WhittleSpec
diligent but not rigid, expecting you to change things as you work through a
problem and learn. Short iterations, a focus on observable behaviours and many
other such details try to get you to not be shackled to a specification you wrote
with (necessarily) incomplete understanding, but help you increase your
understanding and build the system the best way you know how.

## Don't Just Do Something! Stand There!

This is the title of my favourite chapter from *The Art of Unix Programming*.

Honestly: working with WhittleSpec feels slow sometimes. Front-loading the
thinking means the first visible output arrives later than it would from a loose
prompt, but taking the time to think in advance saves the time of having to redo
it later.

What the framework resists is skipping the parts that are expensive to recover
from: deciding what "done" _actually_ means, noticing that a requirement is wrong, choosing
which increment comes next.

Meanwhile it takes the other decisions off you entirely. Variable names, import
order, the shape of a helper: an agent picks those, and it's safe to let it make those inconsequential choices because you've nailed down the consequential ones.

## Slices somebody can look at

Every task delivers something demonstrable through a real entry point. A task
that adds a component without wiring it in, or wires something in without making
it reachable, has moved work without producing progress.

The tell is the demo. If the only demonstration is "the tests pass", the slice
was horizontal and the value is still somewhere in the future.

## Evidence rather than assertion

Completion requires the capability exercised through the surface a user actually
touches. A unit test whose fake you wrote can only confirm what you already
believed; it cannot catch a wrong belief about a CLI's arguments, a device's
limits or an API's shape, and those are the failures that matter.

So a green suite is necessary and rarely sufficient. Each acceptance criterion
carries its own demonstration, and the project records a floor — what can never
count as evidence here.

Tests carry much of the specification's weight, which is why the TDD and BDD
skills are the most detailed in the suite. A test states what the code must do in
a form that gets checked on every run, and unlike prose it cannot quietly fall
out of date. That is worth a large investment — in practice a larger one than
most people expect going in, and it is also where delegation pays best, since
generating the eleventh case is what an agent is good at.

None of this bends when the work is late. Ceremony scales down to nothing when
the task is small; the standard for what counts as done does not move with it.

## Attention is the scarce resource

Detail past the point of attentive reading has negative value: a skimmed
specification gives the impression of oversight while removing it. Every level
carries a size ceiling, and the last pass before any approval gate is a
compaction pass.

## The framework does not assume your environment

WhittleSpec runs wherever a POSIX shell and an agent that reads instruction
files exist. It has no opinion about your test runner, your issue tracker or
where completed work is persisted; a project records those once in
`WHITTLESPEC.md` and the skills read them.

Three invariants enforce that, and `context/constraints.md` states each with a
test for violating it: nothing depends on one agent harness, the framework
claims no files or names the adopter owns, and concrete languages and frameworks
appear only as marked examples.
