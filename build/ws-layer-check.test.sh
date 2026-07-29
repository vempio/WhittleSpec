#!/usr/bin/env bash
# Self-test for the marker-aware layer validator (Slice 1, Task 3) -- LEAN.
# Scope (ratified): prove the three D1 rejection classes + inventory 1:1 on
# planted fixtures, and validate the real Slice-1 marked block clean. Marker-cost
# reporting and ws._meta sectioning are do-and-eyeball, not TDD.
#
# Unit under test: build/ws-layer-check.sh [--inventory <f>] <file>...
#   exit 0 clean; non-zero + class name on stderr per violation.
set -u

_cur='' _pass=0 _fail=0
pass() { printf 'PASS  %-46s\n' "$_cur"; _pass=$((_pass + 1)); }
fail() { printf 'FAIL  %-46s %s\n' "$_cur" "$1"; _fail=$((_fail + 1)); }

here="$(cd "$(dirname "$0")" && pwd)"
LC="$here/ws-layer-check.sh"
_rc=0 _err=''
# _run <args...>  (stderr -> _err, exit -> _rc)
_run() { local e; e="$(mktemp)"; "$LC" "$@" 2>"$e" >/dev/null; _rc=$?; _err="$(cat "$e")"; rm -f "$e"; }
mkinv() { printf '%s\n' "$@" > "$1"; }   # write inventory lines to a file

# --- 1: mechanism in unmarked CORE is rejected --------------------------------
test_rejects_mechanism_in_unmarked_core() { _cur=$FUNCNAME
  d=$(mktemp -d); printf 'Doctrine says run `make test` to verify.\n' > "$d/f.md"; mkinv "$d/inv" ''
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -ne 0 ] || { fail "expected rejection, got exit 0"; return; }
  case "$_err" in *CORE-mechanism*|*CORE*mechanism*) pass ;; *) fail "class not named: $_err";; esac
}

# --- 2: the same mechanism inside a marker is accepted ------------------------
test_accepts_mechanism_inside_marker() { _cur=$FUNCNAME
  d=$(mktemp -d)
  printf '<!-- WS:EXAMPLE demo -->\nrun make test to verify.\n<!-- /WS -->\n' > "$d/f.md"
  mkinv "$d/inv" 'demo: illustrative test command (EXAMPLE)'
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -eq 0 ] || { fail "expected clean, got $_rc: $_err"; return; }
  pass
}

# --- 3: marker id absent from inventory is rejected ---------------------------
test_rejects_unknown_marker_id() { _cur=$FUNCNAME
  d=$(mktemp -d)
  printf '<!-- WS:IF-CONFIGURED ghost -->\nx\n<!-- /WS -->\n' > "$d/f.md"; mkinv "$d/inv" 'known: y (DEFAULT)'
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -ne 0 ] || { fail "expected rejection, got 0"; return; }
  case "$_err" in *unknown-id*) pass ;; *) fail "class not named: $_err";; esac
}

# --- 4: inventory must be 1:1 -- an unused inventory id is rejected -----------
test_rejects_unused_inventory_id() { _cur=$FUNCNAME
  d=$(mktemp -d)
  printf '<!-- WS:DEFAULT used -->\nx\n<!-- /WS -->\n' > "$d/f.md"
  mkinv "$d/inv" 'used: a (DEFAULT)' 'orphan: b (DEFAULT)'
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -ne 0 ] || { fail "expected rejection for unused inventory id, got 0"; return; }
  case "$_err" in *unused-inventory*|*orphan*) pass ;; *) fail "class not named: $_err";; esac
}

# --- 5: unclosed marker rejected ---------------------------------------------
test_rejects_unclosed_marker() { _cur=$FUNCNAME
  d=$(mktemp -d); printf '<!-- WS:DEFAULT a -->\nno closer here\n' > "$d/f.md"; mkinv "$d/inv" 'a: x (DEFAULT)'
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -ne 0 ] || { fail "expected rejection, got 0"; return; }
  case "$_err" in *unclosed*) pass ;; *) fail "class not named: $_err";; esac
}

