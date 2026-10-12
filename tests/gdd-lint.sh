#!/bin/bash
# Self-check for gdd-lint.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
S="$(cd "$(dirname "$0")/.." && pwd)/plugins/polaris/skills/gdd-loop/scripts/gdd-lint.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/lint-test-XXXX"); cd "$W"
mkdir -p gdd/subgoals gdd/reviews gdd/archive/subgoals
fail=0
has() { if printf '%s\n' "$out" | grep -qF -- "$2"; then echo "PASS $1"; else echo "FAIL $1: no '$2' in:"; printf '%s\n' "$out"; fail=1; fi; }
ok() { if [ "$code" = 0 ]; then echo "PASS $1"; else echo "FAIL $1: exit $code:"; printf '%s\n' "$out"; fail=1; fi; }
run() { out=$(bash "$S" gdd "$@"); code=$?; }

cat > gdd/subgoals/good.md <<'EOF'
---
type: build
advances: capture, U1
depends_on: old
touches: src/a/
---
# good

## Done when

1. [adds] it adds
   - Check: `test -f src/a/x`
2. [feels] it feels right
   - Check: human: taste
3. [looks] it looks right
   - Check: observe: open it
EOF
printf -- '---\ntype: build\nadvances: x\ndepends_on: none\ntouches: a/\n---\n# old\n' > gdd/archive/subgoals/old.md
printf -- '---\nsubgoal: good\nloop: 3\nprogress: capture=met gate=met\n---\n# r\n' > gdd/reviews/good.md
printf '# Goal completion report\n' > gdd/reviews/GOAL.md
run; ok "valid sub-goal, archived dependency, review, GOAL.md"

cat > gdd/subgoals/bad.md <<'EOF'
---
type: feature
advances: <acceptance scenario ids>
depends_on: ghost
---
# bad

## Done when

1. [a] no check here
2. [b] weak check
   - Check: just look at it
3. [b] twice
   - Check: `true`
EOF
run
[ "$code" = 1 ] && echo "PASS broken sub-goal: exit 1" || { echo "FAIL broken sub-goal: exit $code"; fail=1; }
has "type"                "gdd/subgoals/bad.md:2: type: must be build or decide"
has "placeholder"         "gdd/subgoals/bad.md:3: advances: is still the template placeholder"
has "missing dependency"  "gdd/subgoals/bad.md:4: depends_on: no sub-goal ghost"
has "missing key"         "gdd/subgoals/bad.md:1: frontmatter needs touches:"
has "item without check"  "gdd/subgoals/bad.md:10: [a] has no Check: line"
has "check kind"          "gdd/subgoals/bad.md:12: Check: must be a"
has "duplicate id"        "gdd/subgoals/bad.md:13: [b] is used twice"

run gdd/subgoals/bad.md
printf '%s\n' "$out" | grep -q 'no sub-goal ghost' && { echo "FAIL one file: checked depends_on across files"; fail=1; } || echo "PASS one file: depends_on not checked across files"
rm gdd/subgoals/bad.md

printf '# no frontmatter\n' > gdd/subgoals/nofm.md
run gdd/subgoals/nofm.md; has "no frontmatter" "gdd/subgoals/nofm.md:1: needs frontmatter"
rm gdd/subgoals/nofm.md

printf -- '---\nsubgoal: good\nloop: three\n---\n' > gdd/reviews/bad.md
run gdd/reviews/bad.md
has "review loop number" "gdd/reviews/bad.md:3: loop: must be a number"
has "review progress"    "gdd/reviews/bad.md:1: frontmatter needs progress:"

printf '# State\n\n## Uncertainties\n\n- U1 a? | open\n- U2 b? | resolved: yes\n- U3 c? | open (half done)\n\n## Learnings\n\n- x | open (not an uncertainty)\n' > gdd/state.md
run gdd/state.md
has "state: note after open"      "gdd/state.md:7: an uncertainty is"
printf '%s\n' "$out" | grep -q 'state.md:5:\|state.md:6:\|state.md:11:' && { echo "FAIL state: valid lines flagged"; fail=1; } || echo "PASS state: valid lines and other sections pass"
printf '# State\n\n## Uncertainties\n\n- None\n' > gdd/state.md
run gdd/state.md; ok "state: None"

echo "workdir: $W"
exit $fail
