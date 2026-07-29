# Installing WhittleSpec

WhittleSpec is a set of skill directories. Installing it means putting them where your
agent reads skills from. Nothing is compiled, nothing runs in the background, and
nothing outside that one directory is written.

Three routes, same result. **Clone and build** is the one to take if possible.
It does updates most smoothly and integrates the best with your other skills.
The other two are for machines where git clone && make is not an option.

## Clone and build

<!-- WS:DEFAULT install-routes -->

    git clone https://github.com/vempio/WhittleSpec
    cd WhittleSpec
    make ws-install-global

Each skill is symlinked rather than copied, so a later `git pull` updates all of them
at once. `make ws-install-skills` installs into a single project's skills directory
instead of the global one, and both take the override named below.

Needs a POSIX shell, `make`, and a filesystem with working symlinks.

<!-- /WS -->

## Have your agent do it

Paste this to an agent that can fetch a URL and write files:

> Install WhittleSpec from https://github.com/vempio/WhittleSpec, following its INSTALL.md.

It works out where your harness keeps skills and follows the procedure at the bottom of
this file. Ask it to show you the plan before it writes, if you would rather check
first. To update later, ask again: the install leaves a record of what it put where, and
an update reads that to retire whatever this release no longer ships.

This is the route that needs no shell, no build tool and no symlinks.

## Copy the directories

1. Download the repository -- the latest release if there is one, otherwise the
   default branch -- and unpack it anywhere.
2. Copy every subdirectory of `skills/` whose name begins with `ws.` and holds a
   `SKILL.md` into your skills directory.
3. Write `ws._meta/INSTALLED.md` there: the release, the date, and the names you just
   copied. It is what the next update and the removal step read to tell these skills
   from your own.
4. Start with `/ws.0-start`.

Nothing else is needed: each skill directory carries what it depends on.

To update, delete the skills the last install placed -- `ws._meta/INSTALLED.md` names
them -- before copying the new ones in, never `ws.*` as a wildcard: a `ws.` name you put
there yourself is yours. Copying over the top leaves behind skills this release dropped,
and files dropped from inside a skill that still ships. An update replaces a skill wholesale, so any edit you
made inside one goes with it -- keep your own work in your own skill instead.

## Where the skills go

<!-- WS:DEFAULT claude-code-skills-dir -->

`make ws-install-global` installs into `~/.claude/skills`, where Claude Code looks for
them, or into `$CLAUDE_CONFIG_DIR/skills` if you have moved its config.
`make ws-install-skills` installs into `.claude/skills` in the current project instead.

On another harness, or to keep them elsewhere, name the directory:

    make ws-install-global  WS_SKILLS_DIR=~/.config/some-agent/skills
    make ws-install-skills  WS_PROJECT_SKILLS_DIR=.some-agent/skills

<!-- /WS -->

The other two routes have you name the directory as you install -- or your agent name
it, since it knows which harness it is running inside.

## What needs a shell

Installing does not. The skills are plain files and every route above places them
without running anything.

One script does, at runtime: `ws._meta/ws-binding.sh` reads a project's
`WHITTLESPEC.md` and answers questions about it. It is an accelerator, not a
prerequisite. Where it cannot run -- no POSIX shell, or a copy that arrived without its
executable bit -- the skills read that record directly instead and say that they did.
The answers are the same; what is lost is the script's guarantee against misreading it.
Which platforms this has actually been exercised on is in the [README](README.md).

## Your own skills alongside

The clone-and-build route picks up a gitignored `personal/` directory beside the repo's
`skills/` and installs what it finds there with the rest. The copy routes have no repo
to hang that off and need no indirection: put your own skills straight into the skills
directory. Give them names WhittleSpec does not ship and no update will touch them.

## The procedure

What the agent route automates and the copy route does by hand. Clone-and-build does
the equivalent its own way, and the clone it installs from is its own record of which
version is in place. An agent following this should say what it is about to do before
it writes.

1. **Get the files.** The latest release of `vempio/WhittleSpec` if one exists,
   otherwise the default branch. Unpack somewhere permanent if the adopter wants to
   keep the docs and build tooling; a temporary directory is enough otherwise.
2. **Find the skills directory.** The one this harness reads skills from -- "Where the
   skills go" above has the default and how to point it elsewhere. If it is not
   knowable, ask -- do not guess, and do not create a directory the adopter has not
   named.
3. **Establish what is ours.** The names WhittleSpec ships are exactly the `ws.`
   subdirectories of `skills/` in the download that hold a `SKILL.md`. Those you may
   place and replace. Anything else already in the skills directory is the adopter's
   -- including another `ws.` name -- so leave it and report it. There is no other
   test for ownership: a copied install carries no mark saying who put it there, and
   guessing wrong destroys work that is not yours.
4. **Retire what this release drops.** Read `ws._meta/INSTALLED.md` in the skills
   directory. If it records an earlier install, remove the skills it lists that the
   download no longer ships. With no such record, remove nothing and say so.
5. **Place each skill.** Put a copy of each directory from step 3 at that name in the
   skills directory, replacing any earlier copy whole rather than merging into it.
   `ws._meta/ws-binding.sh` must arrive executable: a harness whose file-writing tool
   drops the mode leaves the accessor unrunnable, and every skill then falls back to
   reading the record by hand on a machine that could have run it. Link instead of
   copying only if links work here and the download is being kept.
6. **Record the install.** Write `ws._meta/INSTALLED.md`: the release tag or commit,
   the date, the route, and the skill names placed. Step 4 reads it next time, and it
   is what answers "which WhittleSpec is this". Write it after step 5, which replaces
   the directory it lives in.
7. **Report.** What was installed, what was skipped and why, and where it went.
8. **Verify.** `/ws.0-start` is invocable and loads `ws._meta`. From a project holding
   a `WHITTLESPEC.md`, `sh <skills-dir>/ws._meta/ws-binding.sh get verification`
   prints that project's binding. If it does not run, say so: the install still works,
   and the skills will read the record directly instead.

Nothing outside the skills directory is written. WhittleSpec adds a single pointer
line to a project's `CLAUDE.md` / `AGENTS.md` later, during `/ws.0-start` setup, and
only then.

## Removing it

Remove exactly what the install placed, name by name -- never `ws.*` as a wildcard.
A `ws.` name in your skills directory may be your own: the install refuses to claim
one it did not place, and removal has to be as careful, because here a wrong guess
deletes a directory and everything under it.

- **Installed from a clone.** The entries are symlinks into the clone, so the link
  target says who placed them. `ls -l` your skills directory, delete the entries
  whose target resolves inside the clone, then delete the clone. Links into your
  `personal/` overlay are your own skills placed by the same install -- move them
  somewhere permanent before deleting the clone if you want to keep them.
- **Installed by an agent, or copied by hand.** `ws._meta/INSTALLED.md` lists the
  names that install placed. Delete those, `ws._meta` last, since it carries the
  record. Without such a record nothing says who placed what: take the `ws.` skills
  of the release you installed as the candidates, and leave anything you cannot
  account for.

Nothing else was installed. A project's `WHITTLESPEC.md` and `specs/` are yours to
keep or delete.