# --- 6: stray closer rejected ------------------------------------------------
test_rejects_stray_closer() { _cur=$FUNCNAME
  d=$(mktemp -d); printf 'text\n<!-- /WS -->\n' > "$d/f.md"; mkinv "$d/inv" ''
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -ne 0 ] || { fail "expected rejection, got 0"; return; }
  case "$_err" in *stray*) pass ;; *) fail "class not named: $_err";; esac
}

# --- 7: nested markers rejected ----------------------------------------------
test_rejects_nested_markers() { _cur=$FUNCNAME
  d=$(mktemp -d)
  printf '<!-- WS:DEFAULT a -->\n<!-- WS:DEFAULT b -->\nx\n<!-- /WS -->\n<!-- /WS -->\n' > "$d/f.md"
  mkinv "$d/inv" 'a: x (DEFAULT)' 'b: y (DEFAULT)'
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -ne 0 ] || { fail "expected rejection, got 0"; return; }
  case "$_err" in *nested*) pass ;; *) fail "class not named: $_err";; esac
}

# --- 8: malformed opener rejected (bad layer / missing id) -------------------
test_rejects_malformed_opener() { _cur=$FUNCNAME
  d=$(mktemp -d); printf '<!-- WS:BOGUS a -->\nx\n<!-- /WS -->\n' > "$d/f.md"; mkinv "$d/inv" 'a: x (DEFAULT)'
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -ne 0 ] || { fail "expected rejection, got 0"; return; }
  case "$_err" in *malformed*) pass ;; *) fail "class not named: $_err";; esac
}

# --- 8a: a denylisted word used as English is NOT a mechanism -----------------
# Word sense, not spelling. "make a decision" and "git history" are prose; a
# mechanism reference in this corpus is written in code formatting. Without this
# the check reported ~70% false positives and could not be acted on.
test_accepts_denylist_word_used_as_english() { _cur=$FUNCNAME
  d=$(mktemp -d)
  printf 'Unknowns or decisions to make? Vague goals ("make it better").\n' > "$d/f.md"
  mkinv "$d/inv" ''
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -eq 0 ] || { fail "English 'make' should not be a mechanism: $_err"; return; }
  pass
}

# --- 8b: a bare harness path is a mechanism whether or not it is formatted ----
test_rejects_bare_harness_path() { _cur=$FUNCNAME
  d=$(mktemp -d); printf 'Skills live in ~/.claude/skills for this.\n' > "$d/f.md"; mkinv "$d/inv" ''
  _run --inventory "$d/inv" "$d/f.md"; rm -rf "$d"
  [ "$_rc" -ne 0 ] || { fail "expected rejection, got exit 0"; return; }
  case "$_err" in *CORE-mechanism*) pass ;; *) fail "class not named: $_err";; esac
}

# --- 9: the real Slice-1 verification-binding block validates clean ----------
test_passes_real_slice1_marked_block() { _cur=$FUNCNAME
  d=$(mktemp -d); blk="$d/block.md"
  awk '/<!-- WS:IF-CONFIGURED verification-binding -->/{f=1} f{print} /<!-- \/WS -->/{if(f)exit}' \
    "$here/../skills/ws._meta/SKILL.md" > "$blk"
  mkinv "$d/inv" 'verification-binding: WHITTLESPEC verification adapter (IF-CONFIGURED)'
  _run --inventory "$d/inv" "$blk"; rm -rf "$d"
  [ "$_rc" -eq 0 ] || { fail "real marked block should validate clean, got $_rc: $_err"; return; }
  pass
}

for t in $(declare -F | awk '{print $3}' | grep '^test_' | sort); do "$t"; done
printf -- '----\n%d pass, %d fail\n' "$_pass" "$_fail"
[ "$_fail" -eq 0 ]
