# Seed: CSV export on the reports page

**Status**: seed (not yet activated for SDD)
**Created**: 2026-07-28
**Source**: three separate users asked for it in the feedback widget this
            quarter, all wanting to pull numbers into their own spreadsheet

## Discovery

The reports page renders totals and a breakdown table in the browser only.
Users who want to do anything beyond what the page shows — chart it their own
way, hand it to someone else, keep a monthly snapshot — currently screenshot
it or retype the numbers by hand. Every request has been "just let me get the
table out as a file."

## Open Questions

**For requirements / decision:**

- Export exactly what's on screen (respecting the page's current filters/date
  range), or the full underlying dataset regardless of filter? The three
  requests all implied "what I'm looking at right now."
- One button on the reports page, or does this belong on every table in the
  product? Scope to reports page only unless a second page asks for it.

## Impact If Ignored

Low urgency, real friction — nobody's blocked, but three independent asks in
one quarter says this is a recurring small tax on users who trust the numbers
enough to want to do more with them.

## Recommended Next Step

Small and clear enough to skip spec rigor: file a tracked issue for "add CSV
export button to the reports page, respecting current filters" and delete
this seed once it's created — no `/ws.0-start` needed for a one-button,
one-page feature with no open design questions.
