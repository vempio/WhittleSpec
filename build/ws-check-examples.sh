#!/bin/sh
# ws-check-examples.sh -- verify the public example corpus is self-contained.
#
# POSIX sh + awk/grep/sed only, matching the pure-shell idiom of
# ws-check-refs.sh. Three checks, run from the project root (cwd holding
# `examples/` and `skills/`):
#
# 1. Existence: every backticked `examples/<name>/<file>` path in the manifest
#    table (examples/_examples.md) resolves to a real file.
# 2. Membership: every seed-length example citation in
#    skills/ws._meta/seed-template.md (a backticked `examples/<name>/seed.md`
#    path) names a path listed in the manifest -- catches a citation added
#    without cataloguing it, or a manifest entry renamed without updating the
#    citation.
# 3. Denylist (standing regression guard): every literal string in the
#    denylist file (one per line) must not appear anywhere under the scanned
#    roots. This is where the private case-history this corpus replaced is
#    named, so it can never quietly reappear.
#
# What this does NOT do: judge whether an example is *good* teaching material.
# That is a semantic review a human performs when the corpus changes, not a
# grep -- see examples/_examples.md's own instruction to keep it in sync.
#
# Usage: ws-check-examples.sh [--manifest FILE] [--denylist FILE]
#                              [--seed-template FILE] [ROOT ...]
#   ROOT             directories to scan for the denylist check (default: skills examples)
#   --manifest       the example-corpus index (default: examples/_examples.md)
#   --denylist       literal strings that must never reappear (default:
#                     ws-check-examples-denylist.txt beside this script)
#   --seed-template  file whose seed-length citations get the membership check
#                     (default: skills/ws._meta/seed-template.md)

set -eu

SCRIPT_DIR=$(dirname "$0")
MANIFEST="examples/_examples.md"
DENYLIST="$SCRIPT_DIR/ws-check-examples-denylist.txt"
SEED_TEMPLATE="skills/ws._meta/seed-template.md"
roots=""
while [ $# -gt 0 ]; do
	case "$1" in
		--manifest) MANIFEST="$2"; shift 2 ;;
		--manifest=*) MANIFEST="${1#*=}"; shift ;;
		--denylist) DENYLIST="$2"; shift 2 ;;
		--denylist=*) DENYLIST="${1#*=}"; shift ;;
		--seed-template) SEED_TEMPLATE="$2"; shift 2 ;;
		--seed-template=*) SEED_TEMPLATE="${1#*=}"; shift ;;
		*) roots="$roots $1"; shift ;;
	esac
done
[ -n "$roots" ] || roots="skills examples"

fail=0

# --- 1. existence: every manifest-listed path resolves ---
if [ ! -f "$MANIFEST" ]; then
	printf 'manifest not found: %s\n' "$MANIFEST" >&2
	exit 1
fi
manifest_paths=$(grep -oE '`examples/[a-zA-Z0-9_./-]+`' "$MANIFEST" | tr -d '`' | sort -u || true)

for p in $manifest_paths; do
	if [ ! -f "$p" ]; then
		printf 'missing-example: %s (listed in %s)\n' "$p" "$MANIFEST" >&2
		fail=1
	fi
done

# --- 2. membership: every seed-length citation names a manifest path ---
# A check that disappears along with its own input is not a check, so a missing
# seed template or denylist is a failure here rather than a silent skip.
if [ ! -f "$SEED_TEMPLATE" ]; then
	printf 'seed template not found: %s\n' "$SEED_TEMPLATE" >&2
	exit 1
fi
cited=$(grep -oE '`examples/[a-zA-Z0-9_./-]+/seed\.md`' "$SEED_TEMPLATE" | tr -d '`' | sort -u || true)
manifest_flat=$(printf '%s\n' "$manifest_paths" | tr '\n' ' ')
for c in $cited; do
	case " $manifest_flat " in
		*" $c "*) ;;
		*)
			printf 'uncatalogued-citation: %s (cited in %s, not listed in %s)\n' \
				"$c" "$SEED_TEMPLATE" "$MANIFEST" >&2
			fail=1
			;;
	esac
done

# --- 3. denylist: retired private names must never reappear ---
# `_completed/` is this repo's historical-record convention (closed slices are
# not rewritten -- see ws._meta > Spec Lifecycle); a retro or task file that
# NAMES a retired term as part of the record of retiring it is not a leak, so
# hits under any `_completed/` directory are excluded, not flagged.
if [ ! -f "$DENYLIST" ]; then
	printf 'denylist not found: %s\n' "$DENYLIST" >&2
	exit 1
fi
while IFS= read -r term || [ -n "$term" ]; do
	term=${term%%#*}
	term=$(printf '%s' "$term" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	[ -n "$term" ] || continue
	hits=$(grep -rFn "$term" $roots 2>/dev/null | grep -v '/_completed/' || true)
	if [ -n "$hits" ]; then
		printf 'denylisted-term: "%s" found:\n%s\n' "$term" "$hits" >&2
		fail=1
	fi
done < "$DENYLIST"

if [ "$fail" -eq 0 ]; then
	echo "Example corpus self-contained."
fi
exit "$fail"
