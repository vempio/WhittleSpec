#!/usr/bin/env bash
# Self-test for the Slice-1 adapter-binding boundary.
#
# Units under test:
#   build/ws-binding.sh   -- read-only accessor over WHITTLESPEC.md (the binding record)
#   /ws.0-start setup      -- the anchor writer (creates+anchors WHITTLESPEC.md)
#   ws._meta / skeleton skills -- marker scheme + clone-agnostic meta-path
#
# Traceability: tasks-slice1.md Task 1 ACs (AC1 setup+anchor, AC2 consume bound
# command, AC3 validate-before-use 5 cases, AC4 marker scheme, AC5 clone-agnostic load).
#
# Phase: IDEA. Stubs only -- each test marks todo; no fixtures, no assertions yet.
# Runner prints TODO / PASS / FAIL per test so unimplemented intent stays visible.

set -u

# --- minimal harness (todo-visible) ---------------------------------------
_ws_pass=0 _ws_fail=0 _ws_todo=0
todo() { printf 'TODO  %-52s %s\n' "$_ws_current" "$1"; _ws_todo=$((_ws_todo + 1)); }
# pass()/fail() arrive in the red phase; declared here so the harness is whole.
pass() { printf 'PASS  %-52s\n' "$_ws_current"; _ws_pass=$((_ws_pass + 1)); }
fail() { printf 'FAIL  %-52s %s\n' "$_ws_current" "$1"; _ws_fail=$((_ws_fail + 1)); }

# --- fixtures + run helper (red phase) -------------------------------------
# Absolute path to the unit under test, resolved once. MUST be absolute: tests
# cd into throwaway project dirs before invoking it. The accessor ships inside
# ws._meta so that consumers reach it by the same sibling rule that resolves
# ws._meta/SKILL.md -- which is what makes a copied install work, not just a
# symlinked one.
_here="$(cd "$(dirname "$0")" && pwd)"
SKILLS="$_here/../skills"                         # the installed skill tree
WSB="$SKILLS/ws._meta/ws-binding.sh"
META="$SKILLS/ws._meta/SKILL.md"                 # shared-context doctrine file
SKELETON='ws.0-start ws.4-run ws._meta'          # Task-1 skeleton-path skills
_out='' _err='' _rc=0 _prepath=''

# _run <project-dir> <ws-binding args...>
# Invoke the accessor with cwd set to a project dir (that is where it looks for
# WHITTLESPEC.md). Captures stdout -> _out, stderr -> _err, exit code -> _rc.
# If _prepath is set, it is prepended to PATH for the invocation (lets a test
# make a command resolvable, or guarantee one is absent, hermetically).
_run() {
  _dir="$1"; shift
  _errf="$(mktemp)"
  _out="$(cd "$_dir" && PATH="${_prepath:+$_prepath:}$PATH" "$WSB" "$@" 2>"$_errf")"; _rc=$?
  _err="$(cat "$_errf")"; rm -f "$_errf"
}

# _proj_verif <binding-value> : make a throwaway project whose Verification
# binding is <binding-value>; echo the project dir path.
_proj_verif() {
  d="$(mktemp -d)"
  cat > "$d/WHITTLESPEC.md" <<EOF
## Verification
Invariant: one full repeatable check
Binding: $1
Fallback: none -> evidence = demo
EOF
  printf '%s' "$d"
}

# _make_exec <dir> <name> : create an executable named <name> in <dir>, so that
# prepending <dir> to PATH makes <name> resolvable.
_make_exec() {
  printf '#!/bin/sh\nexit 0\n' > "$1/$2"
  chmod +x "$1/$2"
}

# ===========================================================================
# Group A: binding resolution -- `ws-binding get verification`
# ===========================================================================

