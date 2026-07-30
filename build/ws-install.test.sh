#!/usr/bin/env bash
# Hermetic self-test for the installer targets.
#
# Every case installs into a temporary skills root -- never the operator's real
# one. That is the whole point: an installer test that writes to the skills
# directory in daily use cannot be run by the person most likely to need it.
#
# Unit under test: build/ws-install.sh, through the ws-install-global and
# ws-install-skills targets that both call it.
set -u

_cur='' _pass=0 _fail=0
pass() { printf 'PASS  %-46s\n' "$_cur"; _pass=$((_pass + 1)); }
fail() { printf 'FAIL  %-46s %s\n' "$_cur" "$1"; _fail=$((_fail + 1)); }

here="$(cd "$(dirname "$0")" && pwd)"
root="$here/.."
# Each case names the directories it installs into, and nothing outside it may
# say otherwise. These variables are exported, so a run under ws-test -- or under
# an operator who exports one in their shell -- would otherwise hand an install
# meant for a temporary root the operator's real skills directory instead. Unset
# rather than overridden: a case that names none of them must see the built-in
# default, which is the thing one of the cases below is checking.
mk() { ( unset WS_SKILLS_DIR WS_PROJECT_SKILLS_DIR WS_PERSONAL_DIR WHITTLESPEC_DIR CLAUDE_CONFIG_DIR
         make -f "$here/Makefile.common" "$@" ) >/dev/null 2>&1; }
mk_out() { ( unset WS_SKILLS_DIR WS_PROJECT_SKILLS_DIR WS_PERSONAL_DIR WHITTLESPEC_DIR CLAUDE_CONFIG_DIR
             make -f "$here/Makefile.common" "$@" ) 2>&1; }
nlinks() { find "$1" -maxdepth 1 -type l -name 'ws.*' 2>/dev/null | wc -l | tr -d ' '; }
expected() { find "$root/skills" -mindepth 1 -maxdepth 1 -type d -name 'ws.*' \
               -exec test -f '{}/SKILL.md' ';' -print | wc -l | tr -d ' '; }

test_fresh_install_links_every_skill() { _cur=$FUNCNAME
  d=$(mktemp -d); mk ws-install-global WS_SKILLS_DIR="$d/skills"
  got=$(nlinks "$d/skills"); want=$(expected); rm -rf "$d"
  [ "$got" = "$want" ] || { fail "linked $got, expected $want"; return; }; pass
}

# Anchored to the expected count, not just to itself. Comparing the two runs alone
# passes on an installer that places NOTHING (0 == 0) or a consistent subset --
# verified by mutation: inverting the SKILL.md guard kept this case green.
test_reinstall_is_idempotent() { _cur=$FUNCNAME
  d=$(mktemp -d); mk ws-install-global WS_SKILLS_DIR="$d/skills"
  first=$(nlinks "$d/skills"); mk ws-install-global WS_SKILLS_DIR="$d/skills"
  second=$(nlinks "$d/skills"); want=$(expected); rm -rf "$d"
  [ "$first" = "$want" ] || { fail "first install linked $first, expected $want"; return; }
  [ "$first" = "$second" ] || { fail "$first then $second"; return; }; pass
}

test_foreign_skill_of_same_name_is_preserved() { _cur=$FUNCNAME
  d=$(mktemp -d); mkdir -p "$d/skills" "$d/foreign/ws.status"
  printf 'not ours\n' > "$d/foreign/ws.status/SKILL.md"
  ln -s "$d/foreign/ws.status" "$d/skills/ws.status"
  mk ws-install-global WS_SKILLS_DIR="$d/skills"
  tgt=$(readlink "$d/skills/ws.status"); rm -rf "$d"
  case "$tgt" in *foreign*) pass ;; *) fail "clobbered foreign skill: $tgt";; esac
}

