#!/bin/bash
# Where the sub-goals stand, decided without judgment so the AI does not decide it.
#   gdd-status.sh <gdd-dir>   pull requests in review and their state, what can start, what overlaps, whether to hold
# It runs no checks; gdd-check.sh does. Needs bash, sed, grep, awk; gh when present.

dir="${1:-gdd}"
[ -f "$dir/goal.md" ] || { echo "no $dir/goal.md" >&2; exit 1; }
root=$(cd "$dir/.." && pwd)
STALL_N=3   # identical progress in this many latest reviews = stalled

fm() { sed -n '1{/^---$/!q;};2,/^---$/p' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1; }
file_of() { ls "$dir"/subgoals/*/"$1".md 2>/dev/null | head -1; }

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