test_get_returns_declared_command() {            # AC2 (bound-run smoke)
  # Goal: `ws-binding get verification` yields the operator's declared command
  #       verbatim -- the value ws.4-run consumes instead of a hardcoded one.
  # Boundaries: only the Verification binding; does NOT check the command exists
  #       (Group B), does NOT touch other concepts' sections.
  # Arrange: a project whose WHITTLESPEC.md binds Verification to a distinctive,
  #          unmistakable command no hardcoded default could masquerade as.
  # Act: ask the accessor for the verification binding.
  # Assert: stdout is exactly that command string (byte-for-byte); exit 0.
  proj="$(mktemp -d)"
  cat > "$proj/WHITTLESPEC.md" <<'EOF'
## Verification
Invariant: one full repeatable check
Binding: quux-check --all --exit-on-first
Fallback: none -> evidence = demo
EOF
  _run "$proj" get verification
  rm -rf "$proj"
  [ "$_rc" -eq 0 ] || { fail "expected exit 0, got $_rc (stderr: $_err)"; return; }
  [ "$_out" = "quux-check --all --exit-on-first" ] \
    || { fail "expected the declared command verbatim, got '$_out'"; return; }
  pass
}
test_get_no_record_offers_setup_not_guess() {    # AC3 case 1
  # Goal: with no binding record present, get refuses to invent a value and
  #       instead routes the operator to setup -- never a guessed default.
  # Boundaries: absence of the whole file, distinct from a present-but-bad
  #       command (Group B); message wording asserted only for the setup cue.
  # Arrange: a project directory with no WHITTLESPEC.md at all.
  # Act: ask for the verification binding.
  # Assert: exit non-zero; stderr names /ws.0-start setup as the way forward;
  #         stdout carries no command (no fabricated default like `make test`).
  proj="$(mktemp -d)"   # deliberately no WHITTLESPEC.md
  _run "$proj" get verification
  rm -rf "$proj"
  [ "$_rc" -ne 0 ] || { fail "expected non-zero exit when no record exists, got 0"; return; }
  [ -z "$_out" ] || { fail "expected empty stdout (no guessed default), got '$_out'"; return; }
  case "$_err" in
    *"/ws.0-start"*) : ;;
    *) fail "stderr must route to /ws.0-start setup, got '$_err'"; return ;;
  esac
  pass
}
test_get_reflects_changed_value() {              # AC3 case 3
  # Goal: the accessor re-reads the record every call -- editing the binding
  #       after init is reflected immediately, never served from a stale cache.
  # Boundaries: same process, two sequential reads; not concurrent edits.
  # Arrange: a project bound to command A; capture get; then rewrite the binding
  #          to a clearly different command B.
  # Act: ask for the verification binding a second time.
  # Assert: the second read returns B (not A) exactly; exit 0.
  proj="$(mktemp -d)"
  cat > "$proj/WHITTLESPEC.md" <<'EOF'
## Verification
Invariant: one full repeatable check
Binding: alpha-runner --fast
Fallback: none -> evidence = demo
EOF
  _run "$proj" get verification
  first="$_out"; first_rc="$_rc"
  cat > "$proj/WHITTLESPEC.md" <<'EOF'
## Verification
Invariant: one full repeatable check
Binding: beta-runner --slow --verbose
Fallback: none -> evidence = demo
EOF
  _run "$proj" get verification
  rm -rf "$proj"
  { [ "$first_rc" -eq 0 ] && [ "$first" = "alpha-runner --fast" ]; } \
    || { fail "precondition: first read should be 'alpha-runner --fast', got '$first' (rc $first_rc)"; return; }
  [ "$_rc" -eq 0 ] || { fail "expected exit 0 on re-read, got $_rc"; return; }
  [ "$_out" = "beta-runner --slow --verbose" ] \
    || { fail "re-read must reflect the edited value, got '$_out' (stale cache?)"; return; }
  pass
}
test_get_honors_user_override() {                # AC3 case 4
  # Goal: a value the operator deliberately set away from any recommended
  #       default is returned exactly as recorded -- get has no opinion of its own.
  # Boundaries: reads whatever the record says; does not know or enforce defaults.
  # Arrange: a project whose Verification binding is an unusual non-default
  #          command the operator chose on purpose.
  # Act: ask for the verification binding.
  # Assert: stdout is that overridden command verbatim; exit 0.
  proj="$(mktemp -d)"
  cat > "$proj/WHITTLESPEC.md" <<'EOF'
## Verification
Invariant: one full repeatable check
Binding: /opt/acme/bin/weird-check --profile=ci -k
Fallback: none -> evidence = demo
EOF
  _run "$proj" get verification
  rm -rf "$proj"
  [ "$_rc" -eq 0 ] || { fail "expected exit 0, got $_rc (stderr: $_err)"; return; }
  [ "$_out" = "/opt/acme/bin/weird-check --profile=ci -k" ] \
    || { fail "override must be returned verbatim, got '$_out'"; return; }
  pass
}
test_get_unknown_concept_fails_loud() {          # beyond-AC: fail fast
  # Goal: asking for a concept outside the fixed seven-row set is an operator
  #       error and fails loudly, rather than printing nothing and exiting 0.
  # Boundaries: validates the concept key against the known set; does not test
  #       every one of the seven here (one bogus key suffices).
  # Arrange: a valid WHITTLESPEC.md; request a concept that is not one of the seven.
  # Act: ask for the bogus concept.
  # Assert: exit non-zero; stderr says the concept is unknown and (ideally) lists
  #         the recognised set; stdout empty.
  proj="$(mktemp -d)"
  cat > "$proj/WHITTLESPEC.md" <<'EOF'
## Verification
Invariant: one full repeatable check
Binding: some-check
Fallback: none -> evidence = demo
EOF
  _run "$proj" get not-a-real-concept
  rm -rf "$proj"
  [ "$_rc" -ne 0 ] || { fail "expected non-zero exit for unknown concept, got 0"; return; }
  [ -z "$_out" ] || { fail "expected empty stdout for unknown concept, got '$_out'"; return; }
  case "$_err" in
    *unknown*|*Unknown*) : ;;
    *) fail "stderr should name the concept as unknown, got '$_err'"; return ;;
  esac
  pass
}
test_get_none_returns_sentinel_not_empty() {     # D3 invariant: none drops mechanism, not invariant
  # Goal: a binding of "none" is a deliberate, readable choice (this project has
  #       no automated check; evidence = demo), surfaced as a `none` sentinel --
  #       NOT an empty string a caller might mistake for a runnable command.
  # Boundaries: only the get side of the sentinel; how ws.4-run interprets `none`
  #       (skip automated verification, require demo) is that skill's concern.
  # Arrange: a project whose Verification binding is literally `none`.
  # Act: ask for the verification binding.
  # Assert: stdout is exactly `none` (the sentinel), exit 0; not empty output,
  #         not a non-zero error.
  proj="$(mktemp -d)"
  cat > "$proj/WHITTLESPEC.md" <<'EOF'
## Verification
Invariant: one full repeatable check
Binding: none
Fallback: none -> evidence = demo
EOF
  _run "$proj" get verification
  rm -rf "$proj"
  [ "$_rc" -eq 0 ] || { fail "expected exit 0 for a 'none' binding, got $_rc (stderr: $_err)"; return; }
  [ "$_out" = "none" ] || { fail "expected the 'none' sentinel, got '$_out'"; return; }
  pass
}