# Uses a fixture overlay rather than the operator's real one, so the case runs
# everywhere -- including CI, where personal/ is gitignored and absent. Skipping
# when the overlay is missing would report neither pass nor fail and hide the gap.
test_personal_overlay_is_picked_up() { _cur=$FUNCNAME
  d=$(mktemp -d); mkdir -p "$d/overlay/my.helper"
  printf -- '---\nname: my.helper\n---\nfixture overlay skill\n' > "$d/overlay/my.helper/SKILL.md"
  mk ws-install-global WS_SKILLS_DIR="$d/skills" WS_PERSONAL_DIR="$d/overlay"
  got=$([ -L "$d/skills/my.helper" ] && echo yes || echo no); rm -rf "$d"
  [ "$got" = yes ] || { fail "overlay skill not linked"; return; }; pass
}

test_path_containing_spaces() { _cur=$FUNCNAME
  base=$(mktemp -d); d="$base/my config"; mkdir -p "$d"
  mk ws-install-global WS_SKILLS_DIR="$d/skills"
  got=$(nlinks "$d/skills"); want=$(expected); rm -rf "$base"
  [ "$got" = "$want" ] || { fail "linked $got, expected $want"; return; }; pass
}

test_claude_config_dir_is_the_default_source() { _cur=$FUNCNAME
  d=$(mktemp -d); mk ws-install-global CLAUDE_CONFIG_DIR="$d"
  got=$(nlinks "$d/skills"); want=$(expected); rm -rf "$d"
  [ "$got" = "$want" ] || { fail "default source ignored: $got of $want"; return; }; pass
}

test_per_project_target_honours_its_override() { _cur=$FUNCNAME
  d=$(mktemp -d); mk ws-install-skills WS_PROJECT_SKILLS_DIR="$d/proj"
  got=$(nlinks "$d/proj"); want=$(expected); rm -rf "$d"
  [ "$got" = "$want" ] || { fail "linked $got, expected $want"; return; }; pass
}

# The classification path must resolve a link whose target no longer exists --
# the property `realpath -m` used to provide before it was replaced with readlink
# for portability. A dangling link into the clone is ours and must be cleaned up.
test_dangling_link_into_the_clone_is_removed() { _cur=$FUNCNAME
  d=$(mktemp -d); mkdir -p "$d/skills"
  ln -s "$(cd "$root" && pwd -P)/skills/ws.no-such-skill" "$d/skills/ws.no-such-skill"
  mk ws-install-global WS_SKILLS_DIR="$d/skills"
  still=$([ -L "$d/skills/ws.no-such-skill" ] && echo yes || echo no); rm -rf "$d"
  [ "$still" = no ] || { fail "dangling link into the clone was kept as foreign"; return; }; pass
}

# A bad clone path used to empty the prefix that scopes the delete, widening it
# from "links into this clone" to every link -- observed removing a foreign one
# and exiting 0.
test_bad_clone_path_removes_nothing() { _cur=$FUNCNAME
  d=$(mktemp -d); mkdir -p "$d/skills" "$d/theirs"
  ln -s "$d/theirs" "$d/skills/ws.theirs"
  sh "$here/ws-install.sh" "$d/skills" "$d/no-such-clone" >/dev/null 2>&1; rc=$?
  kept=$([ -L "$d/skills/ws.theirs" ] && echo yes || echo no); rm -rf "$d"
  [ "$rc" -ne 0 ] || { fail "bad clone path reported success"; return; }
  [ "$kept" = yes ] || { fail "removed a foreign link when the clone path was bad"; return; }; pass
}

# A link failure must be visible and must stop the target, not print Done at exit 0.
test_link_failure_is_reported_and_exits_nonzero() { _cur=$FUNCNAME
  d=$(mktemp -d); mkdir -p "$d/skills"; chmod a-w "$d/skills"
  if [ -w "$d/skills" ]; then chmod u+w "$d/skills"; rm -rf "$d"
    fail "skills dir still writable -- running as root?"; return; fi
  out=$(mk_out ws-install-global WS_SKILLS_DIR="$d/skills"); rc=$?
  chmod u+w "$d/skills"; rm -rf "$d"
  [ "$rc" -ne 0 ] || { fail "unwritable target reported success"; return; }
  case "$out" in *"FAILED to link"*) pass ;; *) fail "failure not reported in output";; esac
}

