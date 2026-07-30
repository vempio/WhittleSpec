#!/bin/sh
# ws-check-refs.sh -- flag dangling command, link and section references.
#
# POSIX sh + awk only: no dependency the repo's Makefile does not already
# require (matches the pure-shell idiom of `ws-verify-structure`).
#
# Three reference classes are checked across a configured set of markdown files:
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
# 3. Section references (`§ Heading`). The target file is the nearest backticked
#    skill-or-path token to the LEFT of the sign on the same line (`ws._meta` ->
#    that skill's SKILL.md; `ws._meta/binding-setup.md` -> that file, resolved
#    beside the linking file and then under the skills dir); with no such token
#    the reference points into the linking file itself. The reference text ends
#    at the first sub-navigation arrow (`>`, `→`) or sentence punctuation, and
#    must match a heading in the target -- heading-is-prefix-of-reference (the
#    reference runs on into prose) or reference-is-prefix-of-heading (the corpus
#    abbreviates long headings) -- case-insensitively, with code and emphasis
#    marks stripped.
#
#    Navigation (`§ Parent → Child`) is rejected rather than half-checked: it
#    validates the parent only, so renaming the child leaves every reference to
#    it stale behind a green build. Point at the child heading directly, which
#    is then checked like any other. An arrow AFTER the reference ends (past a
#    comma, semicolon, colon or bracket) is ordinary prose and is ignored.
#
#    Recall bounds (stated, not silent): a
#    reference written without the section sign is not detected; the corpus
#    writes `§`. The loose prefix match will accept a shorter heading that
#    happens to prefix a longer one -- deliberate, so abbreviation stays legal.
#    Detection is line-scoped, so a qualifier that wraps to the previous line
#    reads as unqualified: keep `file` and its `§` on one line.
#
# Usage: ws-check-refs.sh [ROOT ...] [--skills-dir DIR] [--ignore FILE]
#   ROOT          files or directories to scan. The default is every shipped
#                 markdown file, which is the same set the layer validator covers
#                 (see build/Makefile.common) -- the two gates read the same
#                 corpus on purpose. Scoping this to `skills` alone let a stale
#                 section pointer sit in `context/constraints.md` through a
#                 chapter split with the build green.
#                 `build/` is deliberately excluded: its fixtures plant dangling
#                 references as test data.
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
[ -n "$roots" ] || roots="skills examples docs context README.md INSTALL.md CONTRIBUTING.md WHITTLESPEC.md"

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

# section_resolves FILE REF -- exit 0 when some heading in FILE matches REF.
section_resolves() {
	awk -v ref="$2" '
	function norm(s) {
		gsub(/[`*"]/, "", s); s = tolower(s)
		gsub(/^[ \t]+|[ \t]+$/, "", s); gsub(/[ \t]+/, " ", s)
		return s
	}
	function matches(h, r) {
		return (h != "" && (h == r || index(r, h) == 1 || index(h, r) == 1))
	}
	BEGIN { r = norm(ref); if (r == "") found = 1 }
	found { exit }
	/^#+[ \t]/ {
		h = $0; sub(/^#+[ \t]*/, "", h); h = norm(h)
		o = h; sub(/^[0-9]+[a-z]?\. */, "", o)   # headings carry ordinals; references drop them
		if (matches(h, r) || matches(o, r)) { found = 1; exit }
	}
	END { exit(found ? 0 : 1) }
	' "$1"
}

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
		# --- section references: "§ Heading", optionally file-qualified ---
		nsec = split($0, sec, "§")
		ctx = sec[1]
		tgt = ""                      # inheritance is line-scoped, never across lines
		for (i = 2; i <= nsec; i++) {
			ref = sec[i]
			sub(/\*\*.*$/, "", ref)       # a bold-delimited reference ends at the marks
			sub(/[,;:()].*$/, "", ref)    # reference ends where the sentence resumes
			gsub(/^[ \t]+|[ \t]+$/, "", ref)
			# Navigation ("§ Parent -> Child") validates the parent only, so a renamed
			# child goes stale behind a green build. Point at the child directly.
			nav = (index(ref, ">") > 0 || index(ref, "\342\206\222") > 0)
			sub(/>.*$/, "", ref); sub(/→.*$/, "", ref)
			gsub(/[ \t-]+$/, "", ref)
			# A numbered subsection ("§1a") names its ordinal only; what follows is
			# prose, and the period in such a heading defeats the prefix match.
			if (match(ref, /^[0-9]+[a-z]?/)) ref = substr(ref, RSTART, RLENGTH)
			# The target is named IMMEDIATELY before the sign; a skill or document
			# mentioned earlier in the sentence is prose, not a reference target.
			# Unnamed, it inherits the previous reference on the line ("`x` § A
			# and § B"), and failing that points into the linking file itself.
			if (match(ctx, /`[^`]+`[ \t]*$/)) {
				c = substr(ctx, RSTART, RLENGTH)
				gsub(/^`|`[ \t]*$/, "", c)
				if (c ~ /^[a-z][a-z0-9]*(\.[a-z0-9_-]+)+$/ || c ~ /\.md$/) tgt = c
			}
			if (ref != "") printf "%s\t%d\t%s\t%s\n", (nav ? "section-nav" : "section"), FNR, ref, tgt
			ctx = ctx "§" sec[i]
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
			section-nav)
				printf '%s:%s -> section: %s (navigates, point at the heading directly)\n' \
					"$file" "$lineno" "$ref" >> "$tmp"
				;;
			section)
				case "$name" in
					"")       target="$file" ;;
					*/*|*.md) target="$dir/$name"
					          [ -f "$target" ] || target="$SKILLS_DIR/$name" ;;
					*)        target="$SKILLS_DIR/$name/SKILL.md" ;;
				esac
				if [ ! -f "$target" ]; then
					printf '%s:%s -> section: %s (no such target: %s)\n' \
						"$file" "$lineno" "$ref" "$name" >> "$tmp"
				elif ! section_resolves "$target" "$ref"; then
					printf '%s:%s -> section: %s (no such heading in %s)\n' \
						"$file" "$lineno" "$ref" "${name:-this file}" >> "$tmp"
				fi
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
