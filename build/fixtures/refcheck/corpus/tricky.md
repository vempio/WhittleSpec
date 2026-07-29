# False-positive traps

None of these may be flagged as a dangling command or link.

- A backticked file path with internal slashes and an extension:
  `state/content-impulses.md` is a path, not a command.
- Another backticked path: `specs/<feature>/seed.md` must not flag.
- An absolute URL: https://example.com/sdd.fake must not be read as a command.
- Prose slashes like and/or or read/write are not commands.
- An HTML closing tag such as `</summary>` is not a command.
- A markdown link to an external URL: [docs](https://example.com/page.md) is not a local file.
