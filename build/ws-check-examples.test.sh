#!/bin/sh
# Fixture-based regression guard for ws-check-examples.sh.
#
# Runs the validator through its real CLI entry point against the fixture
# corpus under fixtures/examplecheck/, asserting each check class fires
# exactly where planted and nowhere else. POSIX sh, no framework dependency.
# Must run from the WhittleSpec project root (the existence check resolves
# manifest paths relative to cwd, matching real usage under `make ws-test`):
#   sh build/ws-check-examples.test.sh

set -eu

HERE=$(cd "$(dirname "$0")" && pwd)

CHECK="$HERE/ws-check-examples.sh"
FIX="$HERE/fixtures/examplecheck"

# The manifest's paths resolve relative to cwd, and the corpus they name never
# ships. Running from the project root made the suite depend on a tree absent
# from every public clone -- so it builds its own instead.
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT INT TERM
mkdir -p "$WORK/examples/_fixtures/examplecheck"
printf 'fixture seed\n' > "$WORK/examples/_fixtures/examplecheck/seed-real.md"
cd "$WORK"

pass=0
fail=0

ok() { pass=$((pass + 1)); printf 'PASS %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf 'FAIL %s: %s\n' "$1" "$2"; }

# --- test: clean manifest + clean seed-template + clean roots -> passes ---
set +e
OUT=$("$CHECK" --manifest "$FIX/manifest-good.md" \
               --seed-template "$FIX/seed-template-good.md" \
               --denylist "$FIX/denylist.txt" \
               "$FIX/clean" 2>&1)
RC=$?
set -e
name="clean_fixture_set_passes"
if [ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'Example corpus self-contained.'; then
	ok "$name"
else
	bad "$name" "rc=$RC out=[$OUT]"
fi

# --- test: manifest entry that does not exist -> existence check fires ---
set +e
OUT=$("$CHECK" --manifest "$FIX/manifest-missing.md" \
               --seed-template "$FIX/seed-template-good.md" \
               --denylist "$FIX/denylist.txt" \
               "$FIX/clean" 2>&1)
RC=$?
set -e
name="missing_manifest_entry_fires_existence_check"
if [ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'missing-example: examples/_fixtures/examplecheck/seed-does-not-exist.md'; then
	ok "$name"
else
	bad "$name" "rc=$RC out=[$OUT]"
fi

# --- test: citation to a real but uncatalogued path -> membership check fires ---
set +e
OUT=$("$CHECK" --manifest "$FIX/manifest-good.md" \
               --seed-template "$FIX/seed-template-uncatalogued.md" \
               --denylist "$FIX/denylist.txt" \
               "$FIX/clean" 2>&1)
RC=$?
set -e
name="uncatalogued_citation_fires_membership_check"
if [ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'uncatalogued-citation: examples/_fixtures/examplecheck/uncatalogued/seed.md'; then
	ok "$name"
else
	bad "$name" "rc=$RC out=[$OUT]"
fi

# --- test: denylisted term present in scanned roots -> denylist check fires ---
set +e
OUT=$("$CHECK" --manifest "$FIX/manifest-good.md" \
               --seed-template "$FIX/seed-template-good.md" \
               --denylist "$FIX/denylist.txt" \
               "$FIX/dirty" 2>&1)
RC=$?
set -e
name="denylisted_term_fires_denylist_check"
if [ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'denylisted-term: "forbidden-fixture-term"'; then
	ok "$name"
else
	bad "$name" "rc=$RC out=[$OUT]"
fi

# --- test: denylisted term under a _completed/ dir is exempt (historical record) ---
set +e
OUT=$("$CHECK" --manifest "$FIX/manifest-good.md" \
               --seed-template "$FIX/seed-template-good.md" \
               --denylist "$FIX/denylist.txt" \
               "$FIX/completed-dir" 2>&1)
RC=$?
set -e
name="completed_dir_exempt_from_denylist"
if [ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'Example corpus self-contained.'; then
	ok "$name"
else
	bad "$name" "rc=$RC out=[$OUT]"
fi

# Real-corpus health is checked separately (`make ws-test`'s own
# `ws-check-examples` line, mirroring `ws-check-refs`) -- this file is
# fixtures-only, matching ws-check-refs.test.sh's split.

printf '\n%s/%s passed.\n' "$pass" "$((pass + fail))"
[ "$fail" -eq 0 ]
