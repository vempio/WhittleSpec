# [Workflow Name]: Operator Guide

[One-line description of what this workflow does.]

## Overview

[Numbered list of what the workflow does, step by step. Keep it high-level --
the reader should understand the full pipeline in 30 seconds.]

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Typical Operator Workflow

[The sequenced "how to use this" narrative. This is the most important
section -- it answers "what do I do and in what order?" Put it before
subcommand details so the operator sees the forest before the trees.]

1. **[Phase]**: [What the operator does and why]
2. **[Phase]**: [Next step, including verification]
3. **[Phase]**: [Continue until the workflow is complete]

## Quick Reference

```bash
# [Brief description of command 1]
make [target] COURSE=[slug] DATE=[YYYY-MM-DD]

# [Brief description of command 2 -- preview/dry-run]
make [target] COURSE=[slug] DATE=[YYYY-MM-DD] DRY_RUN=1
```

## Subcommands

### `[subcommand]` -- [Brief description]

[What it does, what it expects, what it produces.]

- [Key behavior 1]
- [Key behavior 2]

**Output**: JSON to stdout (machine-readable), summary to stderr (human-readable).

### `[subcommand] --dry-run` -- Preview

[What dry-run shows and what it does NOT do.]

## Error Catalog

### [Error name]

```
[Exact error message the operator will see]
```

**Fix**: [What to do, step by step.]

### [Error name]

```
[Exact error message]
```

**Fix**: [What to do.]

## Configuration

### Secrets (environment variables)

| Variable | Description |
|----------|-------------|
| `[VAR]` | [What it's for] (required) |

### Settings (config file)

All non-secret settings live in `config/[config-file].yaml`:

| Key | Default | Description |
|-----|---------|-------------|
| `[key]` | [value] | [What it controls] |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | [Success condition] |
| 1 | [Error condition] |

---

<!-- Template checklist (remove this section when filling in):
- [ ] Overview: describes the full pipeline, not just one step
- [ ] Typical Operator Workflow: covers the end-to-end sequence
- [ ] Quick Reference: all make targets with realistic example values
- [ ] Subcommands: every CLI subcommand documented
- [ ] Error Catalog: every error the operator might see, with fix
- [ ] Configuration: all env vars and config keys
- [ ] Exit Codes: all possible exit codes
- [ ] BDD cross-reference: every workflow step has a BDD scenario
-->