# ===========================================================================
# Group B: validate-before-use -- `ws-binding validate verification`
# ===========================================================================

test_validate_ok_when_command_resolvable() {     # happy path
  # Goal: when the bound command's program actually exists on PATH, validate
  #       reports OK (exit 0) -- the binding is safe to run.
  # Boundaries: resolvability of the FIRST token only; does NOT run the command,
  #       does NOT judge its arguments, does NOT cover the `none` binding.
  # Arrange: a throwaway executable placed on a PATH the test controls, and a
  #          project whose Verification binding invokes that executable with args.
  # Act: validate the verification binding.
  # Assert: exit 0 (OK); no error on stderr.
  bindir="$(mktemp -d)"; _make_exec "$bindir" "mycheck"
  proj="$(_proj_verif "mycheck --all")"
  _prepath="$bindir"
  _run "$proj" validate verification
  _prepath=''
  rm -rf "$proj" "$bindir"
  [ "$_rc" -eq 0 ] || { fail "expected OK (exit 0) for a resolvable command, got $_rc (stderr: $_err)"; return; }
  [ -z "$_err" ] || { fail "expected no stderr on OK, got '$_err'"; return; }
  pass
}
test_validate_missing_command_fails_with_offer() {  # AC3 case 2
  # Goal: a binding whose program is not installed fails loudly and points the
  #       operator at reconfiguration -- never a silent pass.
  # Boundaries: the offer/naming behaviour; exact exit-code value is Group-B's
  #       distinguish-modes test, not asserted numerically here.
  # Arrange: a project bound to a command whose first token cannot be found.
  # Act: validate the verification binding.
  # Assert: non-zero exit; stderr names the missing command AND mentions
  #         reconfiguring (so the operator knows the way out).
  proj="$(_proj_verif "totally-absent-cmd-zzz --run")"
  _run "$proj" validate verification
  rm -rf "$proj"
  [ "$_rc" -ne 0 ] || { fail "expected non-zero for a missing command, got 0"; return; }
  case "$_err" in *totally-absent-cmd-zzz*) : ;; *) fail "stderr must name the missing command, got '$_err'"; return ;; esac
  case "$_err" in *econfig*) : ;; *) fail "stderr must offer reconfiguration, got '$_err'"; return ;; esac
  pass
}
test_validate_no_record_distinct_from_missing_cmd() { # AC3 case 1 vs 2
  # Goal: "there is no binding record at all" is a different situation from
  #       "the record binds a command that isn't installed" -- validate must not
  #       conflate them, because the operator's fix differs (set up vs reconfigure).
  # Boundaries: the semantic/message distinction (setup cue vs reconfigure cue);
  #       the numeric-code distinction is the distinguish-modes test.
  # Arrange: (a) a project with no WHITTLESPEC.md; (b) a project bound to a
  #          missing command.
  # Act: validate verification in each.
  # Assert: the no-record case routes to setup (/ws.0-start) and does NOT read
  #         as "command not found"; its exit differs from the missing-command case.
  proj_a="$(mktemp -d)"                       # (a) no record at all
  _run "$proj_a" validate verification
  rc_a="$_rc"; err_a="$_err"
  rm -rf "$proj_a"
  proj_b="$(_proj_verif "totally-absent-cmd-zzz --run")"  # (b) record binds a missing command
  _run "$proj_b" validate verification
  rc_b="$_rc"
  rm -rf "$proj_b"
  [ "$rc_a" -ne "$rc_b" ] || { fail "no-record and missing-command must differ in exit code, both $rc_a"; return; }
  case "$err_a" in *"/ws.0-start"*) : ;; *) fail "no-record must route to /ws.0-start setup, got '$err_a'"; return ;; esac
  case "$err_a" in
    *"not found"*|*"totally-absent"*) fail "no-record must not read as command-not-found, got '$err_a'"; return ;;
    *) : ;;
  esac
  pass
}
test_validate_exit_codes_distinguish_modes() {   # boundary: callers branch on these
  # Goal: a calling skill branches on validate's exit code, so the three
  #       outcomes must be machine-distinguishable, not just differently worded.
  # Boundaries: distinctness of the codes, not their specific numeric values;
  #       OK is 0 by convention, the two failures are non-zero and unequal.
  # Arrange: three projects -- one OK (resolvable command), one with no record,
  #          one bound to a missing command.
  # Act: validate verification in each; capture the three exit codes.
  # Assert: OK == 0; no-record != 0; missing-command != 0; and no-record !=
  #         missing-command (all three modes tell apart).
  bindir="$(mktemp -d)"; _make_exec "$bindir" "okcmd"
  proj_ok="$(_proj_verif "okcmd --run")"
  _prepath="$bindir"; _run "$proj_ok" validate verification; _prepath=''
  rc_ok="$_rc"; rm -rf "$proj_ok" "$bindir"
  proj_nr="$(mktemp -d)"; _run "$proj_nr" validate verification; rc_nr="$_rc"; rm -rf "$proj_nr"
  proj_mc="$(_proj_verif "totally-absent-cmd-zzz --run")"; _run "$proj_mc" validate verification; rc_mc="$_rc"; rm -rf "$proj_mc"
  [ "$rc_ok" -eq 0 ] || { fail "OK mode must be exit 0, got $rc_ok"; return; }
  [ "$rc_nr" -ne 0 ] || { fail "no-record mode must be non-zero, got 0"; return; }
  [ "$rc_mc" -ne 0 ] || { fail "missing-command mode must be non-zero, got 0"; return; }
  [ "$rc_nr" -ne "$rc_mc" ] || { fail "no-record ($rc_nr) and missing-command ($rc_mc) must differ"; return; }
  pass
}
test_validate_never_autodetects_on_invalid() {   # anti silent-re-derive (D2)
  # Goal: when the bound command is missing, validate's verdict is about THAT
  #       command -- it must not quietly rescue the binding by auto-detecting
  #       some other runner that happens to be installed (the re-derivation D2 forbids).
  # Boundaries: proves non-substitution; does not re-test the reconfigure offer.
  # Arrange: a project bound to a missing command, while common runners
  #          (a real shell / make-like tool) ARE present on PATH.
  # Act: validate the verification binding.
  # Assert: still fails (non-zero) and the failure names the BOUND missing
  #         command -- not a substituted runner; presence of other tools does
  #         not turn an invalid binding into a pass.
  proj="$(_proj_verif "totally-absent-cmd-zzz --run")"
  _run "$proj" validate verification              # real runners (sh, etc.) are on PATH
  rm -rf "$proj"
  [ "$_rc" -ne 0 ] || { fail "invalid binding must fail even when other runners exist, got 0"; return; }
  case "$_err" in
    *totally-absent-cmd-zzz*) : ;;
    *) fail "failure must name the bound command, not a substitute, got '$_err'"; return ;;
  esac
  pass
}
test_validate_none_is_ok() {                     # D3: 'none' drops mechanism, not invariant
  # Goal: a Verification binding of 'none' is a deliberate valid state (no
  #       automated check; evidence = demo), so validate reports OK -- it must
  #       NOT treat the sentinel as a program named 'none' that is "not found".
  # Boundaries: only the none-is-valid verdict; how ws.4-run then demands demo
  #       evidence is that skill's concern, not validate's.
  # Arrange: a project whose Verification binding is literally 'none'.
  # Act: validate the verification binding.
  # Assert: exit 0; stderr does not report 'none' as a missing command.
  proj="$(_proj_verif "none")"
  _run "$proj" validate verification
  rm -rf "$proj"
  [ "$_rc" -eq 0 ] || { fail "validate of a 'none' binding must be OK (exit 0), got $_rc (stderr: $_err)"; return; }
  case "$_err" in
    *"not found"*|*none*) fail "'none' must not be treated as a missing command, got '$_err'"; return ;;
    *) : ;;
  esac
  pass
}

