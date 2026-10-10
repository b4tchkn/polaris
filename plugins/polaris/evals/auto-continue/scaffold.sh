#!/bin/bash
# Three earlier reviews were kept, so Build sub-goals with only quantitative criteria continue without the human; the one with a qualitative criterion stops.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p auto-test/gdd/subgoals/candidates auto-test/gdd/subgoals/in-progress auto-test/gdd/subgoals/done auto-test/gdd/reviews
cat > auto-test/gdd/goal.md <<'EOF'
---
scenario_1_check: test "$(cat auto-test/a.txt)" = a
scenario_2_check: test "$(cat auto-test/b.txt)" = b
scenario_3_check: human
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: auto-continue test

## North star

Three small files exist with the right content.

## Acceptance scenarios

1. auto-test/a.txt holds the single line a
2. auto-test/b.txt holds the single line b
3. auto-test/c.txt holds a short greeting the human finds natural

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
cat > auto-test/gdd/state.md <<'EOF'
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
cat > auto-test/gdd/adr.md <<'EOF'
# ADR

> Decisions the human made, with the human's reasons. Append only; never rewrite.
EOF
cat > auto-test/gdd/subgoals/done/setup.md <<'EOF'
---
type: build
advances: process
depends_on: none
touches: auto-test/
criterion_1: the folder exists | quantitative | test -d auto-test
---
# Set up the folder

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > auto-test/gdd/reviews/setup-1.md <<'EOF'
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
cat > auto-test/gdd/reviews/setup-2.md <<'EOF'
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
cat > auto-test/gdd/reviews/setup-3.md <<'EOF'
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
cat > auto-test/gdd/subgoals/candidates/a-txt.md <<'EOF'
---
type: build
advances: scenario_1
depends_on: none
touches: auto-test/a.txt
criterion_1: a.txt is exactly a | quantitative | test "$(cat auto-test/a.txt)" = a
---
# Create auto-test/a.txt containing the single line a

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > auto-test/gdd/subgoals/candidates/b-txt.md <<'EOF'
---
type: build
advances: scenario_2
depends_on: none
touches: auto-test/b.txt
criterion_1: b.txt is exactly b | quantitative | test "$(cat auto-test/b.txt)" = b
---
# Create auto-test/b.txt containing the single line b

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > auto-test/gdd/subgoals/candidates/c-txt.md <<'EOF'
---
type: build
advances: scenario_3
depends_on: none
touches: auto-test/c.txt
criterion_1: c.txt has one line | quantitative | test $(wc -l < auto-test/c.txt) -eq 1
criterion_2: the human finds it natural as a greeting | qualitative
---
# Create auto-test/c.txt with a short greeting

- Done when: it works through its real entry point
- What to show: the file's content
EOF
git add -A
git commit -qm fixture
