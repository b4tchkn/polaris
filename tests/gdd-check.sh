#!/bin/bash
# Self-check for gdd-check.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
S="$(cd "$(dirname "$0")/.." && pwd)/plugins/polaris/skills/gdd-loop/scripts/gdd-check.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/check-test-XXXX"); cd "$W"
mkdir -p gdd/subgoals src
cat > gdd/goal.md <<'EOF'
---
mode: careful
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
mkdir -p gdd/uncertainties
printf -- '---\nstatus: open\n---\n# a?\n' > gdd/uncertainties/a.md
printf -- '---\nstatus: resolved\n---\n# b?\n\n## Answer\n\nyes\n' > gdd/uncertainties/b.md
fail=0
has() { if printf '%s\n' "$out" | grep -qF -- "$2"; then echo "PASS $1"; else echo "FAIL $1: no '$2' in:"; printf '%s\n' "$out"; fail=1; fi; }

out=$(bash "$S" gdd)
has "progress: command, observe, human, gate" "progress: capture=not-met easy=observe no-forget=human gate=met open_uncertainties=1"
mkdir -p wt/src && touch wt/src/a.txt
out=$(bash "$S" gdd --at "$W/wt"); has "progress: checks run where --at points" "capture=met"
touch src/a.txt src/broken
out=$(bash "$S" gdd); has "progress: gate fails" "capture=met easy=observe no-forget=human gate=not-met"
rm src/broken

cat > gdd/subgoals/items.md <<'EOF'
---
type: build
advances: capture
---
# items

## Done when

1. [adds] it adds
   - Check: `true`
2. [rejects-empty] empty titles are refused
   - Check: `false`
3. [feels] it feels right
   - Check: human: taste
EOF
out=$(bash "$S" gdd items)
has "sub-goal: passing command" "adds: met"
has "sub-goal: failing command" "rejects-empty: not-met"
has "sub-goal: human item"      "feels: human"
has "sub-goal: gate included"   "gate: met"

echo "workdir: $W"
exit $fail
