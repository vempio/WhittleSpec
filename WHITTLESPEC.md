## Verification
Binding: make ws-test

Runs the six suites under `build/*.test.sh` plus both validators. Both layer-validator classes —
marker and inventory integrity, and unmarked environment mechanisms — are hard gates at zero.
Individual suites can be run directly mid-task; the aggregate is what a completion gate requires.

## Work ledger
Binding: local

## Durability
Binding: git commit; timing: per-task

## Discovery capture
Binding: ratified invariants -> context/constraints.md (each with a violation test and an audit status); otherwise the defaults

## Evidence profile
Binding: automated check plus a demo; a check alone is never sufficient