# A path is data, not shell syntax. The Make targets used to splice the variables
# into the recipe text, where the shell then parsed whatever the value contained:
# a directory named with a backtick ran the command inside it. The marker here is
# a substitution that would rewrite the path, so the tell is where the skills
# landed -- and the quote in the name would break a recipe that reassembled it.
test_skills_dir_with_shell_metacharacters_is_not_executed() { _cur=$FUNCNAME
  base=$(mktemp -d); d="$base/"'it'"'"'s `echo INJECTED` dir'; mkdir -p "$d"
  mk ws-install-global WS_SKILLS_DIR="$d/skills"
  got=$(nlinks "$d/skills"); want=$(expected)
  ran=$([ -e "$base/it's INJECTED dir" ] && echo yes || echo no); rm -rf "$base"
  [ "$ran" = no ] || { fail "the path was executed, not used"; return; }
  [ "$got" = "$want" ] || { fail "linked $got, expected $want"; return; }; pass
}

# The same for the other two paths a recipe interpolates: the clone it installs
# from and the overlay it picks up. The clone is reached through a symlink so the
# case stays cheap -- no second copy of the tree.
test_clone_and_overlay_paths_with_shell_metacharacters_are_not_executed() { _cur=$FUNCNAME
  base=$(mktemp -d); clone="$base/"'clone `echo INJECTED`'; ov="$base/"'ov `echo INJECTED`'
  ln -s "$(cd "$root" && pwd -P)" "$clone"; mkdir -p "$ov/my.helper"
  printf -- '---\nname: my.helper\n---\nfixture overlay skill\n' > "$ov/my.helper/SKILL.md"
  mk ws-install-global WS_SKILLS_DIR="$base/skills" WHITTLESPEC_DIR="$clone" WS_PERSONAL_DIR="$ov"
  got=$(nlinks "$base/skills"); want=$(expected)
  overlay=$([ -L "$base/skills/my.helper" ] && echo yes || echo no)
  ran=$([ -e "$base/clone INJECTED" ] || [ -e "$base/ov INJECTED" ] && echo yes || echo no)
  rm -rf "$base"
  [ "$ran" = no ] || { fail "a path was executed, not used"; return; }
  [ "$got" = "$want" ] || { fail "linked $got of $want from the clone"; return; }
  [ "$overlay" = yes ] || { fail "overlay under such a path was not picked up"; return; }; pass
}

# A name WhittleSpec ships that something else already holds means that skill is
# not installed. Reporting it and exiting 0 told the Make target to print "Done.
# WhittleSpec skills now available" over a suite missing its shared context.
test_conflict_on_a_shipped_name_exits_nonzero() { _cur=$FUNCNAME
  d=$(mktemp -d); mkdir -p "$d/skills/ws._meta"
  printf 'not ours\n' > "$d/skills/ws._meta/SKILL.md"
  out=$(mk_out ws-install-global WS_SKILLS_DIR="$d/skills"); rc=$?
  got=$(nlinks "$d/skills"); want=$(( $(expected) - 1 )); rm -rf "$d"
  [ "$rc" -ne 0 ] || { fail "a blocked shipped skill reported success"; return; }
  [ "$got" = "$want" ] || { fail "linked $got, expected $want alongside the conflict"; return; }
  case "$out" in *Conflict*) pass ;; *) fail "conflict not reported in output";; esac
}

