#!/bin/bash
# Checks the format of gdd sub-goal and review files and of the uncertainties in state.md, so a broken file is caught when it is written instead of
# being misread later (an [id] without a Check: line would silently go unchecked).
#   gdd-lint.sh <gdd-dir>             state.md and every file in subgoals/ and reviews/, and that depends_on names existing sub-goals
#   gdd-lint.sh <gdd-dir> <file>...   only those files (the hook runs this right after a write)
# Prints "<file>:<line>: <problem>" and exits 1 when anything is wrong. Runs nothing else. Needs bash, awk.

dir="${1:-gdd}"; [ $# -gt 0 ] && shift
fail=0
say() { echo "$1:$2: $3"; fail=1; }

val=""; at=1
need() { # file key: sets $val and $at, or reports a missing or placeholder value
  r=$(awk -v k="$2" 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, k ":") == 1 { v = substr($0, length(k) + 2); sub(/^[ \t]+/, "", v); print NR "\t" v; exit }' "$1")
  val=${r#*	}; at=${r%%	*}
  if [ -z "$r" ] || [ -z "$val" ]; then say "$1" 1 "frontmatter needs $2:"; return 1; fi
  case "$val" in '<'*) say "$1" "$at" "$2: is still the template placeholder"; return 1 ;; esac
}

items() { # every [id] item needs a Check: line before the next item or heading, and ids are unique
  awk '
    function flush() { if (id != "") print line ": [" id "] has no Check: line"; id = "" }
    match($0, /^[[:space:]]*[0-9]+\.[[:space:]]*\[[A-Za-z0-9_-]+\]/) {
      flush(); s = substr($0, RSTART, RLENGTH); sub(/^[^[]*\[/, "", s); sub(/\].*/, "", s); id = s; line = NR
      if (seen[id]++) print NR ": [" id "] is used twice"
      next
    }
    id != "" && /^[[:space:]]*-[[:space:]]*Check:/ {
      v = $0; sub(/^[[:space:]]*-[[:space:]]*Check:[[:space:]]*/, "", v)
      if (v !~ /^`[^`]+`/ && v !~ /^observe:[[:space:]]*[^[:space:]]/ && v !~ /^human:[[:space:]]*[^[:space:]]/)
        print NR ": Check: must be a `command`, observe: <what to look at>, or human: <why only a human can judge>"
      id = ""; next
    }
    /^#/ { flush() }
    END { flush() }' "$1"
}

subgoal() {
  head -1 "$1" | grep -qx -- '---' || { say "$1" 1 "needs frontmatter (see templates/subgoal.md)"; return; }
  need "$1" type && case "$val" in build|decide) ;; *) say "$1" "$at" "type: must be build or decide" ;; esac
  need "$1" advances
  need "$1" depends_on && [ -n "$whole" ] && for d in $(printf '%s' "$val" | tr ',' ' '); do
    [ "$d" = none ] || [ -f "$dir/subgoals/$d.md" ] || [ -f "$dir/archive/subgoals/$d.md" ] || say "$1" "$at" "depends_on: no sub-goal $d"
  done
  need "$1" touches
  items "$1" | while IFS= read -r l; do echo "$1:$l"; done | grep . && fail=1
}

review() {
  head -1 "$1" | grep -qx -- '---' || { say "$1" 1 "needs frontmatter (see templates/review.md)"; return; }
  need "$1" subgoal
  need "$1" loop && case "$val" in *[!0-9]*) say "$1" "$at" "loop: must be a number" ;; esac
  need "$1" progress
}

state() { # each line under "Uncertainties" is "- U<n> <question> | open" or "| resolved: <answer>" (gdd-check.sh counts the open ones)
  awk '/^## /{p=($0 ~ /Uncertainties|未確定/)} p && /^- / && $0 != "- None" && !/^- U[0-9]+ .*[^ ] \| open$/ && !/^- U[0-9]+ .* \| resolved: .*[^ ]/ {print NR}' "$1" |
    while IFS= read -r n; do echo "$1:$n: an uncertainty is \"- U<n> <question> | open\" or \"- U<n> <question> | resolved: <answer>\" (put notes before the |)"; done | grep . && fail=1
}

whole=""
if [ $# -eq 0 ]; then whole=yes; set -- "$dir/state.md" "$dir"/subgoals/*.md "$dir"/reviews/*.md; fi
for f in "$@"; do
  [ -f "$f" ] || continue
  case "$f" in
    */archive/*) ;;
    */reviews/GOAL.md) ;;
    */state.md) state "$f" ;;
    */subgoals/*.md) subgoal "$f" ;;
    */reviews/*.md) review "$f" ;;
  esac
done
exit $fail
