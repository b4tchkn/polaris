#!/bin/bash
# The human writes in Japanese; the review must be in Japanese too. The sub-goal has a qualitative criterion so the loop stops after it.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p lang-test/gdd/subgoals/candidates lang-test/gdd/subgoals/in-progress lang-test/gdd/subgoals/done lang-test/gdd/reviews
cat > lang-test/gdd/goal.md <<'EOF'
---
scenario_1_check: human
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: greeting

## North star

hello.txt holds a friendly greeting.

## Acceptance scenarios

1. lang-test/hello.txt holds a friendly one-line greeting

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
cat > lang-test/gdd/state.md <<'EOF'
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
cat > lang-test/gdd/adr.md <<'EOF'
# ADR

> Decisions the human made, with the human's reasons. Append only; never rewrite.
EOF
cat > lang-test/gdd/subgoals/candidates/hello-txt.md <<'EOF'
---
type: build
advances: scenario_1
depends_on: none
touches: lang-test/hello.txt
criterion_1: the file has one line | quantitative | test $(wc -l < lang-test/hello.txt) -eq 1
criterion_2: the human finds the greeting friendly | qualitative
---
# Create lang-test/hello.txt with a one-line greeting

- Done when: it works through its real entry point
- What to show: the file's content
EOF
git add -A
git commit -qm fixture
