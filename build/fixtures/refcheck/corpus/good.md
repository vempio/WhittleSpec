# Good references

All of these resolve and must NOT be flagged.

- Command `/sdd.real` resolves to a skill dir.
- Command `/tdd.real` resolves too.
- A relative link to [a sibling](sibling.md) resolves.

## Local Anchor

- A same-file reference to §Local Anchor resolves against this file's own headings.
- A cross-file reference `sdd.real` § Verification Binding resolves exactly.
- An abbreviated reference `sdd.real` § Capture Surfaces, naming a prefix of the
  heading, resolves.
- A direct pointer to a subsection, `sdd.real` § Discovery-capture binding, resolves --
  and is what makes that subsection's removal detectable.
- A numbered reference `sdd.real` §1a resolves by prefix.
- A reference running on into prose, `sdd.real` § Verification Binding, which the skill
  resolves at setup, is matched by its heading prefix.

## 7. Numbered Section

- An ordinal heading is referenced without its number: §Numbered Section resolves.
- A document named earlier, `WHITTLESPEC.md`, is not the target of §Local Anchor.
- **A bold-delimited reference `sdd.real` § Verification Binding** stops at the closing marks.
- Two references on one line, `sdd.real` § Verification Binding and § Capture Surfaces, share the target named once.
