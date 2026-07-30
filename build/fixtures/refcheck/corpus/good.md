# Good references

All of these resolve and must NOT be flagged.

- Command `/sdd.real` resolves to a skill dir.
- Command `/tdd.real` resolves too.
- A relative link to [a sibling](sibling.md) resolves.

## Local Anchor

- A same-file reference to §Local Anchor resolves against this file's own headings.
- A cross-file reference `sdd.real` § Verification Binding resolves exactly.
- An abbreviated reference `sdd.real` § Capture Surfaces → Discovery-capture binding
  resolves: it names a prefix of the heading, and the sub-navigation after the arrow
  is not itself a heading.
- A numbered reference `sdd.real` §1a resolves by prefix.
- A reference running on into prose, `sdd.real` § Verification Binding, which the skill
  resolves at setup, is matched by its heading prefix.

## 7. Numbered Section

- An ordinal heading is referenced without its number: §Numbered Section resolves.
- A document named earlier, `WHITTLESPEC.md`, is not the target of §Local Anchor.
- **A bold-delimited reference `sdd.real` § Verification Binding** stops at the closing marks.
- An ASCII-arrow reference `sdd.real` § Capture Surfaces -> Discovery-capture binding resolves.
- Two references on one line, `sdd.real` § Verification Binding and § Capture Surfaces, share the target named once.
