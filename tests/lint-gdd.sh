#!/bin/bash
# Self-check for lint-gdd.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LINT="$ROOT/plugins/polaris/scripts/lint-gdd.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/lint-test-XXXX")

fail=0
REVIEW_HEADS='## What was built and how to try it
## Evaluation against the criteria
## Least confident decision
## Discarded ideas
## Questions for the human
## Retrospective
## Improvement proposals
## Next sub-goal options'

# A valid gdd/: SG0 done with a decision, SG1 next and waiting for the human, SG2 later.
fixture() { # dir
  mkdir -p "$1/gdd/reviews"
  printf '# Goal: Morning review\n\n## North star\n\nx\n' > "$1/gdd/goal.md"
  cat > "$1/gdd/subgoals.md" <<'EOF'
# Sub-goals

## Done: SG0 Pick the sources

| Item | Content |
|---|---|
| Goal | Decide which tools to read |
| Type and done condition | Decide. The human agrees |
| Result | Slack and GitHub |

## Next: SG1 Build the skill

| Item | Content |
|---|---|
| Goal | A skill that posts the review |
| Type and done condition | Build. It runs through /morning-review |
| Evaluation criteria | Quantitative: it posts within 1 minute |
| What to show | The posted message |

## Later (rough outlook)

| # | Goal | Type |
|---|---|---|
| SG2 | Use it for a week | Build |
EOF
  { printf '# Sub-goal review: SG0\n\n'; printf '%s\n\nx\n\n' "$REVIEW_HEADS"; printf '## Decision\n\n<!-- c -->\nProceed\n'; } > "$1/gdd/reviews/SG0.md"
  { printf '# Sub-goal review: SG1\n\n'; printf '%s\n\nx\n\n' "$REVIEW_HEADS"; printf '## Decision\n\n<!-- c -->\n'; } > "$1/gdd/reviews/SG1.md"
}

case_() { # name, expected check id ("" = passes), shell edit run inside the fixture
  d="$W/$(printf '%s' "$1" | tr -c 'a-zA-Z0-9' _)"
  fixture "$d"
  (cd "$d" && eval "$3")
  out=$(bash "$LINT" "$d"); rc=$?
  if [ -z "$2" ]; then
    [ "$rc" = 0 ] && echo "PASS $1" || { echo "FAIL $1 (want pass, got: $out)"; fail=1; }
  else
    [ "$rc" = 1 ] && printf '%s' "$out" | grep -q " $2 " && echo "PASS $1" ||
      { echo "FAIL $1 (want $2, got rc=$rc: $out)"; fail=1; }
  fi
}

case_ "valid fixture" "" ":"
case_ "fresh gdd-init templates" "" "rm -r gdd/reviews; cp '$ROOT'/plugins/polaris/skills/gdd-init/templates/{goal,subgoals}.md gdd/"
case_ "G1 goal heading" G1 "sed -i.bak 's/^# Goal: /# /' gdd/goal.md"
case_ "S1 translated heading" S1 "sed -i.bak 's/^## Next: /## 次：/' gdd/subgoals.md"
case_ "S2 two Next" S2 "printf '\n## Next: SG3 Again\n' >> gdd/subgoals.md"
case_ "S2 no Next with Later left" S2 "sed -i.bak 's/^## Next: SG1/## Done: SG1/' gdd/subgoals.md"
case_ "S3 Done after Next" S3 "printf '\n## Done: SG4 Late\n' >> gdd/subgoals.md"
case_ "S4 duplicate SG" S4 "sed -i.bak 's/^| SG2 |/| SG1 |/' gdd/subgoals.md"
case_ "S5 missing row" S5 "sed -i.bak '/^| What to show |/d' gdd/subgoals.md"
case_ "S5 empty row" S5 "sed -i.bak 's/^| Evaluation criteria | .*/| Evaluation criteria | |/' gdd/subgoals.md"
case_ "S6 type without a period" S6 "sed -i.bak 's/Build. It runs/Build: it runs/' gdd/subgoals.md"
case_ "S7 bad Later row" S7 "sed -i.bak 's/^| SG2 | Use it for a week | Build |/| Use it for a week | Build |/' gdd/subgoals.md"
case_ "R1 review of an unknown SG" R1 "cp gdd/reviews/SG0.md gdd/reviews/SG9.md"
case_ "R2 translated review heading" R2 "sed -i.bak 's/^## Questions for the human/## 人間への質問/' gdd/reviews/SG1.md"
case_ "R2 Decision not last" R2 "printf '\n## Notes\n' >> gdd/reviews/SG1.md"
case_ "R4 empty decision on the last Done" R4 "sed -i.bak 's/^Proceed$//' gdd/reviews/SG0.md"
case_ "X1 empty decision off Next" X1 "{ printf '%s\n' '## Done: SG5 Old'; cat gdd/subgoals.md; } > s && mv s gdd/subgoals.md && sed 's/^Proceed$//' gdd/reviews/SG0.md > gdd/reviews/SG5.md"
case_ "X2 last Done without review" X2 "rm gdd/reviews/SG0.md"

exit "$fail"
