#!/bin/bash
# Runs gdd checks, so whether something is done is decided by commands, not by the AI.
#   gdd-check.sh <gdd-dir> [--at <dir>]         progress toward the goal: each check in goal.md, and open uncertainties
#   gdd-check.sh <gdd-dir> <slug> [--at <dir>]  a sub-goal's "Done when" checks and the gate
# Checks are the "Check:" lines under each [id] item: a `command` runs here (exit 0 = met); "observe:" is left
# to the subgoal-verifier, "human:" to the human. --at runs commands in <dir> (the worker's worktree) instead of the
# repository that holds <gdd-dir>. Needs bash, sed, awk.
# ponytail: checks rerun on every call; cache them if a project's checks get slow.

at=""; args=()
while [ $# -gt 0 ]; do case "$1" in --at) at="$2"; shift 2 ;; *) args+=("$1"); shift ;; esac; done
dir="${args[0]:-gdd}"; slug="${args[1]}"
[ -f "$dir/goal.md" ] || { echo "no $dir/goal.md" >&2; exit 1; }
checks_root="${at:-$(cd "$dir/.." && pwd)}"

checks() { # file -> "id<TAB>spec" for every [id] item followed by a Check: line
  awk '
    match($0, /^[[:space:]]*[0-9]+\.[[:space:]]*\[[A-Za-z0-9_-]+\]/) { s = substr($0, RSTART, RLENGTH); sub(/^[^[]*\[/, "", s); sub(/\].*/, "", s); id = s; next }
    id != "" && /^[[:space:]]*-[[:space:]]*Check:/ { sub(/^[[:space:]]*-[[:space:]]*Check:[[:space:]]*/, ""); print id "\t" $0; id = "" }
  ' "$1"
}

judge() { # spec -> met / not-met / observe / human
  case "$1" in
    '`'*) c=${1#\`}; c=${c%\`*}
          if (cd "$checks_root" && bash -c "$c") >/dev/null 2>&1; then echo met; else echo not-met; fi ;;
    observe:*) echo observe ;;
    *) echo human ;;
  esac
}

if [ -n "$slug" ]; then
  f=$(ls "$dir"/subgoals/*/"$slug".md 2>/dev/null | head -1); [ -n "$f" ] || { echo "no sub-goal $slug" >&2; exit 1; }
  while IFS=$'\t' read -r id spec; do echo "$id: $(judge "$spec")  ($spec)"; done < <(checks "$f"; checks "$dir/goal.md" | grep '^gate	')
  exit 0
fi

out=""
while IFS=$'\t' read -r id spec; do out="$out $id=$(judge "$spec")"; done < <(checks "$dir/goal.md")
open=$(awk '/^## /{p=($0 ~ /Uncertainties|未確定/)} p && /^- / && /\| *open *$/' "$dir/state.md" 2>/dev/null | wc -l | tr -d ' ')
echo "progress: ${out# } open_uncertainties=$open"
