#!/bin/sh
# ws-layer-check.sh -- marker-aware layer validator (Slice 1, Task 3).
#
# Usage: ws-layer-check.sh [--inventory <file>] <corpus-file>...
#
# Parses WS marker ranges (<!-- WS:<LAYER> <id> --> ... <!-- /WS -->) and rejects
# the three D1 failure classes, printing one "class: file: detail" line per
# violation to stderr; exit 0 = clean, non-zero = at least one violation:
#   - malformed-marker / nested-marker / stray-closer / unclosed-marker
#   - unknown-id (marker id absent from the inventory)
#   - unused-inventory-id (inventory id no marker uses -> 1:1 broken)
#   - CORE-mechanism (a denylisted environment mechanism in UNMARKED prose)
#
# Fenced code blocks (```...```) are skipped: they illustrate marker/mechanism
# syntax and must be exempt. This is dev/CI tooling (gawk-friendly), not the
# runtime helper.
set -u

INV="$(dirname "$0")/mechanism-inventory.md"
while [ $# -gt 0 ]; do
  case "$1" in
    --inventory) INV="$2"; shift 2 ;;
    *) break ;;
  esac
done

work="$(mktemp -d)"; rec="$work/rec"; used="$work/used"; : > "$rec"; : > "$used"
viol=0
inv_ids=''
[ -f "$INV" ] && inv_ids="$(sed -n 's/^\([A-Za-z0-9_-][A-Za-z0-9_-]*\)[[:space:]]*:.*/\1/p' "$INV")"

for f in "$@"; do
  awk -v F="$f" '
    BEGIN{ deny="pytest|make|git|Jira|Grep|Glob|Bash"; open=0; fence=0
           split("DEFAULT IF-CONFIGURED EXAMPLE", L, " "); for (i in L) valid[L[i]]=1 }
    /^```/ { fence = !fence; next }
    fence  { next }
    {
      if (match($0, /<!-- WS:[^>]*-->/)) {
        m=substr($0, RSTART, RLENGTH)
        gsub(/<!-- WS:[[:space:]]*/, "", m); gsub(/[[:space:]]*-->/, "", m)
        nf=split(m, a, /[[:space:]]+/); layer=a[1]; id=a[2]
        if (!(layer in valid) || id=="" || nf>2) { print "malformed-marker\t" F "\t" $0; next }
        if (open) { print "nested-marker\t" F "\t" $0; next }
        open=1; openid=id; print "USE\t" id; next
      }
      if ($0 ~ /<!--[[:space:]]*\/WS[[:space:]]*-->/) {
        if (!open) { print "stray-closer\t" F "\t" $0; next }
        open=0; next
      }
      if (!open) {
        # Word sense, not spelling. A mechanism reference in this corpus is written in
        # code formatting (`make test`, `pytest -q`); the same letters in prose
        # ("decisions to make", "git history") are English and claim nothing about the
        # environment. So the denylist is scoped to backticked spans -- without this the
        # check reported roughly 70% false positives and could not be acted on.
        # A leading dot still marks a hidden path (.git, .pytest_cache) rather than an
        # invocation. ~/.claude stays unconditional: a bare harness path is an
        # assumption however it is written.
        # Cost of the trade: a mechanism written in plain prose is missed. The corpus
        # convention is to format them, and a check nobody can act on catches less.
        code=""; rest=$0
        while (match(rest, /`[^`]*`/)) {
          code = code " " substr(rest, RSTART + 1, RLENGTH - 2)
          rest = substr(rest, RSTART + RLENGTH)
        }
        if (match(code, "(^|[^A-Za-z.])(" deny ")([^A-Za-z]|$)") || index($0, "~/.claude"))
          print "CORE-mechanism\t" F "\t" $0
      }
    }
    END{ if (open) print "unclosed-marker\t" F "\t" openid }
  ' "$f" >> "$rec"
done

TAB="$(printf '\t')"
while IFS="$TAB" read -r kind a b; do
  if [ "$kind" = USE ]; then
    printf '%s\n' "$a" >> "$used"
    printf '%s\n' "$inv_ids" | grep -qx "$a" || { printf 'unknown-id: %s\n' "$a" >&2; viol=1; }
  else
    printf '%s: %s: %s\n' "$kind" "$a" "$b" >&2; viol=1
  fi
done < "$rec"

# inventory 1:1 -- every inventory id must be used by some marker
for id in $inv_ids; do
  grep -qx "$id" "$used" || { printf 'unused-inventory-id: %s\n' "$id" >&2; viol=1; }
done

rm -rf "$work"
exit "$viol"
