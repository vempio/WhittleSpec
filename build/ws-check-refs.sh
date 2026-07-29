#!/bin/sh
# ws-check-refs.sh -- flag dangling slash-command / relative-link references.
#
# POSIX sh + awk only: no dependency the repo's Makefile does not already
# require (matches the pure-shell idiom of `ws-verify-structure`).
#
# Two reference classes are checked across a configured set of markdown files:
#
# 1. Slash-command references (e.g. `/ws.4-run`, `/ws.tdd.red`). Detected as
#    an inline-code span (backtick-delimited) whose entire content is a
#    `/command`-shaped token: leading slash, lowercase-letter first segment,
#    dot-separated segments, no internal slash, no file extension. This matches
#    the corpus convention (commands are always written in backticks) while
#    precisely excluding the look-alikes a loose `/word` scan mis-flags:
#    filesystem paths (`/etc/passwd`, `specs/<f>/seed.md`), HTML closing tags
#    (`</summary>`), and prose. Every such command must resolve to a skill
#    directory (`<skills-dir>/<name>/` with SKILL.md). No external allowlist: a
#    command naming no skill in the tree is dangling by definition, so the check
#    adapts to whatever tree it runs on.
#
#    Recall bound (stated, not silent): a command written WITHOUT backticks is
#    not detected -- an unbackticked `/x` is lexically indistinguishable from a
#    path or prose, and detecting it would reintroduce the false positives a
#    gate must avoid. The corpus writes every command in backticks.
#
# 2. Relative markdown links to `.md` files (`](target.md)`, optional #anchor).
#    Each must resolve to an existing file relative to the linking file's dir.
#    Absolute URLs (`http://`, `https://`, `mailto:`) are skipped.
#
# Usage: ws-check-refs.sh [ROOT ...] [--skills-dir DIR] [--ignore FILE]
#   ROOT          files or directories to scan (default: skills examples README.md INSTALL.md)
#   --skills-dir  directory whose subdirs define valid skill names (default: skills)
#   --ignore      list of command-shaped tokens that are documentation examples,
#                 not real invocations, and must be skipped (default:
#                 ws-check-refs-ignore.txt beside this script). See that file's header.
#
# Exit status is nonzero if any dangling reference is found. Paths with spaces
# are not supported (the repo has none); this keeps the word-split loops simple.

set -eu

SCRIPT_DIR=$(dirname "$0")
SKILLS_DIR="skills"
IGNORE_FILE="$SCRIPT_DIR/ws-check-refs-ignore.txt"
roots=""
while [ $# -gt 0 ]; do
	case "$1" in
		--skills-dir) SKILLS_DIR="$2"; shift 2 ;;
		--skills-dir=*) SKILLS_DIR="${1#*=}"; shift ;;
		--ignore) IGNORE_FILE="$2"; shift 2 ;;
		--ignore=*) IGNORE_FILE="${1#*=}"; shift ;;
		*) roots="$roots $1"; shift ;;
	esac
done
[ -n "$roots" ] || roots="skills examples README.md INSTALL.md"

# Ignore-list = |-delimited set of documentation-example tokens to skip.
IGNORESET="|"
if [ -f "$IGNORE_FILE" ]; then
	while IFS= read -r ln || [ -n "$ln" ]; do
		ln=${ln%%#*}                                  # strip comment
		ln=$(printf '%s' "$ln" | tr -d '[:space:]')   # trim whitespace
		[ -n "$ln" ] || continue
		IGNORESET="$IGNORESET$ln|"
	done < "$IGNORE_FILE"
fi

# Valid skill names = immediate subdirs of SKILLS_DIR containing SKILL.md,
# stored as a :-delimited string for O(1)-ish membership tests.
SKILLSET=":"
for d in "$SKILLS_DIR"/*/; do
	[ -f "$d/SKILL.md" ] || continue
	name=$(basename "$d")
	SKILLSET="$SKILLSET$name:"
done

# Collect markdown files from roots, deterministically ordered.
files=""
for root in $roots; do
	if [ -f "$root" ]; then
		case "$root" in *.md) files="$files $root" ;; esac
	elif [ -d "$root" ]; then
		files="$files $(find "$root" -name '*.md' | sort)"
	fi
done

: "${TMPDIR:=/tmp}"
tmp="$TMPDIR/ws-check-refs.$$"
trap 'rm -f "$tmp"' EXIT INT TERM
: > "$tmp"

TAB=$(printf '\t')

for file in $files; do
	dir=$(dirname "$file")
	awk '
	{
		# --- command references: inline-code spans of command shape ---
		s = $0
		while (match(s, /`[^`]+`/)) {
			span = substr(s, RSTART, RLENGTH)
			content = substr(span, 2, length(span) - 2)
			gsub(/^[ \t]+|[ \t]+$/, "", content)
			if (content ~ /^\/[a-z][a-z0-9]*(\.[a-z0-9_-]+)*$/ &&
			    content !~ /\.(md|json|py|txt|sh|yaml|yml|toml|cfg|ini|lock|html|css|js)$/) {
				name = substr(content, 2)
				printf "command\t%d\t%s\t%s\n", FNR, content, name
			}
			s = substr(s, RSTART + RLENGTH)
		}
		# --- relative markdown links to .md targets ---
		t = $0
		while (match(t, /\]\([^)]+\)/)) {
			inner = substr(t, RSTART + 2, RLENGTH - 3)
			gsub(/^[ \t]+|[ \t]+$/, "", inner)
			h = index(inner, "#")
			if (h > 0) inner = substr(inner, 1, h - 1)
			if (inner ~ /^[a-z][a-z0-9+.-]*:\/\// || inner ~ /^mailto:/) {
				# absolute URL scheme -- skip
			} else if (inner ~ /\.md$/) {
				printf "link\t%d\t%s\t\n", FNR, inner
			}
			t = substr(t, RSTART + RLENGTH)
		}
	}
	' "$file" | while IFS="$TAB" read -r kind lineno ref name; do
		case "$kind" in
			command)
				case "$IGNORESET" in
					*"|$ref|"*) continue ;;  # documentation example -- skip
				esac
				case "$SKILLSET" in
					*":$name:"*) ;;  # resolves to a real skill
					*) printf '%s:%s -> command: %s\n' "$file" "$lineno" "$ref" >> "$tmp" ;;
				esac
				;;
			link)
				[ -f "$dir/$ref" ] || \
					printf '%s:%s -> link: %s\n' "$file" "$lineno" "$ref" >> "$tmp"
				;;
		esac
	done
done

if [ -s "$tmp" ]; then
	cat "$tmp"
	count=$(wc -l < "$tmp" | tr -d ' ')
	printf '\n%s dangling reference(s) found.\n' "$count" >&2
	exit 1
fi
echo "No dangling references."