# A cleanup that cannot delete leaves the previous release's links in place, so
# the install is stale rather than incomplete -- worse to report as success.
test_failed_cleanup_is_reported_and_exits_nonzero() { _cur=$FUNCNAME
  d=$(mktemp -d); mkdir -p "$d/skills"
  ln -s "$(cd "$root" && pwd -P)/skills/ws.status" "$d/skills/ws.status"
  chmod a-w "$d/skills"
  if [ -w "$d/skills" ]; then chmod u+w "$d/skills"; rm -rf "$d"
    fail "skills dir still writable -- running as root?"; return; fi
  out=$(sh "$here/ws-install.sh" "$d/skills" "$root" 2>&1); rc=$?
  chmod u+w "$d/skills"; rm -rf "$d"
  [ "$rc" -ne 0 ] || { fail "unremovable old link reported success"; return; }
  case "$out" in *"FAILED to remove"*) pass ;; *) fail "removal failure not reported";; esac
}

# Cleanup has to cover the namespace placement covers, not just ws.*: an overlay
# skill carries whatever name the adopter gave it, and once the overlay drops it
# the link it left behind dangles forever.
test_retired_overlay_skill_is_unlinked() { _cur=$FUNCNAME
  d=$(mktemp -d); mkdir -p "$d/overlay/my.helper"
  printf -- '---\nname: my.helper\n---\nfixture overlay skill\n' > "$d/overlay/my.helper/SKILL.md"
  mk ws-install-global WS_SKILLS_DIR="$d/skills" WS_PERSONAL_DIR="$d/overlay"
  rm -rf "$d/overlay/my.helper"
  mk ws-install-global WS_SKILLS_DIR="$d/skills" WS_PERSONAL_DIR="$d/overlay"
  still=$([ -L "$d/skills/my.helper" ] && echo yes || echo no); rm -rf "$d"
  [ "$still" = no ] || { fail "link to a dropped overlay skill was left dangling"; return; }; pass
}

# The widened cleanup must still classify by link target, not by name: an entry
# pointing anywhere else is the adopter's whatever it is called.
test_foreign_link_outside_the_ws_namespace_is_kept() { _cur=$FUNCNAME
  d=$(mktemp -d); mkdir -p "$d/skills" "$d/theirs/helper"
  printf 'not ours\n' > "$d/theirs/helper/SKILL.md"
  ln -s "$d/theirs/helper" "$d/skills/helper"
  mk ws-install-global WS_SKILLS_DIR="$d/skills"
  kept=$([ -L "$d/skills/helper" ] && echo yes || echo no); rm -rf "$d"
  [ "$kept" = yes ] || { fail "removed a foreign link that is not in the ws namespace"; return; }; pass
}

# INSTALL.md tells adopters an install places ws. names and that anything else in
# their skills directory stays theirs. A shipped directory outside that namespace
# would claim a name they were never told to expect (INV-2), so it is a defect in
# the download and reported as one rather than installed.
test_unprefixed_shipped_skill_is_not_installed() { _cur=$FUNCNAME
  d=$(mktemp -d); c="$d/clone"; mkdir -p "$c/skills/ws._meta" "$c/skills/notws"
  printf -- '---\nname: ws._meta\n---\nfixture\n' > "$c/skills/ws._meta/SKILL.md"
  printf -- '---\nname: notws\n---\nfixture\n' > "$c/skills/notws/SKILL.md"
  out=$(sh "$here/ws-install.sh" "$d/skills" "$c" 2>&1); rc=$?
  meta=$([ -L "$d/skills/ws._meta" ] && echo yes || echo no)
  stray=$([ -e "$d/skills/notws" ] && echo yes || echo no); rm -rf "$d"
  [ "$stray" = no ] || { fail "installed a source directory outside the ws namespace"; return; }
  [ "$meta" = yes ] || { fail "the ws. skill beside it was not installed"; return; }
  [ "$rc" -ne 0 ] || { fail "a malformed download reported success"; return; }
  case "$out" in *Skipped*) pass ;; *) fail "the skipped directory was not reported";; esac
}

for t in $(declare -F | awk '{print $3}' | grep '^test_' | sort); do "$t"; done
printf -- '----\n%d pass, %d fail\n' "$_pass" "$_fail"
[ "$_fail" -eq 0 ]
