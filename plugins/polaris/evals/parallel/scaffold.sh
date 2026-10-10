#!/bin/bash
# Two independent Build candidates with disjoint touches: they are handed to two workers at once.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p par-test/gdd/subgoals/candidates par-test/gdd/subgoals/in-progress par-test/gdd/subgoals/done par-test/gdd/reviews
cat > par-test/gdd/goal.md <<'EOF'
---
scenario_1_check: test "$(cat par-test/left/x.txt)" = x
scenario_2_check: test "$(cat par-test/right/y.txt)" = y
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: parallel test

## North star

Two independent files exist.

## Acceptance scenarios

1. par-test/left/x.txt holds x
2. par-test/right/y.txt holds y

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
cat > par-test/gdd/state.md <<'EOF'
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
cat > par-test/gdd/adr.md <<'EOF'
# ADR

> Decisions the human made, with the human's reasons. Append only; never rewrite.
EOF
cat > par-test/gdd/subgoals/done/setup.md <<'EOF'
---
type: build
advances: process
depends_on: none
touches: par-test/
criterion_1: the folder exists | quantitative | test -d par-test
---
# Set up the folder

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > par-test/gdd/reviews/setup-1.md <<'EOF'
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
cat > par-test/gdd/reviews/setup-2.md <<'EOF'
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
cat > par-test/gdd/reviews/setup-3.md <<'EOF'
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
cat > par-test/gdd/subgoals/candidates/left-x.md <<'EOF'
---
type: build
advances: scenario_1
depends_on: none
touches: par-test/left/
criterion_1: x.txt is x | quantitative | test "$(cat par-test/left/x.txt)" = x
---
# Create par-test/left/x.txt containing x

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > par-test/gdd/subgoals/candidates/right-y.md <<'EOF'
---
type: build
advances: scenario_2
depends_on: none
touches: par-test/right/
criterion_1: y.txt is y | quantitative | test "$(cat par-test/right/y.txt)" = y
---
# Create par-test/right/y.txt containing y

- Done when: it works through its real entry point
- What to show: the file's content
EOF
git add -A
git commit -qm fixture