# ===========================================================================
# Group C: anchor writer -- /ws.0-start setup
# ===========================================================================

test_setup_writes_verification_row() {           # AC1  -- `ws-binding set verification <cmd>`
  # Goal: setting the verification binding materialises a WHITTLESPEC.md whose
  #       Verification section records that command -- and it round-trips: a
  #       subsequent `get verification` returns exactly what was set.
  # Boundaries: the write+round-trip of one concept; does NOT test anchoring
  #       (separate), nor updating an already-present row (flagged separately).
  # Arrange: an empty project (no WHITTLESPEC.md yet).
  # Act: set the verification binding to a distinctive command.
  # Assert: WHITTLESPEC.md now exists with a "## Verification" section, and
  #         get verification returns that exact command.
  proj="$(mktemp -d)"
  _run "$proj" set verification "pytest -q"
  set_rc="$_rc"
  _run "$proj" get verification
  got="$_out"; get_rc="$_rc"
  file_exists=no; [ -f "$proj/WHITTLESPEC.md" ] && file_exists=yes
  has_header=no; grep -q '^## Verification$' "$proj/WHITTLESPEC.md" 2>/dev/null && has_header=yes
  rm -rf "$proj"
  [ "$set_rc" -eq 0 ] || { fail "set should succeed, got $set_rc (stderr: $_err)"; return; }
  [ "$file_exists" = yes ] || { fail "set must create WHITTLESPEC.md"; return; }
  [ "$has_header" = yes ] || { fail "WHITTLESPEC.md must contain a '## Verification' section"; return; }
  { [ "$get_rc" -eq 0 ] && [ "$got" = "pytest -q" ]; } \
    || { fail "round-trip: get should return 'pytest -q', got '$got' (rc $get_rc)"; return; }
  pass
}
test_get_resolves_durability_section() {         # Slice 3: durability header mapping
  # Goal: `get durability` reads the ## Durability section's Binding line -- the
  #       one thing (header_for's concept->section mapping) that would fail
  #       unseen on an adopter's machine if that mapping were wrong.
  # Boundaries: only that durability resolves to its own section's value; does
  #       NOT parse timing prose (that is skill-read, not get's concern).
  # Arrange: an empty project; set durability to a distinctive mechanism+timing.
  # Act: set durability, then get it back.
  # Assert: round-trips exactly; exit 0; landed in a "## Durability" section.
  proj="$(mktemp -d)"
  _run "$proj" set durability "git commit; timing: per-slice"
  set_rc="$_rc"
  _run "$proj" get durability
  got="$_out"; get_rc="$_rc"
  has_header=no; grep -q '^## Durability$' "$proj/WHITTLESPEC.md" 2>/dev/null && has_header=yes
  rm -rf "$proj"
  [ "$set_rc" -eq 0 ] || { fail "set durability should succeed, got $set_rc (stderr: $_err)"; return; }
  [ "$has_header" = yes ] || { fail "set must create a '## Durability' section"; return; }
  { [ "$get_rc" -eq 0 ] && [ "$got" = "git commit; timing: per-slice" ]; } \
    || { fail "round-trip: get durability should return the set value, got '$got' (rc $get_rc)"; return; }
  pass
}
test_get_discovery_capture_round_trips() {       # Slice 5: header mapping
  # Goal: set/get for discovery-capture resolves its own ## section -- guards
  #       header_for's concept->section mapping, which would fail unseen on an
  #       adopter's machine if wrong. The value is elastic (a destination list
  #       with a routing rule), so the round-trip must survive punctuation.
  proj="$(mktemp -d)"
  _run "$proj" set discovery-capture "process observations -> docs/process-backlog.md; research notes -> team wiki"
  set_rc="$_rc"
  _run "$proj" get discovery-capture
  got="$_out"; get_rc="$_rc"
  has_header=no; grep -q '^## Discovery capture$' "$proj/WHITTLESPEC.md" 2>/dev/null && has_header=yes
  rm -rf "$proj"
  [ "$set_rc" -eq 0 ] || { fail "set should succeed, got $set_rc (stderr: $_err)"; return; }
  [ "$has_header" = yes ] || { fail "set must create a '## Discovery capture' section"; return; }
  { [ "$get_rc" -eq 0 ] && [ "$got" = "process observations -> docs/process-backlog.md; research notes -> team wiki" ]; } \
    || { fail "round-trip mismatch, got '$got' (rc $get_rc)"; return; }
  pass
}
test_get_discovery_capture_absent_section_is_the_default() {   # Slice 5: installed base
  # Goal: a project configured before this adapter existed has a WHITTLESPEC.md
  #       with no '## Discovery capture' section. That must read as "use the
  #       defaults" -- empty value, exit 0 -- not as an error. Getting this wrong
  #       is the Slice 3 backward-compat no-ship repeated.
  proj="$(mktemp -d)"
  printf '## Verification\nBinding: make test\n' > "$proj/WHITTLESPEC.md"
  _run "$proj" get discovery-capture
  got="$_out"; rc="$_rc"
  rm -rf "$proj"
  [ "$rc" -eq 0 ] || { fail "absent section must exit 0 (defaults apply), got $rc"; return; }
  [ -z "$got" ] || { fail "absent section must yield an empty value, got '$got'"; return; }
  pass
}
test_get_current_behaviour_authority_round_trips() {  # Slice 4: header mapping
  # Goal: set/get for current-behaviour-authority resolves its own ## section --
  #       guards header_for's concept->section mapping (would fail unseen on an
  #       adopter's machine if wrong). Unbound is handled as the default in prose,
  #       not here.
  proj="$(mktemp -d)"
  _run "$proj" set current-behaviour-authority "OpenAPI spec for the API; tests for behaviour"
  set_rc="$_rc"
  _run "$proj" get current-behaviour-authority
  got="$_out"; get_rc="$_rc"
  has_header=no; grep -q '^## Current-behaviour authority$' "$proj/WHITTLESPEC.md" 2>/dev/null && has_header=yes
  rm -rf "$proj"
  [ "$set_rc" -eq 0 ] || { fail "set should succeed, got $set_rc (stderr: $_err)"; return; }
  [ "$has_header" = yes ] || { fail "set must create a '## Current-behaviour authority' section"; return; }
  { [ "$get_rc" -eq 0 ] && [ "$got" = "OpenAPI spec for the API; tests for behaviour" ]; } \
    || { fail "round-trip mismatch, got '$got' (rc $get_rc)"; return; }
  pass
}
test_get_durability_absent_section_is_empty_not_error() {  # Codex #1: back-compat default
  # Goal: a WHITTLESPEC.md configured before durability existed (has other
  #       sections, no ## Durability) yields empty output + exit 0 -- the signal
  #       ws.4-run §1c reads as "unbound -> assume git default", NOT an error and
  #       NOT exit 3. Locks the backward-compat path Codex flagged.
  # Boundaries: only the empty+0 accessor contract; the "assume git" branch is
  #       ws.4-run prose, not shell-testable here.
  proj="$(mktemp -d)"
  cat > "$proj/WHITTLESPEC.md" <<'EOF'
## Verification
Binding: pytest -q
EOF
  _run "$proj" get durability
  rm -rf "$proj"
  [ "$_rc" -eq 0 ] || { fail "absent Durability section must be exit 0 (unbound=git default), got $_rc"; return; }
  [ -z "$_out" ] || { fail "absent Durability section must yield empty output, got '$_out'"; return; }
  pass
}
test_set_updates_existing_row() {                # reconfigure: set replaces, never duplicates
  # Goal: re-setting a concept that already has a row updates it in place, so the
  #       record keeps exactly one section per concept and get returns the newest
  #       value -- reconfigure must not leave a stale duplicate for get to read.
  # Boundaries: update semantics of one concept's Binding; not anchoring.
  # Arrange: a project where verification is already set to command A.
  # Act: set verification to a different command B.
  # Assert: get verification returns B; WHITTLESPEC.md has exactly one
  #         "## Verification" section (no duplicate appended).
  proj="$(mktemp -d)"
  _run "$proj" set verification "alpha --one"
  _run "$proj" set verification "beta --two"
  _run "$proj" get verification
  got="$_out"
  count="$(grep -c '^## Verification$' "$proj/WHITTLESPEC.md" 2>/dev/null)"; count="${count:-0}"
  rm -rf "$proj"
  [ "$got" = "beta --two" ] || { fail "get should return the updated value 'beta --two', got '$got'"; return; }
  [ "$count" -eq 1 ] || { fail "expected exactly one Verification section after update, got $count"; return; }
  pass
}
test_anchor_creates_files_if_absent() {          # AC1  -- `ws-binding anchor`
  # Goal: anchoring makes every session aware of the binding record by pointing
  #       to it from BOTH CLAUDE.md and AGENTS.md, creating them if absent.
  # Boundaries: existence + pointer presence in both files; pointer-not-value
  #       and preservation are separate tests.
  # Arrange: a project that has neither CLAUDE.md nor AGENTS.md.
  # Act: anchor.
  # Assert: both files now exist, and each contains a line referencing WHITTLESPEC.md.
  proj="$(mktemp -d)"                             # neither CLAUDE.md nor AGENTS.md
  _run "$proj" anchor
  anc_rc="$_rc"
  c_exists=no; [ -f "$proj/CLAUDE.md" ] && c_exists=yes
  a_exists=no; [ -f "$proj/AGENTS.md" ] && a_exists=yes
  c_ref=no; grep -q 'WHITTLESPEC.md' "$proj/CLAUDE.md" 2>/dev/null && c_ref=yes
  a_ref=no; grep -q 'WHITTLESPEC.md' "$proj/AGENTS.md" 2>/dev/null && a_ref=yes
  rm -rf "$proj"
  [ "$anc_rc" -eq 0 ] || { fail "anchor should succeed, got $anc_rc (stderr: $_err)"; return; }
  { [ "$c_exists" = yes ] && [ "$a_exists" = yes ]; } || { fail "anchor must create both CLAUDE.md and AGENTS.md"; return; }
  { [ "$c_ref" = yes ] && [ "$a_ref" = yes ]; } || { fail "each anchored file must reference WHITTLESPEC.md"; return; }
  pass
}
test_anchor_is_pointer_not_value() {             # AC1, D2 -- anchoring is a pointer, never a binding
  # Goal: the anchor is a POINTER to the record, never a copy of a binding --
  #       so the bound command must not leak into CLAUDE.md/AGENTS.md (that leak
  #       is exactly the system-CLAUDE.md-authority bug D2 exists to prevent).
  # Boundaries: absence of the value + presence of a reference; not idempotency.
  # Arrange: a project whose WHITTLESPEC.md binds a distinctive command; anchor.
  # Act: inspect the two anchored files.
  # Assert: neither file contains the command string; both reference WHITTLESPEC.md.
  proj="$(_proj_verif "supersecret-distinctive-cmd --xyz")"
  _run "$proj" anchor
  leaked=no
  grep -q 'supersecret-distinctive-cmd' "$proj/CLAUDE.md" 2>/dev/null && leaked=yes
  grep -q 'supersecret-distinctive-cmd' "$proj/AGENTS.md" 2>/dev/null && leaked=yes
  c_ref=no; grep -q 'WHITTLESPEC.md' "$proj/CLAUDE.md" 2>/dev/null && c_ref=yes
  a_ref=no; grep -q 'WHITTLESPEC.md' "$proj/AGENTS.md" 2>/dev/null && a_ref=yes
  rm -rf "$proj"
  [ "$leaked" = no ] || { fail "bound command must NOT appear in anchor files (pointer only)"; return; }
  { [ "$c_ref" = yes ] && [ "$a_ref" = yes ]; } || { fail "both anchor files must reference WHITTLESPEC.md"; return; }
  pass
}
test_anchor_preserves_unrelated_lines() {        # AC3 case 5 -- reconfigure is non-destructive
  # Goal: anchoring is additive -- an operator's existing CLAUDE.md/AGENTS.md
  #       instructions survive untouched (reconfiguration must not clobber them).
  # Boundaries: preservation of prior content; not the pointer's exact wording.
  # Arrange: CLAUDE.md and AGENTS.md that already hold distinctive unrelated lines.
  # Act: anchor.
  # Assert: every pre-existing line is still present, and the pointer was added.
  proj="$(mktemp -d)"
  printf 'KEEP-claude-line-one\nKEEP-claude-line-two\n' > "$proj/CLAUDE.md"
  printf 'KEEP-agents-line-A\n' > "$proj/AGENTS.md"
  _run "$proj" anchor
  c1=no; grep -q 'KEEP-claude-line-one' "$proj/CLAUDE.md" && c1=yes
  c2=no; grep -q 'KEEP-claude-line-two' "$proj/CLAUDE.md" && c2=yes
  a1=no; grep -q 'KEEP-agents-line-A' "$proj/AGENTS.md" && a1=yes
  c_ref=no; grep -q 'WhittleSpec bindings:' "$proj/CLAUDE.md" && c_ref=yes
  a_ref=no; grep -q 'WhittleSpec bindings:' "$proj/AGENTS.md" && a_ref=yes
  rm -rf "$proj"
  { [ "$c1" = yes ] && [ "$c2" = yes ] && [ "$a1" = yes ]; } || { fail "pre-existing lines must survive anchoring"; return; }
  { [ "$c_ref" = yes ] && [ "$a_ref" = yes ]; } || { fail "pointer must be added to both files"; return; }
  pass
}
test_anchor_respects_operator_symlink() {        # INV-2 -- the adopter's file layout is theirs
  # Goal: an operator who has symlinked one instruction file to the other (a real
  #       convention) keeps that layout, and gets exactly ONE pointer line through
  #       it -- WhittleSpec never restructures files it does not own.
  # Boundaries: symlink survival + single pointer; not the pointer's wording.
  #             Unix-only by design (umbrella: runtime degrades, test infra may not).
  # Arrange: two projects, symlinked each way, each holding prior operator content.
  # Act: anchor.
  # Assert: the symlink survives, prior content survives, exactly one pointer.
  for dir in c2a a2c; do
    proj="$(mktemp -d)"
    if [ "$dir" = c2a ]; then
      printf 'KEEP-operator-line\n' > "$proj/AGENTS.md"
      ( cd "$proj" && ln -s AGENTS.md CLAUDE.md )
      real="$proj/AGENTS.md"; link="$proj/CLAUDE.md"
    else
      printf 'KEEP-operator-line\n' > "$proj/CLAUDE.md"
      ( cd "$proj" && ln -s CLAUDE.md AGENTS.md )
      real="$proj/CLAUDE.md"; link="$proj/AGENTS.md"
    fi
    _run "$proj" anchor
    still_link=no; [ -L "$link" ] && still_link=yes
    kept=no; grep -q 'KEEP-operator-line' "$real" && kept=yes
    count="$(grep -c 'WhittleSpec bindings:' "$real" 2>/dev/null)"; count="${count:-0}"
    rm -rf "$proj"
    [ "$still_link" = yes ] || { fail "$dir: operator symlink must survive anchoring"; return; }
    [ "$kept" = yes ] || { fail "$dir: operator content must survive anchoring"; return; }
    [ "$count" -eq 1 ] || { fail "$dir: exactly one pointer through the symlink, got $count"; return; }
  done
  pass
}
test_anchor_idempotent() {                       # AC1 robustness -- re-anchoring is safe
  # Goal: running anchor more than once (e.g. re-setup) does not accumulate
  #       duplicate pointer lines -- the anchor detects its own prior presence.
  # Boundaries: no duplication on repeat; not preservation of foreign lines.
  # Arrange: a project; anchor once, then anchor again.
  # Act: count the pointer lines in each file.
  # Assert: exactly one pointer line in CLAUDE.md and one in AGENTS.md.
  proj="$(mktemp -d)"
  _run "$proj" anchor
  _run "$proj" anchor
  c_count="$(grep -c 'WhittleSpec bindings:' "$proj/CLAUDE.md" 2>/dev/null)"; c_count="${c_count:-0}"
  a_count="$(grep -c 'WhittleSpec bindings:' "$proj/AGENTS.md" 2>/dev/null)"; a_count="${a_count:-0}"
  rm -rf "$proj"
  [ "$c_count" -eq 1 ] || { fail "CLAUDE.md must have exactly one pointer line, got $c_count"; return; }
  [ "$a_count" -eq 1 ] || { fail "AGENTS.md must have exactly one pointer line, got $a_count"; return; }
  pass
}

