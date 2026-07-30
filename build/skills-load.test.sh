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

# 3. Every skill loads exactly the chapters the routing table gives it.
# The table in ws._meta is the record of the mapping; the load lines are what a
# session acts on. If they disagree, doctrine goes missing without a symptom --
# so the disagreement, in either direction, is the failure.
routing="$SKILLS/ws._meta/SKILL.md"
for chapter in shaping executing lifecycle; do
  [ -f "$SKILLS/ws._meta/$chapter.md" ] || bad "routing: chapter $chapter.md missing"
  row="$(grep -F "[\`$chapter.md\`]($chapter.md)" "$routing" || true)"
  [ -n "$row" ] || { bad "routing: no row for $chapter.md"; continue; }
  listed=" $(printf '%s' "$row" | grep -oE '`ws\.[a-z0-9.-]+`' | tr -d '`' | tr '\n' ' ')"
  for d in "$SKILLS"/ws.*; do
    name="$(basename "$d")"
    case "$name" in *._meta|ws.tdd.*|ws.bdd.*) continue ;; esac
    # Only the load line counts. A skill may POINT at a chapter it does not load
    # -- that is what a pointer is for -- so scanning the whole file would read
    # navigation as loading.
    loadline="$(grep -m1 '^Load shared context:' "$d/SKILL.md" || true)"
    loads=no
    case "$loadline" in *"ws._meta/$chapter.md"*) loads=yes ;; esac
    case "$listed" in
      *" $name "*) [ "$loads" = yes ] && ok \
          || bad "routing: $name is listed under $chapter.md but does not load it" ;;
      *)           [ "$loads" = no ]  && ok \
          || bad "routing: $name loads $chapter.md but the table omits it" ;;
    esac
  done
done

# 4. Every IF-CONFIGURED adapter defines its doctrine exactly once.
# A consuming skill may carry its own region for the same adapter -- that is a
# procedure reading the binding, not a second definition, and it shares the id
# because an id names a mechanism. Two definitions among the doctrine files would
# let persistence or verification behaviour diverge with nothing to catch it.
doctrine="$SKILLS/ws._meta/SKILL.md $SKILLS/ws._meta/shaping.md"
doctrine="$doctrine $SKILLS/ws._meta/executing.md $SKILLS/ws._meta/lifecycle.md"
adapter_ids="$(grep -roh -- '<!-- WS:IF-CONFIGURED [a-z0-9_-]* -->' "$SKILLS" \
  | sed -E 's/.* ([a-z0-9_-]+) -->/\1/' | sort -u)"
[ -n "$adapter_ids" ] || bad "adapter: no IF-CONFIGURED markers found at all"
for id in $adapter_ids; do
  # shellcheck disable=SC2086
  n=$(grep -l -- "<!-- WS:IF-CONFIGURED $id -->" $doctrine 2>/dev/null | wc -l | tr -d ' ')
  case "$n" in
    1) ok ;;
    0) bad "adapter: $id defines no doctrine in the spine or its chapters" ;;
    *) bad "adapter: $id defines doctrine in $n of the doctrine files, must be exactly one" ;;
  esac
done

printf -- '----\n%d pass, %d fail\n' "$_pass" "$_fail"
[ "$_fail" -eq 0 ]
