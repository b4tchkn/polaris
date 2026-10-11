#!/bin/bash
# Mechanical part of gdd-loop: everything that can be decided without judgment, so the AI does not decide it.
#   gdd-status.sh <gdd-dir> [--at <dir>]               progress toward the goal, pull requests, what can start, whether to hold
#   gdd-status.sh <gdd-dir> check <slug> [--at <dir>]  runs a sub-goal's "Done when" checks and the gate
# Checks are the "Check:" lines under each [id] item in goal.md and the sub-goal files: a `command` runs here
# (exit 0 = met); "observe:" is left to the evaluator, "human:" to the human. --at runs commands in <dir>
# (the worker's worktree) instead of the repository that holds <gdd-dir>. Needs bash, sed, grep, awk; gh when present.
# ponytail: checks rerun on every call; cache them if a project's checks get slow.

at=""; args=()
while [ $# -gt 0 ]; do case "$1" in --at) at="$2"; shift 2 ;; *) args+=("$1"); shift ;; esac; done
dir="${args[0]:-gdd}"; cmd="${args[1]}"; slug="${args[2]}"
[ -f "$dir/goal.md" ] || { echo "no $dir/goal.md" >&2; exit 1; }
root=$(cd "$dir/.." && pwd)
checks_root="${at:-$root}"
STALL_N=3   # identical progress in this many latest reviews = stalled

fm() { sed -n '1{/^---$/!q;};2,/^---$/p' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1; }
file_of() { ls "$dir"/subgoals/*/"$1".md 2>/dev/null | head -1; }

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

progress() {
  out=""
  while IFS=$'\t' read -r id spec; do out="$out $id=$(judge "$spec")"; done < <(checks "$dir/goal.md")
  open=$(awk '/^## /{p=($0 ~ /Uncertainties|未確定/)} p && /^- / && /\| *open *$/' "$dir/state.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "${out# } open_uncertainties=$open"
}

reviews_latest() { # review files, newest first, by their `loop:` number
  for f in "$dir"/reviews/*.md; do [ -f "$f" ] && printf '%s\t%s\n' "$(fm "$f" loop)" "$f"; done | sort -rn | cut -f2
}

stalled() {
  latest=$(reviews_latest | head -$STALL_N)
  [ "$(printf '%s\n' "$latest" | grep -c .)" -ge $STALL_N ] || return 1
  [ "$(for f in $latest; do fm "$f" progress; done | sort -u | wc -l | tr -d ' ')" = 1 ]
}

pr_state() { # sub-goal file -> OPEN / MERGED / CLOSED / unknown
  url=$(fm "$1" pr); s=""
  if [ -n "$url" ] && [ "$url" != none ] && command -v gh >/dev/null; then
    s=$(cd "$root" && gh pr view "$url" --json state -q .state 2>/dev/null)
  fi
  # Without a pull request (no remote, no gh), a branch merged into the default branch counts as merged.
  if [ -z "$s" ]; then
    b="gdd/$(basename "$1" .md)"; def=$(git -C "$root" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || echo main)
    git -C "$root" rev-parse -q --verify "$b" >/dev/null 2>&1 && git -C "$root" merge-base --is-ancestor "$b" "$def" 2>/dev/null && s=MERGED
  fi
  echo "${s:-unknown}"
}

overlaps() { # $1 slug: other in-progress / candidate slugs whose touches share a path prefix
  mine=$(fm "$(file_of "$1")" touches | tr ',' ' ')
  for f in "$dir"/subgoals/in-progress/*.md "$dir"/subgoals/candidates/*.md; do
    [ -f "$f" ] || continue; s=$(basename "$f" .md); [ "$s" = "$1" ] && continue
    for a in $mine; do for b in $(fm "$f" touches | tr ',' ' '); do
      case "$a" in "$b"*) echo "$s"; break 2 ;; esac
      case "$b" in "$a"*) echo "$s"; break 2 ;; esac
    done; done
  done | sort -u | tr '\n' ' '
}

ready() { # prints "yes" or "no (<reason>)": every dependency must be merged (in done/)
  why=""
  for d in $(fm "$(file_of "$1")" depends_on | tr ',' ' '); do
    [ "$d" = none ] && continue
    [ -f "$dir/subgoals/done/$d.md" ] || why="$why $d not merged"
  done
  [ -z "$why" ] && echo yes || echo "no ($why )"
}

if [ "$cmd" = check ]; then
  f=$(file_of "$slug"); [ -n "$f" ] || { echo "no sub-goal $slug" >&2; exit 1; }
  while IFS=$'\t' read -r id spec; do echo "$id: $(judge "$spec")  ($spec)"; done < <(checks "$f"; checks "$dir/goal.md" | grep '^gate	')
  exit 0
fi

echo "progress: $(progress)"
stalled && echo "stalled: yes ($STALL_N latest reviews show the same progress)" || echo "stalled: no"
hold=""
stalled && hold="$hold stalled;"
latest=$(reviews_latest | head -1)
[ -n "$latest" ] && [ "$(fm "$latest" overridden)" = true ] && hold="$hold the latest pull request was closed;"
for st in in-review in-progress candidates done; do
  echo "$st:"
  for f in "$dir"/subgoals/$st/*.md; do
    [ -f "$f" ] || continue; s=$(basename "$f" .md)
    line="  $s type=$(fm "$f" type) advances=$(fm "$f" advances)"
    [ "$st" = in-review ] && line="$line pr=$(fm "$f" pr) state=$(pr_state "$f")"
    [ "$st" = candidates ] && line="$line ready=$(ready "$s") overlaps=[$(overlaps "$s")]"
    echo "$line"
  done
done
[ -z "$hold" ] && echo "hold: no" || echo "hold: yes ($hold ) - ask the human before starting new sub-goals"
