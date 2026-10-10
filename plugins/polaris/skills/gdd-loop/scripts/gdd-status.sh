#!/bin/bash
# Mechanical part of gdd-loop: reads the frontmatter of gdd/ files and reports what can be decided without judgment.
#   gdd-status.sh <gdd-dir>              goal distance, stall, streak, sub-goals and whether each candidate is ready
#   gdd-status.sh <gdd-dir> gate <slug>  "auto" or "ask: <reasons>" for continuing after <slug> without the human
# Frontmatter is flat `key: value`, one per line. Needs bash, git, sed, grep, awk. gh is used when present.
# ponytail: scenario and done checks rerun on every call; cache them if a project's checks get slow.

dir="${1:-gdd}"; cmd="$2"; slug="$3"
[ -f "$dir/goal.md" ] || { echo "no $dir/goal.md" >&2; exit 1; }
root=$(cd "$dir/.." && pwd)
STALL_N=3   # identical progress in this many latest reviews = stalled
TRUST_N=3   # this many latest reviews not overridden and without rework = trusted

fm() { sed -n '1{/^---$/!q;};2,/^---$/p' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1; }
fm_keys() { sed -n '1{/^---$/!q;};2,/^---$/p' "$1" | sed -n "s/^\($2\):.*/\1/p"; }
run() { (cd "$root" && bash -c "$1") >/dev/null 2>&1; }
file_of() { ls "$dir"/subgoals/*/"$1".md 2>/dev/null | head -1; }
state_of() { f=$(file_of "$1"); [ -n "$f" ] && basename "$(dirname "$f")"; }
default_ref() { git -C "$root" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || echo main; }

merged() { # a done sub-goal counts as merged when it has no branch, or its PR / branch is in the default branch
  git -C "$root" rev-parse -q --verify "gdd/$1" >/dev/null || return 0
  if command -v gh >/dev/null && [ "$(cd "$root" && gh pr view "gdd/$1" --json state -q .state 2>/dev/null)" = MERGED ]; then return 0; fi
  git -C "$root" merge-base --is-ancestor "gdd/$1" "$(default_ref)" 2>/dev/null
}

progress() {
  out=""
  for k in $(fm_keys "$dir/goal.md" 'scenario_[0-9]*_check'); do
    c=$(fm "$dir/goal.md" "$k"); n=${k%_check}
    if [ "$c" = human ]; then r=human; elif run "$c"; then r=met; else r=not-met; fi
    out="$out $n=$r"
  done
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

streak() {
  n=0
  for f in $(reviews_latest); do
    [ "$(fm "$f" overridden)" = false ] && [ "$(fm "$f" rework)" = none ] || break
    n=$((n+1))
  done
  echo $n
}

overlaps() { # $1 slug: other in-progress / ready slugs whose touches share a path prefix
  mine=$(fm "$(file_of "$1")" touches | tr ',' ' ')
  for f in "$dir"/subgoals/in-progress/*.md "$dir"/subgoals/candidates/*.md; do
    [ -f "$f" ] || continue; s=$(basename "$f" .md); [ "$s" = "$1" ] && continue
    for a in $mine; do for b in $(fm "$f" touches | tr ',' ' '); do
      case "$a" in "$b"*) echo "$s"; break 2 ;; esac
      case "$b" in "$a"*) echo "$s"; break 2 ;; esac
    done; done
  done | sort -u | tr '\n' ' '
}

ready() { # prints "yes" or "no (<reason>)"
  f=$(file_of "$1"); why=""
  for d in $(fm "$f" depends_on | tr ',' ' '); do
    [ "$d" = none ] && continue
    [ "$(state_of "$d")" = done ] || { why="$why $d not done"; continue; }
    merged "$d" || why="$why $d not merged"
  done
  [ -z "$why" ] && echo yes || echo "no ($why )"
}

if [ "$cmd" = gate ]; then
  f=$(file_of "$slug"); [ -n "$f" ] || { echo "no sub-goal $slug" >&2; exit 1; }
  why=""
  [ "$(fm "$f" type)" = build ] || why="$why decide-type;"
  for k in $(fm_keys "$f" 'criterion_[0-9]*'); do
    case "$(fm "$f" "$k")" in *"| qualitative"*) why="$why qualitative criterion;"; break ;; esac
  done
  dc=$(fm "$dir/goal.md" done_checks)
  [ -z "$dc" ] || [ "$dc" = none ] || run "$dc" || why="$why done_checks fail;"
  if git -C "$root" rev-parse -q --verify "gdd/$slug" >/dev/null; then
    base=$(git -C "$root" merge-base "$(default_ref)" "gdd/$slug" 2>/dev/null)
    stat=$(git -C "$root" diff --numstat "$base" "gdd/$slug" -- . ':(exclude)gdd' ':(exclude)*/gdd' 2>/dev/null)
    files=$(printf '%s\n' "$stat" | grep -c .); lines=$(printf '%s\n' "$stat" | awk '{s+=$1+$2} END{print s+0}')
    mf=$(fm "$dir/goal.md" max_files); ml=$(fm "$dir/goal.md" max_lines)
    [ -z "$mf" ] || [ "$files" -le "$mf" ] || why="$why $files files > max_files $mf;"
    [ -z "$ml" ] || [ "$lines" -le "$ml" ] || why="$why $lines lines > max_lines $ml;"
  fi
  stalled && why="$why stalled for $STALL_N reviews;"
  s=$(streak); [ "$s" -ge $TRUST_N ] || why="$why only $s of $TRUST_N latest reviews kept without override or rework;"
  [ -z "$why" ] && echo auto || echo "ask:$why"
  exit 0
fi

echo "progress: $(progress)"
dc=$(fm "$dir/goal.md" done_checks)
if [ -z "$dc" ] || [ "$dc" = none ]; then echo "done_checks: none"; elif run "$dc"; then echo "done_checks: pass"; else echo "done_checks: fail"; fi
stalled && echo "stalled: yes ($STALL_N latest reviews show the same progress)" || echo "stalled: no"
echo "streak: $(streak) (latest reviews kept without override or rework; $TRUST_N needed to continue without asking)"
for st in in-progress candidates done; do
  echo "$st:"
  for f in "$dir"/subgoals/$st/*.md; do
    [ -f "$f" ] || continue; s=$(basename "$f" .md)
    line="  $s type=$(fm "$f" type) advances=$(fm "$f" advances)"
    [ "$st" = candidates ] && line="$line ready=$(ready "$s") overlaps=[$(overlaps "$s")]"
    echo "$line"
  done
done
