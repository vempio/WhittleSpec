# WhittleSpec

WhittleSpec is a Specification-Driven Development framework: a suite of agent skills
for incrementally turning vague intentions into precise, reviewable specifications before code gets
written, and for keeping a person in control of what gets built.

And it tries to work with complexity and uncertainty rather than hide them — making them visible and tractable instead.

## Why it exists

I created it partly because what I was looking for didn't exist, and partly out of frustration with what existed. All spec-driven frameworks I was aware of accidentally railroad you into waterfall development, fast-talk over complexity, and don't really have any provisions for reacting to what you learn as you go.

WhittleSpec tries to support you in doing serious engineering, where you remain in control of what gets built, and why and how. Since even for AI-generated products the responsibility for these products is never transferred away from you, I consider this not only fitting, but essential.

When a person writes code, the writing drags decisions into the open. Writing "validate
the upload" implies settling what the size limit is, what happens to a file that
exceeds it, what counts as a type — and a dozen things besides.

Now, if a person only specifies, but the AI writes the code, insight into these decisions gets lost. Not just what decision was taken, but even (more insidiously) that a decision had to be taken in the first place!

So now that coding speed is even less of a factor, human attention (and decisions) become an even stronger bottleneck in development.

WhittleSpec tries to help make those decisions visible, distinguish between consequential and inconsequential ones, and fix them while they are still cheap to change. By uncovering and fixing the decisions that matter, it
gives the agent licence to make all the others without having to stop and ask, or the human having to worry about what they might have missed.

[The longer argument](docs/philosophy.md)

## Quickstart

    git clone https://github.com/vempio/WhittleSpec
    cd WhittleSpec
    make ws-install-global

Or, where that will not run, tell your agent:

> Install WhittleSpec from https://github.com/vempio/WhittleSpec, following its INSTALL.md.

Either way, every `ws.*` skill lands in your agent's skills directory. Then start with
`/ws.0-start`, which asks what you are doing and tells you how much process it
deserves — including none at all.

<!-- WS:DEFAULT claude-code-skills-dir -->

That directory is `~/.claude/skills` by default, which is where Claude Code looks. On
another harness, set `WS_SKILLS_DIR` to wherever yours looks — nothing in WhittleSpec
needs to know which one you run.

<!-- /WS -->

To add your own skills without forking, drop them in a gitignored `personal/` slot
beside the repo skills; the same target links those too.

[Every install route, including without a shell](INSTALL.md) ·
[What a full cycle looks like](docs/workflow.md)

## Requirements and platforms

<!-- WS:DEFAULT install-prerequisites -->

I tried hard to make it portable in every sense.

Installing needs nothing but an agent that reads skill files from a directory — the
skills are plain files, and [INSTALL.md](INSTALL.md) has a route that copies them with
no shell and no build tool at all. The clone-and-build route additionally wants a POSIX
shell, `make`, and working symlinks. Git is a convenience, not a requirement.

Linux, macOS and WSL are supported and tested.

Windows-native now has an install route that needs no shell, and the runtime degrades
rather than stops: `ws-binding.sh`, the accessor that reads a project's
`WHITTLESPEC.md`, still wants a POSIX shell, and without one the skills read that file
directly and tell you they did. But nothing here has been exercised on a Windows box,
so treat it as unverified rather than supported.

<!-- /WS -->

## How it differs

Most frameworks here treat the specification as the thing code is derived from, and
gather the detail up front. WhittleSpec treats it as a thinking tool.

Firstly, WhittleSpec contends that you will inevitably learn as you implement, and makes quick iterations and revise-as-you-learn a central part of its approach.

Secondly, it's very specifically about retaining control, staying ahead of your AI collaborator, setting clear conditions — because if you want to go fast, you better have trusty guardrails.

And thirdly, it tries to not take itself too seriously, and give you exactly as much ceremony as is helpful, but not more.

[Against spec-kit, BMAD, and the smaller skill collections](docs/comparison.md)

## What it builds on

Luckily, none of it is new (in fact, it is all delightfully boring :-) ). Test-driven development, behaviour-driven development and agile
working are decades old, and this framework mostly arranges them for a different kind
of collaborator. They answer problems an agent makes more acute — problems that were
the bane of engineers long before computers existed.

The inner loop is
[test-driven development](https://martinfowler.com/bliki/TestDrivenDevelopment.html),
the outer one is
[behaviour-driven development](https://dannorth.net/blog/introducing-bdd/), and the
surrounding stance is [agile](https://agilemanifesto.org/) in the original sense rather
than the ceremonial one. Those three links are the short versions if any of it is
unfamiliar: WhittleSpec assumes the ideas, but not that you have practised them.

## Who am I

I've been working in the embedded systems field for about two decades now: as a developer, requirements engineer, test engineer, team lead and team coach. So all of the things I included in WhittleSpec are techniques that I have tried out before, and found useful — and found missing from AI-supported workflows.

If you want to learn more, or get in contact, head over to https://luca.engineer/

## Documentation

- [The workflow](docs/workflow.md) — a cycle from assessment to closure
- [Why WhittleSpec exists](docs/philosophy.md) — the reasoning behind the design
- [How WhittleSpec differs](docs/comparison.md) — where it sits among the alternatives
- [Skill catalogue](skills/README.md) — every skill, one line each

Contributions: see [CONTRIBUTING.md](CONTRIBUTING.md). MIT licensed.