# ===========================================================================
# Group D: marker scheme (inspection-as-test over prose)
# ===========================================================================

test_meta_defines_layer_model_and_markers() {    # AC4
  # Goal: ws._meta is the single definition point for the four-layer model
  #       (CORE / DEFAULT / IF-CONFIGURED / EXAMPLE) and the concrete marker
  #       syntax (<!-- WS:<LAYER> <id> --> ... <!-- /WS -->), so skills and the
  #       future validator share one vocabulary.
  # Boundaries: presence of the vocabulary + syntax definition; NOT whether any
  #       given passage is marked (next test), NOT validator behaviour (Task 3).
  # Arrange: the WhittleSpec ws._meta SKILL.md.
  # Act: read it.
  # Assert: all four layer names appear, AND the opener form "<!-- WS:" and the
  #         closer "<!-- /WS -->" are both shown as the defined syntax.
  for term in CORE DEFAULT IF-CONFIGURED EXAMPLE '<!-- WS:' '<!-- /WS -->'; do
    grep -Fq -- "$term" "$META" || { fail "ws._meta must define/show: $term"; return; }
  done
  pass
}
test_task1_binding_prose_wrapped_if_configured() {  # AC4
  # Goal: the verification-binding passage Task 1 adds to ws._meta is adapter
  #       prose, so it is enclosed in a balanced IF-CONFIGURED marker pair --
  #       not left as unmarked CORE law.
  # Boundaries: this passage is wrapped + markers balance; not a full marker census.
  # Arrange: ws._meta.
  # Act: find the IF-CONFIGURED region carrying the verification binding.
  # Assert: an opener "<!-- WS:IF-CONFIGURED verification-binding -->" exists,
  #         the region closes with "<!-- /WS -->", every WS opener in the file
  #         has a matching closer (balanced), and the enclosed text mentions
  #         verification (the marker wraps the right passage).
  grep -Fq -- '<!-- WS:IF-CONFIGURED verification-binding -->' "$META" \
    || { fail "missing IF-CONFIGURED opener for verification-binding"; return; }
  opens="$(grep -c -- '<!-- WS:' "$META" 2>/dev/null)"; opens="${opens:-0}"
  closes="$(grep -c -- '<!-- /WS -->' "$META" 2>/dev/null)"; closes="${closes:-0}"
  [ "$opens" -eq "$closes" ] || { fail "unbalanced markers: $opens openers vs $closes closers"; return; }
  enclosed="$(awk '/<!-- WS:IF-CONFIGURED verification-binding -->/{f=1;next} /<!-- \/WS -->/{if(f)exit} f' "$META")"
  case "$enclosed" in
    *[Vv]erification*) : ;;
    *) fail "verification-binding region must mention verification, got '$enclosed'"; return ;;
  esac
  pass
}
test_markers_are_block_level_not_per_sentence() {   # D1 'never per sentence'
  # Goal: markers wrap whole blocks, never a fragment inside a sentence -- the
  #       D1 "never per sentence" rule, operationalised as: a marker comment is
  #       the only non-whitespace content on its line (never trailing prose).
  # Boundaries: block-vs-inline granularity via the own-line proxy; not a full
  #       grammar analysis of what sits between markers.
  # Arrange: ws._meta.
  # Act: inspect every line containing a WS marker comment.
  # Assert: each WS opener/closer occupies its own line (matches
  #         ^\s*<!-- (WS:...|/WS) -->\s*$) -- no marker embedded mid-sentence.
  count="$(grep -c -- '<!-- WS:\|<!-- /WS -->' "$META" 2>/dev/null)"; count="${count:-0}"
  [ "$count" -gt 0 ] || { fail "expected WS markers present to check block-level, found none"; return; }
  bad="$(grep -n -- '<!-- WS:\|<!-- /WS -->' "$META" | grep -vE '^[0-9]+:[[:space:]]*<!-- (WS:.*|/WS) -->[[:space:]]*$' || true)"
  [ -z "$bad" ] || { fail "marker(s) not on their own line (block-level): $bad"; return; }
  pass
}

