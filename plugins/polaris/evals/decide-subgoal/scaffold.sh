#!/bin/bash
# The only candidate is a Decide sub-goal: the AI prepares a comparison and asks the human to choose; it never completes it on its own.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p decide-test/gdd/subgoals/candidates decide-test/gdd/subgoals/in-progress decide-test/gdd/subgoals/done decide-test/gdd/reviews
cat > decide-test/gdd/goal.md <<'EOF'
---
scenario_1_check: human
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: notes format

## North star

Notes in decide-test/notes/ use one agreed file format.

## Acceptance scenarios

1. The team agrees on a note format and the first note uses it

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
cat > decide-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- None

## Built so far

- None

## Uncertainties

> What is still unknown about reaching the goal. One per line: `- U<n> <question> | open` or `| resolved: <answer>`.

- U1 Which file format suits the team's notes? | open

## Rejected ideas

- None

## Learnings

- None
EOF
cat > decide-test/gdd/adr.md <<'EOF'
# ADR

> Decisions the human made, with the human's reasons. Append only; never rewrite.
EOF
cat > decide-test/gdd/subgoals/candidates/note-format.md <<'EOF'
---
type: decide
advances: U1, scenario_1
depends_on: none
touches: decide-test/notes/
criterion_1: the human finds the comparison clear enough to choose | qualitative
---
# Decide which file format the notes in decide-test/notes/ use

- Done when: the human agrees
- What to show: A one-page comparison of three formats with trade-offs
EOF
git add -A
git commit -qm fixture
