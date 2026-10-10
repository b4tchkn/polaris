#!/bin/bash
# One criterion the evaluator can measure, one it cannot check offline. The evaluator says Not checked, the table is pasted unchanged, the loop does not continue on its own, and the retrospective turns the problem into a candidate.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p ev-test/gdd/subgoals/candidates ev-test/gdd/subgoals/in-progress ev-test/gdd/subgoals/done ev-test/gdd/reviews
cat > ev-test/gdd/goal.md <<'EOF'
---
scenario_1_check: test "$(cat ev-test/a.txt)" = a
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: ev test

## North star

a.txt exists and CI is green.

## Acceptance scenarios

1. ev-test/a.txt holds a

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
cat > ev-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- None

## Built so far

- None

## Uncertainties

> What is still unknown about reaching the goal. One per line: `- U<n> <question> | open` or `| resolved: <answer>`.

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > ev-test/gdd/adr.md <<'EOF'
# ADR

> Decisions the human made, with the human's reasons. Append only; never rewrite.
EOF
cat > ev-test/gdd/subgoals/done/setup.md <<'EOF'
---
type: build
advances: process
depends_on: none
touches: ev-test/
criterion_1: the folder exists | quantitative | test -d ev-test
---
# Set up the folder

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > ev-test/gdd/reviews/setup-1.md <<'EOF'
---
subgoal: setup-1
loop: 1
progress: scenario_1=not-met open_uncertainties=3
auto: false
overridden: false
rework: none
---
# Sub-goal review: setup-1


## Decision

<!-- gdd-loop writes the outcome here: "Proceed (automatic). Next: <slug>", or the human's answer (OK / Change something with the comment / Stop). -->
OK.
EOF
cat > ev-test/gdd/reviews/setup-2.md <<'EOF'
---
subgoal: setup-2
loop: 2
progress: scenario_1=not-met open_uncertainties=2
auto: false
overridden: false
rework: none
---
# Sub-goal review: setup-2


## Decision

<!-- gdd-loop writes the outcome here: "Proceed (automatic). Next: <slug>", or the human's answer (OK / Change something with the comment / Stop). -->
OK.
EOF
cat > ev-test/gdd/reviews/setup-3.md <<'EOF'
---
subgoal: setup-3
loop: 3
progress: scenario_1=not-met open_uncertainties=1
auto: false
overridden: false
rework: none
---
# Sub-goal review: setup-3


## Decision

<!-- gdd-loop writes the outcome here: "Proceed (automatic). Next: <slug>", or the human's answer (OK / Change something with the comment / Stop). -->
OK.
EOF
cat > ev-test/gdd/subgoals/candidates/a-txt.md <<'EOF'
---
type: build
advances: scenario_1
depends_on: none
touches: ev-test/a.txt
criterion_1: a.txt is a | quantitative | test "$(cat ev-test/a.txt)" = a
criterion_2: the GitHub Actions run for the commit that adds a.txt has passed | quantitative | gh run list --limit 1 --json conclusion -q '.[0].conclusion' | grep -qx success
---
# Create ev-test/a.txt containing a

- Done when: it works through its real entry point
- What to show: the file's content
EOF
git add -A
git commit -qm fixture
