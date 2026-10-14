#!/bin/bash
# Where the sub-goals stand, decided without judgment so the AI does not decide it.
#   gdd-status.sh <gdd-dir>   each sub-goal's state, what can start, what overlaps, whether to hold
# Reads the files in <gdd-dir> (a sub-goal's `status:`, `depends_on:`, `touches:`, and the reviews' `progress:`) and, for a
# `doing` sub-goal, its branch gdd/<slug> in git: `doing` on main and `done` on the branch is `ready-to-merge`; `doing`
# with no branch is `doing branch=none`. It runs no checks; gdd-check.sh does. Needs bash, sed, awk, git.

dir="${1:-gdd}"
[ -f "$dir/goal.md" ] || { echo "no $dir/goal.md" >&2; exit 1; }
root=$(cd "$dir/.." && pwd)
STALL_N=3   # identical progress in this many latest reviews = stalled

fm() { sed -n '1{/^---$/!q;};2,/^---$/p' ${1:+"$1"} | sed -n "s/^$2:[[:space:]]*//p" | head -1; }

branch_state() { # slug -> "ready-to-merge" / "doing branch=gdd/<slug>" / "doing branch=none"
  b="gdd/$1"
  git -C "$root" rev-parse -q --verify "refs/heads/$b" >/dev/null 2>&1 || { echo "doing branch=none"; return; }
  if [ "$(git -C "$root" show "$b:gdd/subgoals/$1.md" 2>/dev/null | fm '' status)" = done ]
  then echo "ready-to-merge branch=$b"; else echo "doing branch=$b"; fi
}

states=""
for f in "$dir"/subgoals/*.md; do
  [ -f "$f" ] || continue
  s=$(basename "$f" .md); st=$(fm "$f" status)
  [ "$st" = doing ] && st=$(branch_state "$s")
  states="$states$s $st
"
done
st() { printf '%s' "$states" | awk -v s="$1" '$1 == s { print $2 }'; }

overlaps() { # $1 slug: other unfinished sub-goals whose touches share a path prefix
  mine=$(fm "$dir/subgoals/$1.md" touches | tr ',' ' ')
  for f in "$dir"/subgoals/*.md; do
    s=$(basename "$f" .md); [ "$s" = "$1" ] && continue
    case $(st "$s") in todo|doing|ready-to-merge) ;; *) continue ;; esac
    for a in $mine; do for b in $(fm "$f" touches | tr ',' ' '); do
      case "$a" in "$b"*) echo "$s"; break 2 ;; esac
      case "$b" in "$a"*) echo "$s"; break 2 ;; esac
    done; done
  done | sort -u | tr '\n' ' '
}

ready() { # prints "yes" or "no (<reason>)": every dependency must be done
  why=""
  for d in $(fm "$dir/subgoals/$1.md" depends_on | tr ',' ' '); do
    [ "$d" = none ] && continue
    s=$(st "$d"); [ "$s" = done ] || why="$why $d ${s:-missing}"
  done
  [ -z "$why" ] && echo yes || echo "no ($why )"
}

stalled() {
  latest=$(for f in "$dir"/reviews/*.md; do [ -f "$f" ] && [ "$(basename "$f")" != GOAL.md ] && printf '%s\t%s\n' "$(fm "$f" loop)" "$f"; done | sort -rn | cut -f2 | head -$STALL_N)
  [ "$(printf '%s\n' "$latest" | grep -c .)" -ge $STALL_N ] || return 1
  [ "$(for f in $latest; do fm "$f" progress; done | sort -u | wc -l | tr -d ' ')" = 1 ]
}

for s in done cancelled; do echo "$s: $(printf '%s' "$states" | awk -v x="$s" '$2 == x { print $1 }' | tr '\n' ' ')"; done
echo "sub-goals:"
printf '%s' "$states" | while read -r s state extra; do
  case "$state" in ''|done|cancelled) continue ;; esac
  f="$dir/subgoals/$s.md"
  line="  $s state=$state${extra:+ $extra} type=$(fm "$f" type) advances=$(fm "$f" advances)"
  [ "$state" = todo ] && line="$line ready=$(ready "$s") overlaps=[$(overlaps "$s")]"
  echo "$line"
done
if stalled; then echo "hold: yes (the $STALL_N latest reviews show the same progress) - ask the human before starting new sub-goals"
else echo "hold: no"; fi
