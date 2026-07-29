#!/usr/bin/env bash
# Load-all check (Slice 1, Task 2): every ws.* skill resolves its shared context
# as a SIBLING in the same skills directory, with no absolute or clone-named meta
# path -- verified in place and under a renamed clone. (Structural resolution; the
# LLM actually obeying the doctrine is closed by live exercise, not a fixture.)
set -u

here="$(cd "$(dirname "$0")" && pwd)"
SKILLS="$here/../skills"
_pass=0 _fail=0
ok()  { _pass=$((_pass + 1)); }
bad() { printf 'FAIL  %s\n' "$1"; _fail=$((_fail + 1)); }

# Which meta a skill loads: ws.tdd.*/ws.bdd.* -> ws.tdd._meta ; every other ws.* -> ws._meta.
meta_for() {
  case "$1" in
    ws.tdd.*|ws.bdd.*) printf 'ws.tdd._meta' ;;
    ws.*)              printf 'ws._meta' ;;
    *)           printf '' ;;
  esac
}

# Check every consumer skill in a skills tree.
check_tree() {
  tree="$1"; label="$2"
  for d in "$tree"/ws.*; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"; f="$d/SKILL.md"
    [ -f "$f" ] || { bad "[$label] $name: no SKILL.md"; continue; }
    # No absolute or clone-named meta path may survive (AC3).
    if grep -qE 'WhittleSpec/skills/[^ ]*_meta|~/\.claude/skills/.*_meta' "$f"; then
      bad "[$label] $name: retains an absolute/clone-named meta path"; continue
    fi
    # The meta skills are the referent, not consumers -- they need no sibling line.
    case "$name" in *._meta) ok; continue ;; esac
    meta="$(meta_for "$name")"
    grep -Fq "$meta/SKILL.md" "$f" \
      || { bad "[$label] $name: no sibling reference to $meta/SKILL.md"; continue; }
    [ -f "$tree/$meta/SKILL.md" ] \
      || { bad "[$label] $name: sibling $meta/SKILL.md not resolvable in tree"; continue; }
    ok
  done
}

# 1. in place (the real installed suite)
check_tree "$SKILLS" "in-place"

# 2. under a clone that is not named WhittleSpec -- the resolution the sibling
# rule has to survive. A third copy under a differently-named parent was dropped:
# check_tree reads file contents only, so it could not fail where this one passes,
# and it claimed to exercise CLAUDE_CONFIG_DIR without ever setting it.
b1="$(mktemp -d)"
cp -rP "$SKILLS" "$b1/RenamedClone_skills"
check_tree "$b1/RenamedClone_skills" "renamed-clone"; rm -rf "$b1"

printf -- '----\n%d pass, %d fail\n' "$_pass" "$_fail"
[ "$_fail" -eq 0 ]
