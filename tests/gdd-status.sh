#!/bin/bash
# Self-check for gdd-status.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
S="$(cd "$(dirname "$0")/.." && pwd)/plugins/polaris/skills/gdd-loop/scripts/gdd-status.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/status-test-XXXX"); cd "$W"
mkdir -p gdd/subgoals gdd/reviews
echo '# Goal: x' > gdd/goal.md
fail=0
has() { if printf '%s\n' "$out" | grep -qF -- "$2"; then echo "PASS $1"; else echo "FAIL $1: no '$2' in:"; printf '%s\n' "$out"; fail=1; fi; }
sg() { printf -- '---\nstatus: %s\ntype: build\nadvances: a\ndepends_on: %s\ntouches: %s\n---\n# %s\n' "$2" "$3" "$4" "$1" > "gdd/subgoals/$1.md"; }
rv() { printf -- '---\nsubgoal: %s\nloop: %s\nprogress: %s\n---\n# r\n' "$1" "$2" "$3" > "gdd/reviews/$1.md"; }

sg base done none src/a/
sg next todo base src/b/
sg blocked todo next src/c/
sg clash todo base src/b/sub/
sg old cancelled none src/d/
sg now doing none src/e/
out=$(bash "$S" gdd)
has "done listed"            "done: base"
has "cancelled listed"       "cancelled: old"
has "ready when deps done"   "next state=todo type=build advances=a ready=yes"
has "not ready while dep todo" "blocked state=todo type=build advances=a ready=no ( next todo )"
has "overlap by prefix"      "overlaps=[clash ]"
has "doing listed"           "now state=doing"
has "no hold with no reviews" "hold: no"

rv a 1 "x=met"; rv b 2 "x=met"
out=$(bash "$S" gdd); has "no hold with 2 reviews" "hold: no"
rv c 3 "x=met"
out=$(bash "$S" gdd); has "hold with 3 same" "hold: yes"
rv d 4 "x=not-met"
out=$(bash "$S" gdd); has "no hold when progress changed" "hold: no"
printf '# GOAL report\n' > gdd/reviews/GOAL.md
out=$(bash "$S" gdd); has "GOAL.md is not a review" "hold: no"

# --- doing sub-goals read from git: branch gdd/<slug>
G=$(mktemp -d "${TMPDIR:-/tmp}/status-git-XXXX"); cd "$G"
git init -q -b main; git config user.email t@t; git config user.name t
mkdir -p gdd/subgoals; echo '# Goal: x' > gdd/goal.md
sgfile() { printf -- '---\nstatus: %s\ntype: build\nadvances: a\ndepends_on: none\ntouches: %s\n---\n# %s\n' "$2" "$3" "$1" > "gdd/subgoals/$1.md"; }
sgfile finished doing src/f/; sgfile working doing src/w/; sgfile lost doing src/l/; sgfile waits todo src/f/x/
git add -A; git commit -qm base
for b in finished working; do git branch gdd/$b; done
git checkout -q gdd/finished; sgfile finished done src/f/; git commit -qam done; git checkout -q main
out=$(bash "$S" gdd)
has "ready-to-merge from the branch"  "finished state=ready-to-merge branch=gdd/finished"
has "doing with its branch"           "working state=doing branch=gdd/working"
has "doing without a branch"          "lost state=doing branch=none"
has "ready-to-merge blocks overlaps"  "overlaps=[finished ]"
git merge -q --no-ff gdd/finished -m merge; out=$(bash "$S" gdd)
has "done after merge"                "done: finished"
cd "$W"

echo "workdir: $W"
exit $fail
