#!/bin/bash
# Where the sub-goals stand, decided without judgment so the AI does not decide it.
#   gdd-status.sh <gdd-dir>   each sub-goal's state, what can start, what overlaps, whether to hold
# A state is never stored; it is read from the pull request whose body has the line
# "Sub-goal: <path of the sub-goal file from the repository root>", and without one from the commits that carry
# the same line. It runs no checks; gdd-check.sh does. Needs bash, sed, awk, git; gh when there is a remote.

dir="${1:-gdd}"
[ -f "$dir/goal.md" ] || { echo "no $dir/goal.md" >&2; exit 1; }
root=$(cd "$dir/.." && pwd)
prefix=$(git -C "$root" rev-parse --show-prefix 2>/dev/null)
STALL_N=3   # identical progress in this many latest reviews = stalled

fm() { sed -n '1{/^---$/!q;};2,/^---$/p' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1; }
path_of() { echo "${prefix}$(basename "$dir")/subgoals/$1.md"; }

prs=""; remote=""
if [ -n "$(git -C "$root" remote 2>/dev/null)" ]; then
  remote=yes
  # ponytail: newest 500 pull requests only; page through them if a repository ever has more.
  prs=$(cd "$root" && gh pr list --state all --limit 500 --json state,url,body,mergeCommit \
    -q '.[] | . as $p | ($p.body // "" | capture("(?m)^Sub-goal: *(?<s>\\S+)").s) as $s | [$s, $p.state, $p.url, ($p.mergeCommit.oid // "")] | @tsv') \
    || { echo "gh failed: install the GitHub CLI (https://cli.github.com) and run 'gh auth login'" >&2; exit 1; }
fi

state_of() { # slug -> "<state> [<pull request URL or branch>]": todo / interrupted / in-review / merged / merged-not-pulled / closed
  p=$(path_of "$1")
  for s in MERGED OPEN CLOSED; do
    row=$(printf '%s\n' "$prs" | awk -F'\t' -v p="$p" -v s="$s" '$1 == p && $2 == s' | head -1)
    [ -n "$row" ] || continue
    url=$(printf '%s' "$row" | cut -f3); oid=$(printf '%s' "$row" | cut -f4)
    case $s in
      MERGED) git -C "$root" merge-base --is-ancestor "$oid" HEAD 2>/dev/null && echo "merged $url" || echo "merged-not-pulled $url" ;;
      OPEN) echo "in-review $url" ;;
      CLOSED) echo "closed $url" ;;
    esac
    return
  done
  # No pull request: the worker's commits carry the same line.
  if [ -n "$(git -C "$root" log HEAD --format=%H -1 --grep="^Sub-goal: $p\$" 2>/dev/null)" ]; then echo merged
  elif c=$(git -C "$root" log --all --format=%H -1 --grep="^Sub-goal: $p\$" 2>/dev/null) && [ -n "$c" ]; then
    b=$(git -C "$root" for-each-ref --contains "$c" --format='%(refname:short)' refs/heads | head -1)
    [ -f "$dir/reviews/$1.md" ] && echo "in-review $b" || echo "interrupted $b"
  else echo todo; fi
}

states=""
for f in "$dir"/subgoals/*.md; do [ -f "$f" ] && states="$states$(basename "$f" .md) $(state_of "$(basename "$f" .md)")
"; done
st() { printf '%s' "$states" | awk -v s="$1" '$1 == s { print $2 }'; }

overlaps() { # $1 slug: other unmerged sub-goals whose touches share a path prefix
  mine=$(fm "$dir/subgoals/$1.md" touches | tr ',' ' ')
  for f in "$dir"/subgoals/*.md; do
    s=$(basename "$f" .md); [ "$s" = "$1" ] && continue
    case $(st "$s") in todo|interrupted|in-review) ;; *) continue ;; esac
    for a in $mine; do for b in $(fm "$f" touches | tr ',' ' '); do
      case "$a" in "$b"*) echo "$s"; break 2 ;; esac
      case "$b" in "$a"*) echo "$s"; break 2 ;; esac
    done; done
  done | sort -u | tr '\n' ' '
}

ready() { # prints "yes" or "no (<reason>)": every dependency must be merged and pulled
  why=""
  for d in $(fm "$dir/subgoals/$1.md" depends_on | tr ',' ' '); do
    [ "$d" = none ] && continue
    s=$(st "$d"); [ "$s" = merged ] || why="$why $d ${s:-missing}"
  done
  [ -z "$why" ] && echo yes || echo "no ($why )"
}

reviews_latest() { # review files, newest first, by their `loop:` number
  for f in "$dir"/reviews/*.md; do [ -f "$f" ] && printf '%s\t%s\n' "$(fm "$f" loop)" "$f"; done | sort -rn | cut -f2
}

stalled() {
  latest=$(reviews_latest | head -$STALL_N)
  [ "$(printf '%s\n' "$latest" | grep -c .)" -ge $STALL_N ] || return 1
  [ "$(for f in $latest; do fm "$f" progress; done | sort -u | wc -l | tr -d ' ')" = 1 ]
}

stalled && echo "stalled: yes ($STALL_N latest reviews show the same progress)" || echo "stalled: no"
hold=""
stalled && hold="$hold stalled;"
latest=$(reviews_latest | head -1)
[ -n "$latest" ] && [ "$(state_of "$(fm "$latest" subgoal)" | cut -d' ' -f1)" = closed ] && hold="$hold the latest pull request was closed;"
echo "sub-goals:"
printf '%s' "$states" | while read -r s state url; do
  [ -n "$s" ] || continue
  f="$dir/subgoals/$s.md"
  line="  $s state=$state type=$(fm "$f" type) advances=$(fm "$f" advances)"
  case "$url" in http*) line="$line pr=$url" ;; ?*) line="$line branch=$url" ;; esac
  [ "$state" = todo ] && line="$line ready=$(ready "$s") overlaps=[$(overlaps "$s")]"
  echo "$line"
done
[ -z "$hold" ] && echo "hold: no" || echo "hold: yes ($hold ) - ask the human before starting new sub-goals"
