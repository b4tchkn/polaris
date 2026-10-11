#!/bin/bash
# Self-check for gdd-status.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
S="$(cd "$(dirname "$0")/.." && pwd)/plugins/polaris/skills/gdd-loop/scripts/gdd-status.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/status-test-XXXX"); cd "$W"
mkdir -p gdd/subgoals/candidates gdd/subgoals/in-progress gdd/subgoals/in-review gdd/subgoals/done gdd/reviews src
cat > gdd/goal.md <<'EOF'
---
prefer: certainty
---
# Goal: t

## Acceptance scenarios

1. [capture] a task can be added
   - Check: `test -f src/a.txt`
2. [easy] adding needs no explanation
   - Check: observe: open the app and add a task
3. [no-forget] the family forgets less
   - Check: human: only the family can tell

## Definition of done

1. [gate] the checks pass
   - Check: `test ! -f src/broken`
EOF
printf '# State\n\n## Uncertainties\n\n- U1 a? | open\n- U2 b? | resolved: yes\n\n## Learnings\n\n- x\n' > gdd/state.md
sg() { # dir slug depends touches [done-when items]
  printf -- '---\ntype: build\nadvances: capture\ndepends_on: %s\ntouches: %s\n---\n# %s\n\n## Done when\n\n%s\n' "$3" "$4" "$2" "${5:-1. [ok] fine
   - Check: \`true\`}" > "gdd/subgoals/$1/$2.md"
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
has "progress: command, observe, human, gate"  "capture=not-met easy=observe no-forget=human gate=met open_uncertainties=1"
has "ready: no deps"                           "indep type=build advances=capture ready=yes"
has "ready: dependency merged"                 "dep type=build advances=capture ready=yes"
has "ready: dependency not merged"             "ready=no ( cur not merged )"
has "overlap: shared path prefix"              "clash type=build advances=capture ready=yes overlaps=[cur ]"
has "no hold without reviews"                  "hold: no"

mkdir -p wt/src && touch wt/src/a.txt
out=$(bash "$S" gdd --at "$W/wt"); has "progress: checks run where --at points" "capture=met"
touch src/a.txt src/broken
out=$(bash "$S" gdd); has "progress: gate fails" "capture=met easy=observe no-forget=human gate=not-met"
rm src/broken

sg in-progress items none src/i/ "1. [adds] it adds
   - Check: \`true\`
2. [rejects-empty] empty titles are refused
   - Check: \`false\`
3. [feels] it feels right
   - Check: human: taste"
out=$(bash "$S" gdd check items)
has "check: passing command"  "adds: met"
has "check: failing command"  "rejects-empty: not-met"
has "check: human item"       "feels: human"
has "check: gate included"    "gate: met"

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
