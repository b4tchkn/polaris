#!/bin/bash
# Self-check for gdd-status.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
S="$(cd "$(dirname "$0")/.." && pwd)/plugins/polaris/skills/gdd-loop/scripts/gdd-status.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/status-test-XXXX"); cd "$W"
mkdir -p gdd/subgoals/candidates gdd/subgoals/in-progress gdd/subgoals/in-review gdd/subgoals/done gdd/reviews
printf -- '---\nmode: careful\n---\n# Goal: t\n' > gdd/goal.md
sg() { # dir slug depends touches
  printf -- '---\ntype: build\nadvances: capture\ndepends_on: %s\ntouches: %s\n---\n# %s\n' "$3" "$4" "$2" > "gdd/subgoals/$1/$2.md"
}
review() { # slug loop progress overridden
  printf -- '---\nsubgoal: %s\nloop: %s\nprogress: %s\npr: none\noverridden: %s\n---\n' "$1" "$2" "$3" "$4" > "gdd/reviews/$1.md"
}
fail=0
has() { if printf '%s\n' "$out" | grep -qF -- "$2"; then echo "PASS $1"; else echo "FAIL $1: no '$2' in:"; printf '%s\n' "$out"; fail=1; fi; }

sg done base none src/base/
sg in-progress cur none src/cur/
sg candidates indep none src/other/
sg candidates dep base src/x/
sg candidates waits cur src/y/
sg candidates clash none src/cur/sub/
out=$(bash "$S" gdd)
has "ready: no deps"                           "indep type=build advances=capture ready=yes"
has "ready: dependency merged"                 "dep type=build advances=capture ready=yes"
has "ready: dependency not merged"             "ready=no ( cur not merged )"
has "overlap: shared path prefix"              "clash type=build advances=capture ready=yes overlaps=[cur ]"
has "no hold without reviews"                  "hold: no"

printf -- '---\ntype: build\nadvances: capture\npr: https://example.invalid/pr/1\n---\n# r\n' > gdd/subgoals/in-review/rev.md
out=$(bash "$S" gdd); has "in-review: pull request listed" "rev type=build advances=capture pr=https://example.invalid/pr/1 state="
git init -q -b main . && git -c user.email=a@b -c user.name=a commit -q --allow-empty -m init
git switch -q -c gdd/rev && git -c user.email=a@b -c user.name=a commit -q --allow-empty -m rev && git switch -q main
out=$(bash "$S" gdd); has "in-review: branch not merged" "state=unknown"
git merge -q gdd/rev
out=$(bash "$S" gdd); has "in-review: branch merged into main counts as merged" "state=MERGED"

review r1 1 "p" false; review r2 2 "p" false
out=$(bash "$S" gdd); has "two equal reviews: not stalled" "stalled: no"
review r3 3 "p" false
out=$(bash "$S" gdd); has "three equal reviews: stalled" "stalled: yes"
has "stall holds" "hold: yes ( stalled; )"
review r3 3 "q" true
out=$(bash "$S" gdd); has "closed pull request holds" "hold: yes ( the latest pull request was closed; )"
review r4 4 "z" false
out=$(bash "$S" gdd); has "a newer review releases the hold" "hold: no"

echo "workdir: $W"
exit $fail
