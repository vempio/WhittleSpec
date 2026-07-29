#!/bin/sh
# ws-install.sh -- place WhittleSpec's skills in a skills directory.
#
# Usage: ws-install.sh <skills-dir> <clone-dir> [personal-dir]
#
# Symlinks every skills/ws.* directory holding a SKILL.md into <skills-dir>, and
# every subdirectory of [personal-dir] that holds one. Links a previous run of
# this script placed are removed first, so a skill dropped upstream does not
# linger; anything else holding the name is left alone.
#
# Exits non-zero if any name the install was meant to place is missing at the
# end, whatever the reason -- a name held by something foreign, a link that could
# not be written, an old link that could not be removed. The skills that did get
# placed work; the closing summary names the ones that did not.
#
# One implementation, two targets: the global and per-project installs differ
# only in where they point, so they must not differ in how they behave.
set -u

skills_dir="${1:?usage: ws-install.sh <skills-dir> <clone-dir> [personal-dir]}"
clone_dir="${2:?usage: ws-install.sh <skills-dir> <clone-dir> [personal-dir]}"
personal_dir="${3:-}"

# Nothing is removed until the clone is confirmed to be one. Every delete below
# is scoped by a path prefix, so an empty or relative prefix would widen the
# match from "links into this clone" to "every link" -- and the adopter's own
# skills are what would go. Refuse rather than proceed on a guess.
[ -f "$clone_dir/skills/ws._meta/SKILL.md" ] || {
	echo "ERROR: not a WhittleSpec clone: $clone_dir" >&2
	echo "       expected skills/ws._meta/SKILL.md under it; nothing was changed." >&2
	exit 1
}
clone_real="$(cd "$clone_dir" && pwd -P)"
case "$clone_real" in
	/*) ;;
	*) echo "ERROR: cannot resolve $clone_dir; nothing was changed." >&2; exit 1;;
esac

personal_real=/nonexistent
if [ -n "$personal_dir" ] && [ -d "$personal_dir" ]; then
	personal_real="$(cd "$personal_dir" && pwd -P)"
	case "$personal_real" in /*) ;; *) personal_real=/nonexistent;; esac
fi

mkdir -p "$skills_dir"

fail=0
placed=0
missing=''

# Remove only what this install owns: links resolving into the clone or the
# overlay. The scan covers every entry, not just the ws.* ones, because that is
# the namespace this script places into -- the overlay carries whatever names the
# adopter gave their own skills. A cleanup narrower than the placement leaves a
# link to a renamed or deleted overlay skill dangling for good. Ownership is read
# off the link target, so a foreign entry of any name is never a candidate.
# A dangling link still resolves by name, which is why this reads the link and
# normalises it by hand rather than using a realpath flag no BSD userland has.
echo "Removing the links an earlier run of this install placed..."
for link in "$skills_dir"/*; do
	[ -L "$link" ] || continue
	tgt="$(readlink "$link")"
	case "$tgt" in /*) ;; *) tgt="$(dirname "$link")/$tgt";; esac
	case "$tgt" in
		"$clone_real"/*|"$personal_real"/*)
			rm "$link" || { echo "  FAILED to remove: $(basename "$link")"; fail=1; };;
	esac
done

# place <source-dir> <own|overlay>
place() {
	for d in "$1"/*/; do
		[ -f "$d/SKILL.md" ] || continue
		name="$(basename "$d")"
		# The shipped set is the ws. names and nothing else. That is what INSTALL.md
		# promises an install places, and what its "establish what is ours" step
		# turns on; installing under a name the adopter was never told to expect
		# claims part of their namespace (INV-2). An unprefixed directory in the
		# download is a defect in the download, so it is reported, not placed.
		if [ "$2" = own ]; then
			case "$name" in
				ws.*) ;;
				*) echo "  Skipped: $name (a shipped skill must be named ws.*)"
				   missing="$missing $name"; fail=1; continue;;
			esac
		fi
		target="$skills_dir/$name"
		if [ -e "$target" ] || [ -L "$target" ]; then
			if [ "$2" = own ]; then
				echo "  Conflict: $name exists and is not WhittleSpec-owned -- left as-is (remove it to install WhittleSpec's)"
			else
				echo "  Kept existing: $name (already placed -- not overwritten)"
			fi
			missing="$missing $name"; fail=1
		elif ln -s "$(cd "$d" && pwd -P)" "$target"; then
			placed=$((placed + 1))
			if [ "$2" = own ]; then echo "  Linked: $name"; else echo "  Linked (personal): $name"; fi
		else
			echo "  FAILED to link: $name"; missing="$missing $name"; fail=1
		fi
	done
}

place "$clone_dir/skills" own
[ "$personal_real" = /nonexistent ] || place "$personal_real" overlay

echo ""
if [ "$fail" -eq 0 ]; then
	echo "Installed $placed skills into $skills_dir."
	exit 0
fi

# What remains usable, said plainly: a partial install is worth more than the
# operator assuming none of it took.
echo "INCOMPLETE: installed $placed skills into $skills_dir, and they work."
[ -z "$missing" ] || echo "Not installed:$missing"
echo "Clear what is reported above and run the install again."
exit 1
