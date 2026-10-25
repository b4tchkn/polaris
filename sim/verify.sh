#!/bin/bash
# Judges a simulation run in sim/work/<name>/ ($SIM_WORK/<name>/ if set). Exits 0 only if every sub-goal
# in subgoals.txt (one slug per line) is status: done on remote.git's main, has a branch marking it done
# merged into that main, and the command Checks of the Acceptance scenarios and the gate (Definition of done)
# in the simulated gdd/goal.md pass on main.
#   verify.sh <name>
W="${SIM_WORK:-$(cd "$(dirname "$0")" && pwd)/work}/$1"; R="$W/remote.git"
[ -n "$1" ] && [ -s "$W/subgoals.txt" ] || { echo "verify: no $W/subgoals.txt" >&2; exit 1; }
fail=0
bad() { echo "verify: $*" >&2; fail=1; }
while read -r s; do
  [ -n "$s" ] || continue
  f="gdd/subgoals/$s.md"
  git -C "$R" show "main:$f" 2>/dev/null | grep -qx 'status: done' || bad "$s: not status: done on main"
  merged=0
  for b in $(git -C "$R" for-each-ref --format='%(refname:short)' refs/heads/ | grep -vx main); do
    git -C "$R" show "$b:$f" 2>/dev/null | grep -qx 'status: done' || continue
    git -C "$R" merge-base --is-ancestor "$b" main && merged=1
  done
  [ $merged = 1 ] || bad "$s: no branch marking it done is merged into main"
done < "$W/subgoals.txt"
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
git clone -q "$R" "$t/main"
checks() { awk -v h="## $1" '/^## /{d=($0==h)} d' "$t/main/gdd/goal.md" 2>/dev/null | sed -n 's/.*Check: `\(.*\)`.*/\1/p'; }
gates=$(checks "Definition of done")
[ -n "$gates" ] || bad "no gate in the Definition of done of gdd/goal.md on main"
run() { while read -r g; do
  [ -n "$g" ] || continue
  (cd "$t/main" && bash -c "$g") >&2 || bad "$1 failed on main: $g"
done; }
run gate <<< "$gates"
run "acceptance check" <<< "$(checks "Acceptance scenarios")"
[ $fail = 0 ] && echo "verify: ok"
exit $fail
