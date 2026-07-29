#!/bin/sh
# ws-binding.sh -- read-only accessor over WHITTLESPEC.md (the binding record).
#
# Usage: ws-binding.sh get <concept>
#
# Reads ./WHITTLESPEC.md in the current project and prints the bound value for
# <concept> on stdout (exit 0). A binding of "none" prints the literal sentinel
# `none` (the project has no mechanism for that concept; evidence = demo). All
# errors go to stderr with a non-zero exit -- the accessor never guesses a value
# and never silently re-derives one.
#
# POSIX sh on purpose: it runs in the adopter's project at skill-runtime, so it
# must work wherever a POSIX shell exists (macOS, Linux, WSL, Git Bash).
set -u

RECORD="WHITTLESPEC.md"

die() { printf '%s\n' "$1" >&2; exit "${2:-1}"; }

# The seven settled binding concepts (umbrella D3). This is the single source of
# truth for which concept keys are valid; get rejects anything else.
KNOWN_CONCEPTS='verification evidence-profile work-ledger durability current-behaviour-authority discovery-capture'

# Map a concept key to its WHITTLESPEC.md section header (without the "## ").
# Returns non-zero for an unrecognised concept so callers can fail loudly.
header_for() {
  case "$1" in
    verification)                printf '%s' 'Verification' ;;
    evidence-profile)            printf '%s' 'Evidence profile' ;;
    work-ledger)                 printf '%s' 'Work ledger' ;;
    durability)                  printf '%s' 'Durability' ;;
    current-behaviour-authority) printf '%s' 'Current-behaviour authority' ;;
    discovery-capture)           printf '%s' 'Discovery capture' ;;
    *)                           return 1 ;;
  esac
}

# Print the single-line Binding value from a section, or nothing if absent.
extract_binding() {
  awk -v h="## $1" '
    $0 == h                 { insec = 1; next }
    insec && /^## /         { insec = 0 }
    insec && /^Binding:/ {
      sub(/^Binding:[[:space:]]*/, "")
      print
      exit
    }
  ' "$RECORD"
}

cmd_get() {
  concept="${1:-}"
  [ -n "$concept" ] || die "usage: ws-binding.sh get <concept>" 64
  header="$(header_for "$concept")" \
    || die "Unknown concept: $concept (known: $KNOWN_CONCEPTS)" 2
  [ -f "$RECORD" ] || die "No binding record ($RECORD) in this project. Run /ws.0-start setup to create one." 3
  printf '%s\n' "$(extract_binding "$header")"
}

cmd_validate() {
  concept="${1:-}"
  [ -n "$concept" ] || die "usage: ws-binding.sh validate <concept>" 64
  header="$(header_for "$concept")" \
    || die "Unknown concept: $concept (known: $KNOWN_CONCEPTS)" 2
  # Only verification binds a command, so it is the only concept where "is this
  # runnable" has an answer. Asked about a prose binding -- an evidence floor, a
  # routing rule -- this reported a perfectly good record as a missing tool,
  # naming a word from the sentence as the program.
  [ "$concept" = verification ] \
    || die "validate does not apply to $concept: its binding is prose, not a command." 2
  [ -f "$RECORD" ] || die "No binding record ($RECORD) in this project. Run /ws.0-start setup to create one." 3
  value="$(extract_binding "$header")"
  [ "$value" = "none" ] && return 0               # 'none' = valid no-check state (D3); nothing to resolve
  first=${value%% *}                              # program name = first token
  command -v "$first" >/dev/null 2>&1 || die \
    "Verification command not found: $first (from binding '$value'). Fix the tool, or run /ws.0-start setup to reconfigure." 4
  # resolvable -> exit 0, no output
}

# cmd_set <concept> <value> : record the binding, creating WHITTLESPEC.md if
# absent and updating the concept's row in place if it already exists (so a
# reconfigure never leaves a stale duplicate for get to read).
cmd_set() {
  concept="${1:-}"; value="${2:-}"
  { [ -n "$concept" ] && [ -n "$value" ]; } || die "usage: ws-binding.sh set <concept> <value>" 64
  header="$(header_for "$concept")" || die "Unknown concept: $concept (known: $KNOWN_CONCEPTS)" 2
  hdr="## $header"
  if [ ! -f "$RECORD" ]; then
    { printf '%s\n' "$hdr"; printf 'Binding: %s\n' "$value"; } > "$RECORD"
    return 0
  fi
  if ! grep -Fxq "$hdr" "$RECORD"; then
    { printf '\n%s\n' "$hdr"; printf 'Binding: %s\n' "$value"; } >> "$RECORD"
    return 0
  fi
  tmp="$(mktemp)"
  awk -v hdr="$hdr" -v val="$value" '
    $0 == hdr              { print; insec=1; seen=0; next }
    insec && /^## /        { if (!seen) print "Binding: " val; insec=0 }
    insec && /^Binding:/   { print "Binding: " val; seen=1; next }
    { print }
    END { if (insec && !seen) print "Binding: " val }
  ' "$RECORD" > "$tmp" && mv "$tmp" "$RECORD"
}

# The anchor line dropped into CLAUDE.md / AGENTS.md: a POINTER to the binding
# record, never a binding value (embedding a value would recreate the
# system-CLAUDE.md-authority bug D2 forbids). MARKER detects our own prior line.
ANCHOR_MARKER='WhittleSpec bindings:'
ANCHOR_LINE='WhittleSpec bindings: this project'"'"'s SDD/verification bindings live in WHITTLESPEC.md -- load it at session start.'

# cmd_anchor : ensure CLAUDE.md and AGENTS.md each point at WHITTLESPEC.md.
# Creates a file if absent, is idempotent (no duplicate lines), and appends only
# -- pre-existing instructions are preserved.
cmd_anchor() {
  for f in CLAUDE.md AGENTS.md; do
    if [ -f "$f" ] && grep -Fq "$ANCHOR_MARKER" "$f"; then
      continue
    fi
    printf '%s\n' "$ANCHOR_LINE" >> "$f"
  done
}

case "${1:-}" in
  get)      shift; cmd_get "$@" ;;
  validate) shift; cmd_validate "$@" ;;
  set)      shift; cmd_set "$@" ;;
  anchor)   shift; cmd_anchor "$@" ;;
  *)        die "usage: ws-binding.sh <get|validate|set|anchor> [args]" 64 ;;
esac
