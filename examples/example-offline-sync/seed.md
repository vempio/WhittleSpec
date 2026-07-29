# Seed: Offline-first sync for the mobile note client

**Status**: seed (not yet activated for SDD)
**Created**: 2026-07-28
**Source**: support inbox pattern — three tickets in two weeks reporting "my note
            vanished" after editing the same note on phone and laptop while one
            of them was offline

**Related** (optional): none yet; first time this surface has been touched
            since the client shipped

## Discovery

The mobile client currently requires a live connection for every write: an
edit made offline sits in memory until the app is foregrounded again, and if
the app is killed in the meantime the edit is gone with no warning. The
desktop client has no such gap, which is why the loss is asymmetric — users
only report it after a mobile edit. The three tickets all share the same
shape: edited on phone (offline, e.g. on a train), closed the app before
reopening it with connectivity, edit gone. Two of the three also had a
conflicting edit made on desktop in the same window, which is a second,
harder problem sitting behind the first one.

## Present Understanding

Two problems, not one, and they don't have to ship together. The narrower
problem — don't lose an offline edit — is a local durability fix: persist
every edit to on-device storage immediately, sync when connectivity returns,
and only clear the local copy once the server has acknowledged it. That's
buildable without touching conflict resolution at all, and it's the fix that
would have prevented ticket #1 outright.

The wider problem — two conflicting edits to the same note — needs an actual
merge or conflict-surfacing strategy. Rough options on the table: last-write-
wins by server timestamp (simple, silently loses data — the thing we're
trying to stop), field-level merge for structured notes vs. a diff-based merge
for free text (more correct, more work, and free-text notes are the majority
of content), or surfacing both versions to the user and letting them pick
(punts the hard problem to the user, which is honest but adds a decision they
didn't ask for).

## Open Questions

**For spike / investigation:**

- How does the existing sync protocol represent a write — full-note replace,
  or is there already a per-field diff we could build a merge on top of?
- What's the actual local storage budget on the oldest supported device? A
  local outbox that never got cleared (e.g. sync silently broken for a
  reinstalled account) needs a cap and a user-visible signal, not unbounded
  growth.
- Does the desktop client's local durability work the same way, or would this
  make mobile *more* durable than desktop and create a new asymmetry?

**For requirements / decision:**

- Ship the narrower "don't lose an offline edit" fix alone first, or hold for
  both? (Present Understanding above argues they're separable — this needs the
  product owner's call, not an engineering one.)
- Which conflict strategy for the wider problem, if we do it: silent merge,
  surfaced choice, or last-write-wins with an explicit "you're about to
  overwrite a newer edit" warning as a middle ground?
- Does a conflict ever need to be *impossible to lose silently* — i.e. even a
  bad merge decision should leave the losing version recoverable somewhere
  (undo history, a conflict log) rather than gone?

## Impact If Ignored

Silent data loss on a note-taking product is close to the worst class of bug
it can have — the user's trust in "the app remembers what I typed" is the
entire value proposition. Three tickets in two weeks with no marketing push
suggests this is not rare, just rarely reported (most people don't file a
ticket for a lost note, they just stop trusting the app). Blocks any future
"edit anywhere" messaging.

## Related Artifacts

- Support tickets referenced in Source (ticket numbers omitted from this
  public seed; see the internal tracker for the originals)
- Existing sync protocol implementation — not yet linked here; the spike
  above should produce this pointer

## Recommended Next Step

Run `/ws.spike` on the sync-protocol question first (representation + local
storage budget) — both later decisions depend on knowing what the wire format
already supports before picking a conflict strategy. Once that lands, `/ws.0-start`
the narrower "don't lose an offline edit" fix as its own feature; the wider
conflict-resolution problem stays a seed until the product owner has ruled
on scope.

---

## Out of Scope (here)

Real-time collaborative editing (two people editing the same note
simultaneously while both online) is a related but distinct problem with its
own literature (OT/CRDT) — this seed is about surviving *disconnection*, not
concurrent live editing. Don't let scope creep from "sync" pull that in.
