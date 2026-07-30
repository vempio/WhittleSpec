# WhittleSpec Reference: Parallel Work

When multiple Claude sessions (or humans) work concurrently on the same
codebase, SDD helps identify opportunities and track what's in-flight.

## Philosophy

- **Same working directory**: Common case. Multiple sessions in one repo, each on a different task. Separate worktrees/clones rarely worth the overhead.
- **Best-effort heuristics**: Markers reflect explicit dependencies only. Implicit ones (shared files, integration order, runtime conflicts) need human judgment.
- **Identify, don't enforce**: SDD marks what *can* parallelize; humans decide whether to.
- **Track in-flight work**: Markers show what's being worked on, reducing accidental duplication.
- **Human judgment for coordination**: No locking or automation. Parallelization is a coordination tool, not a constraint system.

## Session Safety Rules

In a shared working directory:

- **Never rely on remembered file state.** Re-read before acting — a parallel session may have changed the file.
- **Never unilaterally revert changes you didn't make.** Unexpected file state → ask the user.
- **Check for interference on task start.** If other tasks are `[~]`, check whether their `Touches` overlaps with yours. Warn if so.
- **The task file is the coordination artifact.** Read fresh, don't rely on memory.

## Stable Task Numbering

When modifying a task list already underway:

- **Never renumber existing tasks.** Completed `[x]` and in-flight `[~]` keep their numbers.
- **Interleave with letter suffixes**: between task 19 and 20, insert 19a (then 19b, 19c if needed).
- **Mark obsolete tasks explicitly**: if scope movement mutates a task beyond recognition, mark `[OBSOLETE -- replaced by 19a]` and create a new one rather than silently mutating.
- **Why**: Task numbers appear in commit messages, tracker comments, parallel session context, and human memory. Renumbering silently breaks all of these.

## Task Status Markers

```
- [ ] Task N: Description          # Pending (not started)
- [~] Task N: Description          # In-flight (being worked on)
- [~:auth] Task N: Description     # In-flight with session hint
- [x] Task N: Description          # Complete
```

The `[~]` marker indicates work in progress. The optional `:hint` suffix helps identify which session owns the task (e.g., `[~:api]`, `[~:frontend]`).

## When Parallel Work Makes Sense

Good candidates for parallel execution:

- Tasks with no dependencies (`Depends on: None`)
- Independent components that don't share files
- Separate features or workstreams identified in the plan

Poor candidates:

- Tasks that modify the same files
- Tasks with sequential dependencies
- Integration-heavy work where order matters

## Parallel Field in Tasks

Tasks with no unfinished dependencies include a `**Parallel**` field:

```markdown
### Task 3: Implement validation

- **Goal**: Add input validation
- **Touches**: src/validator.py
- **Depends on**: None
- **Parallel**: yes (can start alongside Tasks 5, 7)
- **Acceptance**: Validation rejects malformed input
```

The field lists other currently-parallelizable tasks for quick reference. Omit it for tasks with dependencies.
