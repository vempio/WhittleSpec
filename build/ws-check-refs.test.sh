#!/bin/sh
# Fixture-based regression guard for ws-check-refs.sh.
#
# Runs the validator through its real CLI entry point against the fixture corpus
# under fixtures/refcheck/, asserting it catches exactly the planted dangling
# references and nothing else. POSIX sh, no framework dependency:
#   sh build/ws-check-refs.test.sh

set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
CHECK="$HERE/ws-check-refs.sh"
FIX="$HERE/fixtures/refcheck"
SKILLS="$FIX/skills"
CORPUS="$FIX/corpus"

pass=0
fail=0

# ok NAME  -- record a passing assertion
ok() { pass=$((pass + 1)); printf 'PASS %s\n' "$1"; }
# bad NAME MSG -- record a failing assertion
bad() { fail=$((fail + 1)); printf 'FAIL %s: %s\n' "$1" "$2"; }

# run ROOTS... -- run the validator, capture stdout+exit; sets OUT and RC.
# Uses an empty ignore-list so these assertions are isolated from the shipped
# ws-check-refs-ignore.txt; the ignore mechanism gets its own dedicated test below.
run() {
	set +e
	OUT=$("$CHECK" "$@" --skills-dir "$SKILLS" --ignore /dev/null 2>/dev/null)
	RC=$?
	set -e
}

# --- test: flags exactly the two planted defects in bad.md ---
run "$CORPUS"
name="flags_exactly_the_planted_defects"
count=$(printf '%s\n' "$OUT" | grep -c ' -> ' || true)
if [ "$RC" -eq 1 ] && [ "$count" -eq 2 ] \
	&& printf '%s\n' "$OUT" | grep -q 'bad.md:5 -> command: /sdd.ghost' \
	&& printf '%s\n' "$OUT" | grep -q 'bad.md:6 -> link: missing.md'; then
	ok "$name"
else
	bad "$name" "rc=$RC count=$count out=[$OUT]"
fi

# --- test: tricky.md has no false positives ---
run "$CORPUS/tricky.md"
name="no_false_positives_in_tricky_file"
if [ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'No dangling references.'; then
	ok "$name"
else
	bad "$name" "rc=$RC out=[$OUT]"
fi

# --- test: a clean corpus subset returns no findings ---
run "$CORPUS/good.md" "$CORPUS/sibling.md"
name="clean_corpus_returns_no_findings"
if [ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'No dangling references.'; then
	ok "$name"
else
	bad "$name" "rc=$RC out=[$OUT]"
fi

# --- test: exit codes (dirty -> 1, clean -> 0) ---
name="exit_codes"
run "$CORPUS"; dirty=$RC
run "$CORPUS/good.md" "$CORPUS/sibling.md"; clean=$RC
if [ "$dirty" -eq 1 ] && [ "$clean" -eq 0 ]; then
	ok "$name"
else
	bad "$name" "dirty=$dirty clean=$clean"
fi

# --- test: ignore-list skips example tokens but not real broken pointers ---
name="ignore_list_is_selective"
set +e
OUT_OFF=$("$CHECK" "$CORPUS/../ignore-demo.md" --skills-dir "$SKILLS" --ignore /dev/null 2>/dev/null); RC_OFF=$?
OUT_ON=$("$CHECK" "$CORPUS/../ignore-demo.md" --skills-dir "$SKILLS" --ignore "$FIX/ignore.txt" 2>/dev/null); RC_ON=$?
set -e
# Without ignore: both /foo and /sdd.ghost flagged (rc 1). With ignore: only
# /sdd.ghost flagged, /foo gone (rc 1, still failing on the real defect).
if [ "$RC_OFF" -eq 1 ] && [ "$RC_ON" -eq 1 ] \
	&& printf '%s\n' "$OUT_OFF" | grep -q 'command: /foo' \
	&& printf '%s\n' "$OUT_ON" | grep -q 'command: /sdd.ghost' \
	&& ! printf '%s\n' "$OUT_ON" | grep -q 'command: /foo'; then
	ok "$name"
else
	bad "$name" "off=[$OUT_OFF] on=[$OUT_ON]"
fi

printf '\n%s/%s passed.\n' "$pass" "$((pass + fail))"
[ "$fail" -eq 0 ]