# ===========================================================================
# Group E: clone-agnostic meta-path (AC5)
# ===========================================================================

test_skeleton_skills_have_no_clonenamed_path() { # AC5 / Task2 precursor
  # Goal: no skeleton skill hardcodes the clone directory name ("WhittleSpec")
  #       in its shared-context path -- vendoring under any other name must not
  #       break loading.
  # Boundaries: absence of the clone-named path across the skeleton set
  #       (ws.0-start, ws.4-run, ws._meta); positive resolution is next tests.
  # Arrange: the skeleton skill SKILL.md files.
  # Act: search each for a clone-named meta path.
  # Assert: zero occurrences of "WhittleSpec/skills" across all skeleton skills.
  for s in $SKELETON; do
    grep -Fq 'WhittleSpec/skills' "$SKILLS/$s/SKILL.md" \
      && { fail "$s still contains clone-named path 'WhittleSpec/skills'"; return; }
  done
  pass
}
test_load_resolves_under_renamed_clone() {       # AC5
  # Goal: with the clone dir renamed away from "WhittleSpec", each skeleton
  #       skill's shared-context reference still resolves -- because it names a
  #       sibling (ws._meta/SKILL.md) in the same skills dir, not a clone path.
  # Boundaries: structural resolution (sibling present + no clone-name
  #       dependency); does NOT verify the LLM actually loads it (live exercise
  #       at the completion gate covers that).
  # Arrange: copy the skills tree under a differently-named parent dir.
  # Act: for each skeleton skill in the renamed tree, resolve the sibling meta.
  # Assert: a sibling ws._meta/SKILL.md exists beside each skeleton skill, and
  #         no skeleton skill in the renamed tree still names "WhittleSpec".
  base="$(mktemp -d)"; root="$base/RenamedClone"; mkdir -p "$root"
  for s in $SKELETON; do cp -r "$SKILLS/$s" "$root/"; done
  for s in $SKELETON; do
    f="$root/$s/SKILL.md"
    [ -f "$f" ] || { fail "$s missing in renamed tree"; rm -rf "$base"; return; }
    [ -f "$root/ws._meta/SKILL.md" ] || { fail "sibling ws._meta missing beside $s after rename"; rm -rf "$base"; return; }
    grep -Fq 'WhittleSpec/skills' "$f" && { fail "$s still uses clone-named path after rename"; rm -rf "$base"; return; }
  done
  rm -rf "$base"
  pass
}
test_load_resolves_under_custom_config_dir() {   # AC5
  # Goal: when the suite is installed under a custom CLAUDE_CONFIG_DIR (not
  #       ~/.claude), shared context still resolves -- again via the sibling.
  # Boundaries: structural resolution under a custom config root; not LLM load.
  # Arrange: place the skills tree under $CUSTOM/skills (a stand-in config root).
  # Act: resolve ws._meta as a sibling under that custom root.
  # Assert: $CUSTOM/skills/ws._meta/SKILL.md exists beside each skeleton skill,
  #         and the skeleton skills reference ws._meta by a sibling-relative
  #         path (token "ws._meta/SKILL.md"), not a single hardcoded absolute.
  base="$(mktemp -d)"; mkdir -p "$base/skills"
  for s in $SKELETON; do cp -r "$SKILLS/$s" "$base/skills/"; done
  [ -f "$base/skills/ws._meta/SKILL.md" ] || { fail "ws._meta not resolvable under custom config dir"; rm -rf "$base"; return; }
  for s in $SKELETON; do
    f="$base/skills/$s/SKILL.md"
    case "$s" in
      ws._meta) : ;;   # the referent itself, not a consumer -> has no self-load line
      *) grep -Fq 'ws._meta/SKILL.md' "$f" \
           || { fail "$s must reference ws._meta by a sibling-relative path"; rm -rf "$base"; return; } ;;
    esac
    grep -Fq 'WhittleSpec/skills' "$f" && { fail "$s uses clone-named path, not config-agnostic"; rm -rf "$base"; return; }
  done
  rm -rf "$base"
  pass
}

# ===========================================================================
# NOT COVERING (and why):
#  - LLM actually loads+obeys doctrine: not shell-testable; closed by live
#    exercise at the completion gate (Exercise-Verified rule), not a fixture.
#  - Validator rejection of malformed/nested/unclosed markers: that IS Slice 3
#    (Task 3), not Task 1. Here we only assert Task-1's own markers are well-formed.
#  - Concurrent edits to WHITTLESPEC.md: single-user setup, out of scope.
#  - Evidence-profile *consumption*: Task 4. Task 1 only carries its row in the format.
# ===========================================================================

# --- run all registered tests ---------------------------------------------
_ws_tests=$(declare -F | awk '{print $3}' | grep '^test_' | sort)
for _ws_current in $_ws_tests; do "$_ws_current"; done
printf -- '----\n%d pass, %d fail, %d todo\n' "$_ws_pass" "$_ws_fail" "$_ws_todo"
[ "$_ws_fail" -eq 0 ]
