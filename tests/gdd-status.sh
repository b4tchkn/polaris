#!/bin/bash
# Self-check for gdd-status.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
S="$(cd "$(dirname "$0")/.." && pwd)/plugins/polaris/skills/gdd-loop/scripts/gdd-status.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/status-test-XXXX"); cd "$W"
git init -q -b main . && git -c user.email=a@b -c user.name=a commit -q --allow-empty -m init
mkdir -p gdd/subgoals/candidates gdd/subgoals/in-progress gdd/subgoals/done gdd/reviews src
cat > gdd/goal.md <<'EOF'
---
scenario_1_check: test -f src/a.txt
scenario_2_check: human
done_checks: true
max_files: 2
max_lines: 5
---
# Goal: t
EOF
printf '# State\n\n## Uncertainties\n\n- U1 a? | open\n- U2 b? | resolved\n\n## Learnings\n\n- x\n' > gdd/state.md
sg() { # dir slug type depends touches [criterion]
  printf -- '---\ntype: %s\nadvances: scenario_1\ndepends_on: %s\ntouches: %s\ncriterion_1: %s\n---\n# %s\n' "$3" "$4" "$5" "${6:-ok | quantitative | true}" "$2" > "gdd/subgoals/$1/$2.md"
}
review() { # slug loop progress overridden rework
  printf -- '---\nsubgoal: %s\nloop: %s\nprogress: %s\noverridden: %s\nrework: %s\n---\n' "$1" "$2" "$3" "$4" "$5" > "gdd/reviews/$1.md"
}
fail=0
has() { if printf '%s\n' "$out" | grep -qF -- "$2"; then echo "PASS $1"; else echo "FAIL $1: no '$2' in:"; printf '%s\n' "$out"; fail=1; fi; }

sg done base build none src/base/
sg in-progress cur build none src/cur/
sg candidates indep build none src/other/
sg candidates dep build base src/x/
sg candidates waits build cur src/y/
sg candidates clash build none src/cur/sub/
out=$(bash "$S" gdd)
has "progress: scenario not met"        "scenario_1=not-met scenario_2=human open_uncertainties=1"
has "ready: no deps"                    "indep type=build advances=scenario_1 ready=yes"
has "ready: dep done without branch"    "dep type=build advances=scenario_1 ready=yes"
has "ready: dep not done"               "ready=no ( cur not done )"
has "overlap: shared path prefix"       "clash type=build advances=scenario_1 ready=yes overlaps=[cur ]"
has "no stall without reviews"          "stalled: no"

mkdir -p "$W/wt/src" && touch "$W/wt/src/a.txt"
out=$(bash "$S" gdd --at "$W/wt"); has "progress: checks run where --at points" "scenario_1=met"
touch src/a.txt
out=$(bash "$S" gdd); has "progress: scenario met" "scenario_1=met"

# a dependency whose branch is not merged into main is not ready
git branch gdd/base && git switch -q gdd/base && echo b > b.txt && git add b.txt && git -c user.email=a@b -c user.name=a commit -qm b && git switch -q main
out=$(bash "$S" gdd); has "ready: dep branch not merged" "ready=no ( base not merged )"
git merge -q gdd/base
out=$(bash "$S" gdd); has "ready: dep branch merged" "dep type=build advances=scenario_1 ready=yes"

# gate
review r1 1 "p" false none; review r2 2 "p" false none
out=$(bash "$S" gdd gate indep); has "gate: short streak asks" "only 2 of 3"
review r3 3 "q" false none
out=$(bash "$S" gdd gate indep); has "gate: trusted build continues" "auto"
review r4 4 "q" true none
out=$(bash "$S" gdd gate indep); has "gate: override resets the streak" "only 0 of 3"
review r4 4 "q" false none; review r5 5 "q" false none
out=$(bash "$S" gdd gate indep); has "gate: stall asks" "stalled for 3"
review r5 5 "z" false none
sg candidates soft build none src/z/ "reads well | qualitative"
out=$(bash "$S" gdd gate soft); has "gate: qualitative asks" "qualitative criterion"
sg candidates choose decide none docs/
out=$(bash "$S" gdd gate choose); has "gate: decide asks" "decide-type"
git add src/a.txt && git -c user.email=a@b -c user.name=a commit -qm a && git switch -q -c gdd/big && mkdir -p src/big && seq 1 10 > src/big/a && echo 1 > src/big/b && echo 1 > src/big/c && git add src && git -c user.email=a@b -c user.name=a commit -qm big && git switch -q main
sg in-progress big build none src/big/
out=$(bash "$S" gdd gate big); has "gate: too many files" "3 files > max_files 2"
has "gate: too many lines" "12 lines > max_lines 5"

echo "workdir: $W"
exit $fail
